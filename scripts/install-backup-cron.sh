#!/usr/bin/env bash
# Install the daily backup cron job (03:00 server time). Run once on the VPS as root.
set -euo pipefail

CRON_FILE="/etc/cron.d/money-manager-backup"

cat > "$CRON_FILE" <<'EOF'
0 3 * * * root /opt/money-manager/scripts/backup.sh >> /var/log/money-manager-backup.log 2>&1
EOF
chmod 644 "$CRON_FILE"

echo "✅ Cron installed: $CRON_FILE (daily at 03:00)"
