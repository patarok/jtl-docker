# JTL-Shop Docker Development Environment

A Docker-based local development environment for JTL-Shop, featuring PHP/Apache, MariaDB, Redis, phpMyAdmin and MailDev.

## Services

| Service | Image | Port |
|---|---|---|
| JTL-Shop (PHP/Apache) | custom build | `80` |
| MariaDB | `mariadb:10.11` | `3306` |
| Redis | `redis:7-alpine` | `6379` |
| phpMyAdmin | `phpmyadmin` | `8080` |
| MailDev | `maildev/maildev` | `1080` |

## Requirements

- Docker & Docker Compose
- A JTL-Shop license and valid `JTL_VERSION` build number

## Project Structure

```
.
├── docker/
│   └── web/
│       ├── Dockerfile
│       ├── entrypoint.sh
│       ├── php.ini
│       └── xdebug.ini
├── src/                    # Shop source — populated on first start
│   ├── plugins/            # Your custom plugins (tracked in git)
│   ├── templates/          # Your custom templates (tracked in git)
│   └── mediafiles/         # Media — static embeds tracked, runtime files ignored
├── .env                    # Local environment config (not in git)
├── .env.example            # Template for .env (in git)
├── docker-compose.yml
└── README.md
```

## Setup

**1. Clone the repository**
```bash
git clone <repo-url>
cd <repo>
```

**2. Create your `.env` file**
```bash
cp .env.example .env
```

Then edit `.env` with your values:
```ini
# PHP & JTL versions
PHP_VERSION=8.2
JTL_VERSION=5.3.0         # check https://build.jtl-shop.de for available versions

# Database
MYSQL_ROOT_PASSWORD=secret
MYSQL_USER=jtlshop
MYSQL_PASSWORD=secret
MYSQL_DATABASE=jtlshop

# Host user ID — prevents permission issues on bind mount
# Run: id -u
UID=1000
```

**3. Build and start**
```bash
docker compose up -d --build
```

On first start the entrypoint will automatically populate `./src` with the JTL-Shop core files. Subsequent starts skip this step and use your existing `./src` directly.

**4. Complete the shop installation**

Open [http://localhost](http://localhost) and follow the JTL-Shop installer. Use these database credentials:

| Field | Value |
|---|---|
| Host | `jtl-db` |
| Database | value of `MYSQL_DATABASE` |
| User | value of `MYSQL_USER` |
| Password | value of `MYSQL_PASSWORD` |

## Development

### Editing shop files
`./src` is bind-mounted into the container, so any changes you make locally are reflected immediately — no rebuild needed.

### Custom plugins
Place your plugins under `./src/plugins/`. They are tracked in git and will persist across shop updates.

### Custom templates
Place your templates under `./src/templates/`. They are tracked in git and will persist across shop updates.

### PHP configuration
Edit `./docker/web/php.ini` and restart the container:
```bash
docker compose restart jtl-shop
```

### Xdebug
Xdebug is pre-installed and configured via `./docker/web/xdebug.ini`. Configure your IDE to listen on port `9003`.

### Mail
All outgoing mail is caught by MailDev. Open [http://localhost:1080](http://localhost:1080) to view sent emails — nothing reaches the internet.

### Database
Access phpMyAdmin at [http://localhost:8080](http://localhost:8080) or connect directly via any MySQL client on `localhost:3306`.

## Useful Commands

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# Rebuild the shop image (e.g. after PHP or JTL version change)
docker compose up -d --build

# View shop logs
docker compose logs -f jtl-shop

# Open a shell in the shop container
docker compose exec jtl-shop bash

# Reset the database volume
docker compose down -v
```

## Permissions

The shop container runs as your host user (`UID` from `.env`) with group `www-data` (GID `33`). This means:

- You can edit files in `./src` freely without `sudo`
- Apache can read all files and write to runtime directories (`cache/`, `templates_c/`, `uploads/`, etc.)