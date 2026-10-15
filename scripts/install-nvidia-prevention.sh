#!/usr/bin/env bash
# Prevent recurring NVIDIA "driver disappeared" failures caused by
# unattended-upgrades swapping userspace/DKMS while the old module stays loaded.
#
# Installs:
#   1) apt unattended-upgrades blacklist for nvidia* packages
#   2) systemd timer: daily nvidia mismatch check + optional auto-fix
#   3) optional: notify when /var/run/reboot-required appears
#
# Usage:
#   sudo ./scripts/install-nvidia-prevention.sh
#   sudo ./scripts/install-nvidia-prevention.sh --with-auto-fix

set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root: sudo $0"
  exit 2
fi

AUTO_FIX=0
[[ "${1:-}" == "--with-auto-fix" ]] && AUTO_FIX=1

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIX_SCRIPT="${REPO_ROOT}/scripts/fix-nvidia-mismatch.sh"
CHECK_SCRIPT="/usr/local/sbin/nvidia-mismatch-check"
UNIT_DIR="/etc/systemd/system"

install -m 0755 "$FIX_SCRIPT" /usr/local/sbin/fix-nvidia-mismatch.sh

# --- 1) Stop unattended upgrades from silently changing the driver ---
cat >/etc/apt/apt.conf.d/52unattended-upgrades-nvidia <<'EOF'
// Managed by k8s-mediacenter/scripts/install-nvidia-prevention.sh
// NVIDIA kernel modules cannot be hot-swapped safely by package upgrades.
// Keep security updates for the rest of the system; upgrade nvidia on purpose,
// then reboot (or run: sudo fix-nvidia-mismatch.sh).
Unattended-Upgrade::Package-Blacklist {
    "nvidia-";
    "libnvidia-";
    "xserver-xorg-video-nvidia-";
};
EOF
echo "Installed /etc/apt/apt.conf.d/52unattended-upgrades-nvidia"

# --- 2) Daily health check ---
cat >"$CHECK_SCRIPT" <<EOF
#!/usr/bin/env bash
set -euo pipefail
LOG_TAG=nvidia-mismatch-check
LOADED="none"
[[ -r /proc/driver/nvidia/version ]] && LOADED=\$(awk '/NVRM version/{print \$8; exit}' /proc/driver/nvidia/version)
INSTALLED="unknown"
if [[ -e /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 ]]; then
  INSTALLED=\$(readlink -f /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 | grep -oE '[0-9]+\\.[0-9]+(\\.[0-9]+)?' | tail -1)
fi

if ! nvidia-smi &>/dev/null; then
  logger -t "\$LOG_TAG" "nvidia-smi FAILED (loaded=\$LOADED installed=\$INSTALLED)"
  if [[ "$AUTO_FIX" == "1" ]]; then
    logger -t "\$LOG_TAG" "attempting auto-fix"
    /usr/local/sbin/fix-nvidia-mismatch.sh --fix || true
  fi
  exit 1
fi

if [[ "\$LOADED" != "none" && "\$INSTALLED" != "unknown" && "\$LOADED" != "\$INSTALLED" ]]; then
  logger -t "\$LOG_TAG" "MISMATCH loaded=\$LOADED installed=\$INSTALLED"
  if [[ "$AUTO_FIX" == "1" ]]; then
    /usr/local/sbin/fix-nvidia-mismatch.sh --fix || true
  fi
  exit 1
fi

if [[ -f /var/run/reboot-required ]]; then
  logger -t "\$LOG_TAG" "host reboot-required pkgs=\$(tr '\\n' ' ' </var/run/reboot-required.pkgs 2>/dev/null || true)"
fi
exit 0
EOF
chmod 0755 "$CHECK_SCRIPT"

cat >"${UNIT_DIR}/nvidia-mismatch-check.service" <<EOF
[Unit]
Description=Check NVIDIA kernel/userspace driver version match
After=network-online.target docker.service

[Service]
Type=oneshot
ExecStart=${CHECK_SCRIPT}
EOF

cat >"${UNIT_DIR}/nvidia-mismatch-check.timer" <<'EOF'
[Unit]
Description=Daily NVIDIA driver mismatch check

[Timer]
OnBootSec=5min
OnUnitActiveSec=6h
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now nvidia-mismatch-check.timer
echo "Enabled nvidia-mismatch-check.timer (every 6h + 5min after boot)"
echo
echo "Prevention installed."
echo "  - Unattended upgrades will no longer auto-update nvidia packages."
echo "  - When you intentionally upgrade nvidia: apt upgrade && sudo fix-nvidia-mismatch.sh"
echo "    (or reboot)."
if [[ "$AUTO_FIX" == "1" ]]; then
  echo "  - Auto-fix is ON (module reload + restart GPU containers)."
else
  echo "  - Auto-fix is OFF (logs only). Re-run with --with-auto-fix to enable."
fi
