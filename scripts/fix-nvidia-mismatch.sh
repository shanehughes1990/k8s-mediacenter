#!/usr/bin/env bash
# Fix NVIDIA kernel/userspace version mismatch without a full reboot when possible.
# Root cause: unattended-upgrades updates nvidia-* packages and rebuilds DKMS,
# but the *loaded* kernel module stays on the old version until unload/reload or reboot.
#
# Usage:
#   sudo ./scripts/fix-nvidia-mismatch.sh           # diagnose + reload modules
#   sudo ./scripts/fix-nvidia-mismatch.sh --reboot   # full reboot if preferred
#   sudo ./scripts/fix-nvidia-mismatch.sh --check    # diagnose only

set -euo pipefail

MODE="${1:---fix}"

loaded_version() {
  if [[ -r /proc/driver/nvidia/version ]]; then
    awk '/NVRM version/{print $8; exit}' /proc/driver/nvidia/version
  else
    echo "none"
  fi
}

installed_version() {
  # Prefer userspace lib version (what nvidia-smi / container toolkit use)
  if [[ -e /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 ]]; then
    readlink -f /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 \
      | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | tail -1
  elif modinfo nvidia &>/dev/null; then
    modinfo -F version nvidia
  else
    echo "unknown"
  fi
}

diagnose() {
  local loaded installed
  loaded="$(loaded_version)"
  installed="$(installed_version)"
  echo "=== NVIDIA driver status ==="
  echo "Loaded kernel module (NVRM): ${loaded}"
  echo "Installed userspace/DKMS:    ${installed}"
  echo "Running kernel:              $(uname -r)"
  if [[ -f /var/run/reboot-required ]]; then
    echo "Reboot required:             YES ($(tr '\n' ' ' </var/run/reboot-required.pkgs 2>/dev/null || true))"
  else
    echo "Reboot required:             no"
  fi
  if command -v nvidia-smi &>/dev/null; then
    if nvidia-smi &>/dev/null; then
      echo "nvidia-smi:                  OK"
      nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null || true
    else
      echo "nvidia-smi:                  FAIL ($(nvidia-smi 2>&1 | head -1))"
    fi
  fi
  if [[ "$loaded" != "none" && "$installed" != "unknown" && "$loaded" != "$installed" ]]; then
    echo "STATUS: MISMATCH — containers using runtime=nvidia will fail to start"
    return 1
  elif [[ "$loaded" == "none" ]]; then
    echo "STATUS: module not loaded"
    return 1
  else
    echo "STATUS: OK"
    return 0
  fi
}

stop_gpu_containers() {
  echo "=== Stopping containers that use the nvidia runtime ==="
  local ids
  ids="$(docker ps -q --filter 'status=running' 2>/dev/null || true)"
  [[ -z "$ids" ]] && return 0
  while read -r id; do
    [[ -z "$id" ]] && continue
    runtime="$(docker inspect -f '{{.HostConfig.Runtime}}' "$id" 2>/dev/null || true)"
    name="$(docker inspect -f '{{.Name}}' "$id" 2>/dev/null | sed 's#^/##')"
    if [[ "$runtime" == "nvidia" ]]; then
      echo "  stopping $name (runtime=nvidia)"
      docker stop "$name" || true
    fi
  done <<<"$ids"
}

reload_modules() {
  echo "=== Reloading NVIDIA kernel modules ==="
  # Unload dependents first
  for m in nvidia_uvm nvidia_drm nvidia_modeset nvidia; do
    if lsmod | awk '{print $1}' | grep -qx "$m"; then
      echo "  rmmod $m"
      rmmod "$m" || {
        echo "ERROR: could not unload $m (still in use?). Try --reboot."
        lsmod | grep -i nvidia || true
        fuser -v /dev/nvidia* 2>&1 || true
        exit 1
      }
    fi
  done
  sleep 1
  echo "  modprobe nvidia"
  modprobe nvidia
  modprobe nvidia_uvm 2>/dev/null || true
  modprobe nvidia_modeset 2>/dev/null || true
  modprobe nvidia_drm 2>/dev/null || true
  sleep 1
}

start_plex() {
  echo "=== Starting Plex ==="
  local compose="/data/workspace/k8s-mediacenter"
  if [[ -f "$compose/docker-compose.yml" ]]; then
    (cd "$compose" && docker compose up -d plex)
  else
    docker start plex 2>/dev/null || docker compose -f /data/workspace/k8s-mediacenter/docker-compose.yml up -d plex
  fi
  sleep 3
  docker ps --filter name=^plex$ --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
}

if [[ "$(id -u)" -ne 0 && "$MODE" != "--check" ]]; then
  echo "This script needs root for --fix/--reboot. Re-run with sudo."
  exit 2
fi

case "$MODE" in
  --check)
    diagnose || true
    exit 0
    ;;
  --reboot)
    diagnose || true
    echo "Rebooting in 5s (Ctrl+C to abort)..."
    sleep 5
    systemctl reboot
    ;;
  --fix|"")
    if diagnose; then
      echo "No mismatch detected; ensuring Plex is up."
      start_plex || true
      exit 0
    fi
    stop_gpu_containers
    reload_modules
    if ! diagnose; then
      echo "Module reload did not fully clear the mismatch. A reboot is required:"
      echo "  sudo $0 --reboot"
      exit 1
    fi
    start_plex
    echo "Done."
    ;;
  *)
    echo "Usage: $0 [--check|--fix|--reboot]"
    exit 2
    ;;
esac
