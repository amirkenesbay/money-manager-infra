#!/usr/bin/env bash
# Restore MongoDB from a backup archive produced by backup.sh.
# Usage: ./scripts/restore.sh <mongo_YYYY-MM-DD_HH-MM.archive.gz>
# WARNING: --drop replaces existing collections with the archive contents.
set -euo pipefail

[ $# -eq 1 ] || { echo "Usage: $0 <mongo_backup.archive.gz>"; exit 1; }
[ -f "$1" ] || { echo "File not found: $1"; exit 1; }
ARCHIVE="$(realpath "$1")"

cd "$(dirname "$0")/.."
set -a; . ./.env; set +a

docker exec -i money-manager-mongo mongorestore \
  --username "${MONGO_ROOT_USERNAME}" \
  --password "${MONGO_ROOT_PASSWORD}" \
  --authenticationDatabase admin \
  --archive --gzip --drop < "$ARCHIVE"

echo "✅ Restore complete"
