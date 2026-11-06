#!/usr/bin/env bash
# Install the twice-daily certificate renewal cron job. Run once on the VPS as root.
set -euo pipefail

CRON_FILE="/etc/cron.d/money-manager-renew-https"

cat > "$CRON_FILE" <<'CRON'
17 4,16 * * * root /opt/money-manager/scripts/renew-https.sh >> /var/log/money-manager-renew-https.log 2>&1
CRON
chmod 644 "$CRON_FILE"

echo "✅ Cron installed: $CRON_FILE (04:17 and 16:17)"
