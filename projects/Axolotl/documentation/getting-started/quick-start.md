# Quick Start Guide

Get the Axolotl Football Analysis Platform up and running in minutes using Docker.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed (version 20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) installed (version 2.0+)
- At least 4GB of free RAM
- At least 10GB of free disk space

## One-Line Quick Start

The fastest way to get started:

```bash
./scripts/local_dev_up.sh
```

This script will:
1. Create `.env` file if missing (with SQLite default)
2. Create required directories (logs, storage, data)
3. Build Docker images
4. Start all services
5. Make the app available at **http://localhost:8080**

## Manual Setup (3 Steps)

If you prefer manual control:

### Step 1: Set Up Environment

```bash
# Copy environment template
cp .env.example .env

# Edit if needed (defaults work for local development)
nano .env
```

### Step 2: Start Services

```bash
# Start all services with Docker Compose
docker compose up -d

# View logs (optional)
docker compose logs -f
```

### Step 3: Access the Application

Open your browser and navigate to:
- **Web Application**: http://localhost:8080
- **Health Check**: http://localhost:8080/health

## Services Overview

The platform runs these services:

| Service | Description | Port | URL |
|---------|-------------|------|-----|
| Web | Flask application (frontend + API) | 8080 | http://localhost:8080 |
| Worker | Background task processor | - | - |
| Redis | Task queue and caching | 6379 | redis://localhost:6379 |
| PostgreSQL | Database (optional) | 5432 | postgres://localhost:5432 |

## Using PostgreSQL (Optional)

By default, the app uses SQLite. To use PostgreSQL instead:

```bash
# Start with PostgreSQL profile
docker compose --profile postgres up -d
```

Update your `.env` file:
```bash
DATABASE_URL=postgresql://axolotl:axolotl@postgres:5432/axolotl
```

## Common Commands

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f web
docker compose logs -f worker
```

### Stop Services
```bash
# Stop all services (keep data)
docker compose down

# Stop and remove all data
docker compose down -v
```

### Restart After Code Changes
```bash
# Rebuild and restart
docker compose up --build -d
```

### Access Container Shell
```bash
# Web container
docker compose exec web bash

# Worker container
docker compose exec worker bash
```

## Verify Installation

Check that everything is working:

```bash
# Check service status
docker compose ps

# Test health endpoint
curl http://localhost:8080/health

# Should return: {"status":"ok"}
```

## What's Next?

- **Upload a video**: Navigate to the web interface and try analyzing a football video
- **Explore the API**: Check out the [API Reference](../architecture/api-reference.md)
- **Configure Azure services**: See [Configuration Guide](configuration.md)
- **Develop features**: Read the [Contributing Guide](../development/contributing.md)

## Troubleshooting

### Port 8080 Already in Use

```bash
# Find what's using the port
lsof -i :8080

# Or change the port in .env
PORT=8081
```

### Container Won't Start

```bash
# View detailed error logs
docker compose logs web

# Force recreate containers
docker compose down
docker compose up --force-recreate
```

### Build Failures

```bash
# Clean build without cache
docker compose build --no-cache

# Remove all and rebuild
docker compose down --rmi all
docker compose build
```

### Permission Errors

```bash
# Fix ownership of data directories
sudo chown -R $(id -u):$(id -g) logs/ storage/ data/
```

## Development Without Docker

For local development without Docker:

### Linux/Mac
```bash
# Development mode (auto-reload)
./scripts/start.sh --dev

# Production mode
./scripts/start.sh --prod
```

### Windows
```powershell
# Development mode
.\scripts\start.ps1 -Mode dev

# Production mode
.\scripts\start.ps1 -Mode prod
```

See the [Installation Guide](installation.md) for detailed manual setup instructions.

## Need Help?

- **Issues**: Check [Troubleshooting](troubleshooting.md)
- **Configuration**: See [Configuration Guide](configuration.md)
- **Architecture**: Read [System Overview](../architecture/overview.md)
- **Community**: Open an issue on [GitHub](https://github.com/THEDIFY/axolotl/issues)
