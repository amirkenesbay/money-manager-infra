# money-manager-infra

Infrastructure stack for [money-manager-ai](https://github.com/amirkenesbay/money-manager-ai) Telegram bot.

## Stack

- **app** — money-manager-ai Spring Boot application
- **mongo** — MongoDB 8.0 with persistent volume and health check

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

## Volumes

- `mongo_data` — persistent MongoDB data
- `./volumes/mongo/mongo-init.sh` — init script, creates app DB user on first start

## Backups

Daily `mongodump` is sent as a Telegram document to `ALERT_CHAT_ID` and kept locally in `./backups` (last 7).

- `scripts/backup.sh` — dump `moneyManagerBot`, gzip, send to Telegram, prune old local copies
- `scripts/restore.sh <archive.gz>` — restore a backup into the running mongo container (`--drop`)
- `scripts/install-backup-cron.sh` — install the daily cron job (03:00), run once on the VPS

On failure the backup script sends an alert message to the same chat.

## Disaster recovery (new VPS from scratch)

1. `ssh-copy-id root@NEW_IP`
2. Install Docker: `curl -fsSL https://get.docker.com | sh`
3. `git clone https://github.com/amirkenesbay/money-manager-infra.git /opt/money-manager`
4. Copy `.env` to `/opt/money-manager/.env` (keep a local copy of it!)
5. `docker login ghcr.io -u $GPR_USER` with `$GPR_KEY`
6. `docker compose up -d`
7. Download the latest `mongo_*.archive.gz` from the Telegram backup chat, `scp` it to the VPS and run `scripts/restore.sh <archive>`
8. `scripts/install-backup-cron.sh`
9. Update GitHub Actions secrets in this repo: `SSH_HOST`, `SSH_KNOWN_HOSTS` (`ssh-keyscan NEW_IP`), `SSH_PRIVATE_KEY`, `SSH_USER`