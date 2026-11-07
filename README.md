# money-manager-infra

Infrastructure stack for [money-manager-ai](https://github.com/amirkenesbay/money-manager-ai) Telegram bot.

## Stack

- **app** — money-manager-ai Spring Boot application
- **mongo** — MongoDB 8.0 with persistent volume and health check
- **web** — `ghcr.io/amirkenesbay/money-manager-webapp` (nginx + Mini App static), `/api` proxied to `app:8080`, HTTPS via Let's Encrypt

## Prerequisites

- Docker + Docker Compose plugin
- GitHub Personal Access Token with `read:packages` scope (for pulling GitHub Packages dependencies during build)

## Setup

1. Copy the env template and fill in secrets:
   ```bash
   cp .env.example .env
   nano .env
   ```

2. Build and start:
   ```bash
   docker compose up -d --build
   ```

3. Check logs:
   ```bash
   docker compose logs -f
   ```

## Environment Variables

See `.env.example` for all required variables:

| Variable | Description |
|---|---|
| `MONGO_ROOT_USERNAME` | MongoDB root user |
| `MONGO_ROOT_PASSWORD` | MongoDB root password |
| `MONGO_USERNAME` | App DB user (readWrite on moneyManagerBot) |
| `MONGO_PASSWORD` | App DB user password |
| `BOT_TOKEN` | Telegram Bot API token |
| `GEMINI_API_KEY` | Google Gemini API key for NLP |
| `GPR_USER` | GitHub username for GitHub Packages |
| `GPR_KEY` | GitHub PAT with `read:packages` scope |
| `DOMAIN` | Mini App domain, A record must point to the VPS |
| `CERTBOT_EMAIL` | Let's Encrypt account email (expiry notices) |
| `TRIBUTE_API_KEY` | Tribute API key: verifies subscription webhooks |

## Volumes

- `mongo_data` — persistent MongoDB data
- `./volumes/mongo/mongo-init.sh` — init script, creates app DB user on first start

## Backups

Daily `mongodump` is sent as a Telegram document to `ALERT_CHAT_ID` and kept locally in `./backups` (last 7).

- `scripts/backup.sh` — dump `moneyManagerBot`, gzip, send to Telegram, prune old local copies
- `scripts/restore.sh <archive.gz>` — restore a backup into the running mongo container (`--drop`)
- `scripts/install-backup-cron.sh` — install the daily cron job (03:00), run once on the VPS

On failure the backup script sends an alert message to the same chat.

## HTTPS and Mini App

1. A record of `$DOMAIN` → VPS IP; check with `dig +short $DOMAIN`
2. Set `DOMAIN` and `CERTBOT_EMAIL` in `.env`
3. `scripts/init-https.sh` — issue the first certificate (standalone, port 80 must be free) and start `web`
4. `scripts/install-renew-cron.sh` — renew twice a day via webroot, then reload nginx

Changing the domain: update `DOMAIN`, run `scripts/init-https.sh` again.

## Premium via Tribute

1. Tribute → Settings → API keys: create a key, put it into `.env` as `TRIBUTE_API_KEY`, then `docker compose up -d app`
2. Tribute → Settings → Webhooks: URL `https://$DOMAIN/api/v1/webhooks/tribute`
3. New, renewed and cancelled subscriptions switch Premium on until the date Tribute sends; the user and the alerts chat get a message

Manual control from an admin account in the bot: `/activate <user> <days>`, `/whitelist add|remove|list <user>` (Premium forever), `/blacklist add|remove|list <user>` (blocked).

## Disaster recovery (new VPS from scratch)

1. `ssh-copy-id root@NEW_IP`
2. Install Docker: `curl -fsSL https://get.docker.com | sh`
3. `git clone https://github.com/amirkenesbay/money-manager-infra.git /opt/money-manager`
4. Copy `.env` to `/opt/money-manager/.env` (keep a local copy of it!)
5. `docker login ghcr.io -u $GPR_USER` with `$GPR_KEY`
6. `docker compose up -d`
7. Download the latest `mongo_*.archive.gz` from the Telegram backup chat, `scp` it to the VPS and run `scripts/restore.sh <archive>`
8. `scripts/install-backup-cron.sh`
8a. `scripts/init-https.sh` and `scripts/install-renew-cron.sh`
9. Update GitHub Actions secrets in this repo: `SSH_HOST`, `SSH_KNOWN_HOSTS` (`ssh-keyscan NEW_IP`), `SSH_PRIVATE_KEY`, `SSH_USER`