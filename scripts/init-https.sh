#!/usr/bin/env bash
# Issue the first Let's Encrypt certificate for $DOMAIN and start nginx. Run once on the VPS as root.
set -euo pipefail

cd /opt/money-manager
set -a; . ./.env; set +a
: "${DOMAIN:?DOMAIN is not set in .env}"

mkdir -p certbot/conf certbot/www
docker compose stop web 2>/dev/null || true

docker run --rm -p 80:80 \
  -v "$PWD/certbot/conf:/etc/letsencrypt" \
  certbot/certbot certonly --standalone \
  -d "$DOMAIN" -d "www.$DOMAIN" -d "grafana.$DOMAIN" \
  ${CERTBOT_EMAIL:+--email "$CERTBOT_EMAIL"} ${CERTBOT_EMAIL:---register-unsafely-without-email} --agree-tos --non-interactive --keep-until-expiring --expand

docker compose up -d web
echo "✅ HTTPS ready: https://$DOMAIN"
