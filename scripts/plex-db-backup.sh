#!/usr/bin/env bash
# Offline-safe backup + integrity check for Plex SQLite databases.
# Uses Plex's own SQLite binary (system sqlite cannot open ICU collations).
#
# Usage:
#   ./scripts/plex-db-backup.sh                  # backup + integrity check
#   ./scripts/plex-db-backup.sh --check-only
#   ./scripts/plex-db-backup.sh --repair         # run DBRepair auto (Plex must be stopped)
#
# Env:
#   PLEX_CONFIG_DIR   default: /data/appdata/plex
#   PLEX_BACKUP_ROOT  default: /data/appdata/plex-backups
#   KEEP_DAYS         default: 14

set -euo pipefail

PLEX_CONFIG_DIR="${PLEX_CONFIG_DIR:-/data/appdata/plex}"
PLEX_BACKUP_ROOT="${PLEX_BACKUP_ROOT:-/data/appdata/plex-backups}"
KEEP_DAYS="${KEEP_DAYS:-14}"
DBDIR="${PLEX_CONFIG_DIR}/Library/Application Support/Plex Media Server/Plug-in Support/Databases"
MAIN_DB="${DBDIR}/com.plexapp.plugins.library.db"
BLOBS_DB="${DBDIR}/com.plexapp.plugins.library.blobs.db"
IMAGE="${PLEX_IMAGE:-lscr.io/linuxserver/plex:latest}"
MODE="${1:---backup}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

need_files() {
  [[ -f "$MAIN_DB" && -f "$BLOBS_DB" ]] || {
    log "ERROR: databases not found under $DBDIR"
    exit 1
  }
}

plex_running() {
  docker inspect -f '{{.State.Running}}' plex 2>/dev/null | grep -qx true
}

run_plex_sqlite() {
  # $1 = sql or special; operates inside container with Plex SQLite
  docker run --rm --runtime=runc --entrypoint '' \
    -v "${PLEX_CONFIG_DIR}:/config" \
    "$IMAGE" \
    bash -c '
      PSQ="/usr/lib/plexmediaserver/Plex SQLite"
      DB="/config/Library/Application Support/Plex Media Server/Plug-in Support/Databases"
      case "'"$1"'" in
        integrity)
          echo -n "main="; "$PSQ" "$DB/com.plexapp.plugins.library.db" "PRAGMA integrity_check(1);"
          echo -n "blobs="; "$PSQ" "$DB/com.plexapp.plugins.library.blobs.db" "PRAGMA integrity_check(1);"
          ;;
        counts)
          "$PSQ" "$DB/com.plexapp.plugins.library.db" \
            "SELECT COUNT(*) AS metadata_items FROM metadata_items;
             SELECT COUNT(*) AS media_items FROM media_items;
             SELECT COUNT(*) AS media_parts FROM media_parts;"
          ;;
      esac
    '
}

do_check() {
  need_files
  log "Integrity check (Plex SQLite)..."
  local out
  out="$(run_plex_sqlite integrity)"
  echo "$out"
  if echo "$out" | grep -qv '=ok$'; then
    log "INTEGRITY FAILURE"
    return 1
  fi
  log "Integrity OK"
  run_plex_sqlite counts || true
  return 0
}

do_backup() {
  need_files
  local ts dest
  ts="$(date +%Y-%m-%d_%H.%M.%S)"
  dest="${PLEX_BACKUP_ROOT}/auto-${ts}"
  mkdir -p "${dest}/Databases"

  log "Backing up to $dest"
  # Prefer consistent copy: if Plex is running, still copy (SQLite WAL may be active).
  # Best results when Plex is stopped; we snapshot WAL/SHM if present.
  cp -a "$MAIN_DB" "$BLOBS_DB" "${dest}/Databases/"
  cp -a "${MAIN_DB}-wal" "${MAIN_DB}-shm" "${BLOBS_DB}-wal" "${BLOBS_DB}-shm" \
    "${dest}/Databases/" 2>/dev/null || true
  if [[ -f "${PLEX_CONFIG_DIR}/Library/Application Support/Plex Media Server/Preferences.xml" ]]; then
    cp -a "${PLEX_CONFIG_DIR}/Library/Application Support/Plex Media Server/Preferences.xml" "$dest/"
  fi
  (cd "${dest}/Databases" && sha256sum com.plexapp.plugins.library.db com.plexapp.plugins.library.blobs.db >SHA256SUMS)
  du -sh "$dest" | awk '{print "Backup size: "$1}'
  log "Pruning backups older than ${KEEP_DAYS} days under $PLEX_BACKUP_ROOT"
  find "$PLEX_BACKUP_ROOT" -maxdepth 1 -type d \( -name 'auto-*' -o -name 'manual-*' \) -mtime +"${KEEP_DAYS}" -exec rm -rf {} + 2>/dev/null || true
  log "Backup complete: $dest"
}

do_repair() {
  need_files
  if plex_running; then
    log "ERROR: Plex is running. Stop it first: docker stop plex"
    exit 1
  fi
  if [[ ! -x "${PLEX_CONFIG_DIR}/DBRepair.sh" ]]; then
    log "Fetching ChuckPa DBRepair.sh..."
    curl -fsSL -o "${PLEX_CONFIG_DIR}/DBRepair.sh" \
      https://raw.githubusercontent.com/ChuckPa/PlexDBRepair/master/DBRepair.sh
    chmod +x "${PLEX_CONFIG_DIR}/DBRepair.sh"
  fi
  log "Running DBRepair auto (export/import/reindex)..."
  docker run --rm --runtime=runc --entrypoint '' \
    -v "${PLEX_CONFIG_DIR}:/config" \
    -w /config \
    "$IMAGE" \
    bash /config/DBRepair.sh auto exit
  chown -R 1000:1000 "${PLEX_CONFIG_DIR}/Library" 2>/dev/null || true
  do_check
}

case "$MODE" in
  --check-only|--check) do_check ;;
  --repair) do_backup; do_repair ;;
  --backup|"") do_backup; do_check || { log "WARNING: backup taken but integrity failed — run --repair after stopping Plex"; exit 1; } ;;
  *)
    echo "Usage: $0 [--backup|--check-only|--repair]"
    exit 2
    ;;
esac
