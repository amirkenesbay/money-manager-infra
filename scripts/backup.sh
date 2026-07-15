#!/usr/bin/env bash
# Daily MongoDB backup: mongodump -> gzip archive -> send to Telegram (ALERT_CHAT_ID).
# Keeps the last KEEP_LAST archives locally in ./backups as a secondary copy.
set -euo pipefail

cd "$(dirname "$0")/.."
set -a; . ./.env; set +a

BACKUP_DIR="backups"
KEEP_LAST=7
DB_NAME="moneyManagerBot"
STAMP="$(date +%Y-%m-%d_%H-%M)"
FILE="$BACKUP_DIR/mongo_${STAMP}.archive.gz"

mkdir -p "$BACKUP_DIR"

notify() {
  curl -fsS -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d chat_id="${ALERT_CHAT_ID}" -d text="$1" >/dev/null
}

trap 'notify "❌ Mongo backup failed on $(hostname) at ${STAMP}"' ERR

docker exec money-manager-mongo mongodump \
  --username "${MONGO_ROOT_USERNAME}" \
  --password "${MONGO_ROOT_PASSWORD}" \
  --authenticationDatabase admin \
  --db "$DB_NAME" \
  --archive --gzip --quiet > "$FILE"

SIZE="$(du -h "$FILE" | cut -f1)"

curl -fsS -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendDocument" \
  -F chat_id="${ALERT_CHAT_ID}" \
  -F document=@"$FILE" \
  -F caption="🗄 Mongo backup ${STAMP} (${SIZE})" >/dev/null

# prune local copies beyond KEEP_LAST
ls -1t "$BACKUP_DIR"/mongo_*.archive.gz | tail -n +$((KEEP_LAST + 1)) | xargs -r rm --
