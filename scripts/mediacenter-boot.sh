#!/usr/bin/env bash
# Bring the mediacenter stack (and host GPU drivers) up cleanly after boot or maintenance.
# Intended to run as root via systemd: mediacenter.service

set -euo pipefail

COMPOSE_DIR="${COMPOSE_DIR:-/data/workspace/k8s-mediacenter}"
COMPOSE_FILE="${COMPOSE_FILE:-${COMPOSE_DIR}/docker-compose.yml}"
LOG_TAG="mediacenter-boot"
MAX_WAIT_DOCKER=120
MAX_WAIT_NVIDIA=60

log() { logger -t "$LOG_TAG" "$*"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

wait_for_docker() {
  local i=0
  until docker info &>/dev/null; do
    i=$((i + 1))
    if (( i >= MAX_WAIT_DOCKER )); then
      log "ERROR: docker not ready after ${MAX_WAIT_DOCKER}s"
      return 1
    fi
    sleep 1
  done
  log "docker is ready"
}

ensure_nvidia() {
  # If no nvidia tools, skip (non-GPU hosts)
  if ! command -v nvidia-smi &>/dev/null && [[ ! -e /dev/nvidiactl ]]; then
    log "no NVIDIA device/tools; skipping GPU check"
    return 0
  fi

  local i=0
  # Give udev/modules a moment after boot
  while (( i < MAX_WAIT_NVIDIA )); do
    if nvidia-smi &>/dev/null; then
      log "nvidia-smi OK: $(nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null | head -1)"
      return 0
    fi
    i=$((i + 1))
    sleep 1
  done

  log "nvidia-smi failed; attempting module reload via fix-nvidia-mismatch.sh"
  if [[ -x /usr/local/sbin/fix-nvidia-mismatch.sh ]]; then
    /usr/local/sbin/fix-nvidia-mismatch.sh --fix || true
  elif [[ -x "${COMPOSE_DIR}/scripts/fix-nvidia-mismatch.sh" ]]; then
    bash "${COMPOSE_DIR}/scripts/fix-nvidia-mismatch.sh" --fix || true
  fi

  if nvidia-smi &>/dev/null; then
    log "nvidia recovered after fix"
    return 0
  fi
  log "WARNING: NVIDIA still unhealthy — Plex may fail to start (runtime=nvidia)"
  return 0
}

start_stack() {
  if [[ ! -f "$COMPOSE_FILE" ]]; then
    log "ERROR: compose file not found: $COMPOSE_FILE"
    return 1
  fi
  log "docker compose up -d --remove-orphans"
  # shellcheck disable=SC2086
  docker compose -f "$COMPOSE_FILE" --project-directory "$COMPOSE_DIR" up -d --remove-orphans

  # One-shot init containers (restart: no) need an explicit run after postgres is healthy
  if docker compose -f "$COMPOSE_FILE" --project-directory "$COMPOSE_DIR" config --services 2>/dev/null | grep -qx postgresql-init; then
    log "waiting for postgresql healthy, then running postgresql-init"
    local i=0
    until docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' postgresql 2>/dev/null | grep -Eq 'healthy|running'; do
      i=$((i + 1))
      (( i > 60 )) && break
      sleep 2
    done
    docker compose -f "$COMPOSE_FILE" --project-directory "$COMPOSE_DIR" up -d postgresql-init || true
  fi
}

report_status() {
  log "stack status:"
  docker compose -f "$COMPOSE_FILE" --project-directory "$COMPOSE_DIR" ps -a --format 'table {{.Name}}\t{{.Status}}' 2>/dev/null \
    | while read -r line; do log "  $line"; done || true

  local bad
  bad="$(docker compose -f "$COMPOSE_FILE" --project-directory "$COMPOSE_DIR" ps -a --format '{{.Name}} {{.Status}}' 2>/dev/null \
    | grep -viE ' Up |Exited \(0\)' || true)"
  if [[ -n "$bad" ]]; then
    log "WARNING: non-ready services:"
    while read -r line; do [[ -n "$line" ]] && log "  $line"; done <<<"$bad"
    return 1
  fi
  log "all compose services are Up or clean one-shot exit"
  return 0
}

main() {
  log "starting mediacenter boot sequence"
  wait_for_docker
  ensure_nvidia
  start_stack
  # Give containers a moment to settle before status check
  sleep 10
  report_status || true
  log "boot sequence finished"
}

main "$@"
