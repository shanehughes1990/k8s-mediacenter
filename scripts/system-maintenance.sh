#!/usr/bin/env bash
# Weekly (or on-demand) host maintenance:
#   - full apt update/upgrade (including nvidia packages held back from daily unattended)
#   - autoremove unused packages
#   - reboot into clean kernel/modules so the mediacenter stack starts healthy
#
# Invoked by systemd timer: system-maintenance.timer (Mon 04:00 America/Toronto)

set -euo pipefail

LOG_TAG="system-maintenance"
REBOOT="${REBOOT:-1}"
export DEBIAN_FRONTEND=noninteractive

log() { logger -t "$LOG_TAG" "$*"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

log "=== system maintenance start ==="

# Snapshot pending reboot state
if [[ -f /var/run/reboot-required ]]; then
  log "reboot already required before upgrade: $(tr '\n' ' ' </var/run/reboot-required.pkgs 2>/dev/null || true)"
fi

log "apt-get update"
apt-get update -y

log "apt-get upgrade (full, including packages blacklisted from daily unattended)"
# Allow nvidia to upgrade here — weekly reboot applies the new kernel module cleanly.
apt-get -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  upgrade

log "apt-get dist-upgrade"
apt-get -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  dist-upgrade

log "apt-get autoremove --purge"
apt-get -y autoremove --purge

log "apt-get autoclean"
apt-get -y autoclean

# Refresh docker images for the stack (best-effort; Watchtower also handles this)
COMPOSE_DIR="${COMPOSE_DIR:-/data/workspace/k8s-mediacenter}"
if [[ -f "${COMPOSE_DIR}/docker-compose.yml" ]] && command -v docker &>/dev/null; then
  log "docker compose pull (best-effort)"
  docker compose -f "${COMPOSE_DIR}/docker-compose.yml" --project-directory "$COMPOSE_DIR" pull --ignore-pull-failures 2>&1 | tail -30 || true
fi

log "=== system maintenance packages done ==="

if [[ "$REBOOT" == "1" ]]; then
  log "rebooting in 30s for clean kernel/module load (cancel: systemctl stop system-maintenance.service)"
  # Write a flag so boot logs can correlate
  echo "$(date -Is) system-maintenance reboot" >> /var/log/system-maintenance-reboot.log
  sleep 30
  systemctl reboot
else
  log "REBOOT=0 set; skipping reboot"
fi
