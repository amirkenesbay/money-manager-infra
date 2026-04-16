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