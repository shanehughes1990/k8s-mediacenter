#!/usr/bin/env bash
# Install automated host updates + Monday 4am (America/Toronto) reboot cycle
# + ensure mediacenter stack comes up after every boot.
#
# Usage:
#   sudo ./scripts/install-system-maintenance.sh

set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo $0"
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_DIR="$REPO_ROOT"

install -m 0755 "${REPO_ROOT}/scripts/mediacenter-boot.sh" /usr/local/sbin/mediacenter-boot.sh
install -m 0755 "${REPO_ROOT}/scripts/system-maintenance.sh" /usr/local/sbin/system-maintenance.sh
install -m 0755 "${REPO_ROOT}/scripts/fix-nvidia-mismatch.sh" /usr/local/sbin/fix-nvidia-mismatch.sh
install -m 0755 "${REPO_ROOT}/scripts/plex-db-backup.sh" /usr/local/sbin/plex-db-backup.sh

# ---------------------------------------------------------------------------
# 1) Daily unattended upgrades (security + regular updates)
#    NVIDIA stays blacklisted daily (prevents mid-week Plex outages).
#    Full nvidia + dist-upgrade runs Monday before reboot.
# ---------------------------------------------------------------------------
cat >/etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

cat >/etc/apt/apt.conf.d/51unattended-upgrades-mediacenter <<'EOF'
// Managed by k8s-mediacenter/scripts/install-system-maintenance.sh
// Daily: apply security + updates automatically.
// Reboots are NOT done daily — weekly Monday maintenance handles reboot.

Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}";
        "${distro_id}:${distro_codename}-security";
        "${distro_id}:${distro_codename}-updates";
        "${distro_id}ESMApps:${distro_codename}-apps-security";
        "${distro_id}ESM:${distro_codename}-infra-security";
};

// Do not reboot mid-week; Monday 4am job reboots intentionally.
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::MinimalSteps "true";
EOF

# Keep nvidia off daily unattended (weekly maintenance upgrades them + reboots)
cat >/etc/apt/apt.conf.d/52unattended-upgrades-nvidia <<'EOF'
// Managed by k8s-mediacenter — daily unattended must not swap the live NVIDIA module.
// Weekly system-maintenance.timer upgrades nvidia packages and reboots.
Unattended-Upgrade::Package-Blacklist {
    "nvidia-";
    "libnvidia-";
    "xserver-xorg-video-nvidia-";
};
EOF

# ---------------------------------------------------------------------------
# 2) Boot: docker → nvidia health → compose up
# ---------------------------------------------------------------------------
cat >/etc/systemd/system/mediacenter.service <<EOF
[Unit]
Description=Mediacenter Docker Compose stack
Documentation=file://${COMPOSE_DIR}/README.md
After=network-online.target docker.service
Wants=network-online.target
Requires=docker.service
# Start after NVIDIA persistence/modules if present (ignore if missing)
After=nvidia-persistenced.service
Wants=nvidia-persistenced.service

[Service]
Type=oneshot
RemainAfterExit=yes
Environment=COMPOSE_DIR=${COMPOSE_DIR}
Environment=COMPOSE_FILE=${COMPOSE_DIR}/docker-compose.yml
ExecStart=/usr/local/sbin/mediacenter-boot.sh
ExecStop=/usr/bin/docker compose -f ${COMPOSE_DIR}/docker-compose.yml --project-directory ${COMPOSE_DIR} stop
TimeoutStartSec=600
TimeoutStopSec=120

[Install]
WantedBy=multi-user.target
EOF

# ---------------------------------------------------------------------------
# 3) Weekly Monday 04:00 America/Toronto: full upgrade + reboot
# ---------------------------------------------------------------------------
cat >/etc/systemd/system/system-maintenance.service <<'EOF'
[Unit]
Description=Weekly host package upgrade and reboot
Documentation=man:apt-get(8)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
# Nice lower priority so media can keep streaming until reboot window
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=7
Environment=REBOOT=1
Environment=COMPOSE_DIR=/data/workspace/k8s-mediacenter
ExecStart=/usr/local/sbin/system-maintenance.sh
TimeoutStartSec=0
EOF

# OnCalendar with timezone: systemd supports America/Toronto in newer versions
cat >/etc/systemd/system/system-maintenance.timer <<'EOF'
[Unit]
Description=Weekly system maintenance (Mon 04:00 America/Toronto)

[Timer]
# 4:00am Eastern — handles EST/EDT automatically
OnCalendar=Mon *-*-* 04:00:00 America/Toronto
Persistent=true
Unit=system-maintenance.service

[Install]
WantedBy=timers.target
EOF

# ---------------------------------------------------------------------------
# 4) Ensure docker enabled; optional daemon hardening for restarts
# ---------------------------------------------------------------------------
systemctl enable docker.service

# Merge LiveRestore so containers survive docker daemon restarts (not host reboots)
DAEMON_JSON=/etc/docker/daemon.json
if [[ -f "$DAEMON_JSON" ]]; then
  if command -v python3 &>/dev/null; then
    python3 - <<'PY'
import json
from pathlib import Path
p = Path("/etc/docker/daemon.json")
data = json.loads(p.read_text() or "{}")
data.setdefault("runtimes", {}).setdefault("nvidia", {"path": "nvidia-container-runtime", "args": []})
# live-restore helps across `systemctl restart docker` but not host reboot
data["live-restore"] = True
# ensure containers are restarted by docker after unclean shutdowns
data["default-ulimits"] = data.get("default-ulimits") or {}
p.write_text(json.dumps(data, indent=2) + "\n")
print("updated", p)
PY
  fi
else
  cat >"$DAEMON_JSON" <<'EOF'
{
  "live-restore": true,
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "args": []
    }
  }
}
EOF
fi

# ---------------------------------------------------------------------------
# 5) Enable units
# ---------------------------------------------------------------------------
systemctl daemon-reload
systemctl enable mediacenter.service
systemctl enable --now system-maintenance.timer

# Ensure related timers from prior setup still enabled
systemctl enable --now nvidia-mismatch-check.timer 2>/dev/null || true
systemctl enable --now plex-db-backup.timer 2>/dev/null || true
systemctl enable unattended-upgrades.service 2>/dev/null || true

# Start mediacenter unit now (marks RemainAfterExit active; stack already running)
systemctl start mediacenter.service || true

echo
echo "=== Installed ==="
echo "  Daily:  unattended-upgrades (security + updates; nvidia blacklisted)"
echo "  Weekly: system-maintenance.timer → Mon 04:00 America/Toronto upgrade+reboot"
echo "  Boot:   mediacenter.service → nvidia check + docker compose up -d"
echo
systemctl list-timers system-maintenance.timer mediacenter.service nvidia-mismatch-check.timer plex-db-backup.timer --no-pager 2>/dev/null || true
systemctl status system-maintenance.timer mediacenter.service --no-pager -l 2>/dev/null | head -40
echo
echo "Next maintenance: $(systemctl show system-maintenance.timer -p NextElapseUSecRealtime --value 2>/dev/null || true)"
echo "Manual dry-run upgrade without reboot:"
echo "  sudo REBOOT=0 /usr/local/sbin/system-maintenance.sh"
echo "Manual stack bring-up:"
echo "  sudo systemctl start mediacenter.service"
