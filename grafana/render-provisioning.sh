#!/bin/sh
set -eu

source_dir=/etc/grafana/provisioning-src
target_dir="$GF_PATHS_PROVISIONING"

rm -rf "$target_dir"
mkdir -p "$target_dir"
cp -R "$source_dir"/. "$target_dir"/
sed -i \
  -e "s|__TELEGRAM_BOT_TOKEN__|$TELEGRAM_BOT_TOKEN|" \
  -e "s|__TELEGRAM_ALERT_CHAT_ID__|$TELEGRAM_ALERT_CHAT_ID|" \
  "$target_dir/alerting/alerting.yml"

exec /run.sh "$@"
