#!/usr/bin/env bash
# Renew Let's Encrypt certificates that expire soon and reload nginx.
set -euo pipefail

cd /opt/money-manager
docker run --rm \
  -v "$PWD/certbot/conf:/etc/letsencrypt" \
  -v "$PWD/certbot/www:/var/www/certbot" \
  certbot/certbot renew --webroot -w /var/www/certbot --quiet
docker compose exec -T web nginx -s reload
