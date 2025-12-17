# Docker Setup for Axolotl Football Analysis Platform

This document provides comprehensive instructions for running the Axolotl Football Analysis Platform using Docker.

## Quick Start

The fastest way to get started:

```bash
./scripts/local_dev_up.sh
```

This script will:
- Create `.env` file if missing (with SQLite default)
- Create required directories (logs, storage, data)
- Build Docker images
- Start all services
- Run migrations (when configured)
- Make the app available at http://localhost:8080

## Services

The platform consists of the following services:

### Web Service
- **Description**: Main Flask application serving frontend and API
- **Port**: 8080
- **URL**: http://localhost:8080
- **Health Check**: http://localhost:8080/health

### Worker Service
- **Description**: Background task processor for heavy GPU operations
- **Command**: `python app/backend/worker.py`
- **Used for**: SMPL body fitting, video processing, analysis tasks

### Redis
- **Description**: Task queue and caching layer
- **Port**: 6379
- **Data**: Persisted in `redis-data` volume

### PostgreSQL (Optional)
- **Description**: Production database (SQLite used by default)
- **Port**: 5432
- **Credentials**: axolotl/axolotl (configurable via environment)
- **Enable**: Add `--profile postgres` to docker compose commands

## Architecture

### Multi-Stage Dockerfile

The production Dockerfile (`docker/Dockerfile.prod`) uses a multi-stage build:

1. **Stage 1: Frontend Builder**
   - Base: `node:20-alpine`
   - Builds React/Vite frontend
   - Output: Static files to `app/backend/static`

2. **Stage 2: Python Builder**
   - Base: `python:3.11-slim`
   - Installs Python dependencies
   - Creates packages in user directory

3. **Stage 3: Production**
   - Base: `python:3.11-slim`
   - Minimal runtime dependencies
   - Non-root user (appuser, UID 1000)
   - Copies frontend build and Python packages
   - Runs Gunicorn on port 8080

### Database Configuration

**Default: SQLite**
```bash
DATABASE_URL=sqlite:///data/axolotl.db
```

**PostgreSQL (Production)**
```bash
DATABASE_URL=postgresql://axolotl:axolotl@postgres:5432/axolotl
```

Enable PostgreSQL:
```bash
docker compose --profile postgres up -d
```

## Commands

### Starting Services

```bash
# Start with SQLite (default)
docker compose up -d

# Start with PostgreSQL
docker compose --profile postgres up -d

# Start with build (after code changes)
docker compose up --build

# Start and view logs
docker compose up
```

### Viewing Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f web
docker compose logs -f worker

# Last 100 lines
docker compose logs --tail=100 web
```

### Stopping Services

```bash
# Stop all services (keep volumes)
docker compose down

# Stop and remove volumes
docker compose down -v

# Stop specific service
docker compose stop web
```

### Service Management

```bash
# Restart a service
docker compose restart web

# Execute command in container
docker compose exec web bash
docker compose exec web python -c "print('Hello')"

# View running services
docker compose ps

# View service resource usage
docker stats
```

### Building

```bash
# Build all services
docker compose build

# Build specific service
docker compose build web

# Build without cache
docker compose build --no-cache

# Build production image directly
docker build -f docker/Dockerfile.prod -t axolotl-app:latest .
```

## Environment Variables

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

### Required Variables

```bash
# Database (SQLite default for local dev)
DATABASE_URL=sqlite:///data/axolotl.db

# Redis
REDIS_URL=redis://redis:6379/0

# Application
FLASK_ENV=development
PORT=8080
```

### Optional Azure Variables

```bash
# Azure OpenAI
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-key
AZURE_OPENAI_API_VERSION=2024-02-15-preview
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4

# Azure Search
AZURE_SEARCH_ENDPOINT=https://your-search.search.windows.net
AZURE_SEARCH_KEY=your-key
AZURE_SEARCH_INDEX=football-analysis

# Azure Storage
AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;...
AZURE_STORAGE_CONTAINER=football-videos

# Azure Key Vault
AZURE_KEYVAULT_URL=https://your-vault.vault.azure.net/

# Cosmos DB
COSMOS_CONNECTION_STRING=AccountEndpoint=https://...
```

## Volumes

Docker volumes persist data across container restarts:

- **redis-data**: Redis cache and queue data
- **postgres-data**: PostgreSQL database (when using postgres profile)
- **web-data**: Application data for web service
- **worker-data**: Application data for worker service

Host directories:
- **./logs**: Application logs (mounted from host)
- **./storage**: File storage (mounted from host)
- **./data**: Database and data files (mounted from host)

## Native Start Scripts

For development without Docker:

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

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 8080
lsof -i :8080

# Or use netstat
netstat -tlnp | grep 8080

# Kill the process
kill -9 <PID>
```

### Container Won't Start

```bash
# View detailed logs
docker compose logs web

# Check container status
docker compose ps

# Inspect container
docker inspect axolotl-web

# Remove and recreate
docker compose down
docker compose up --force-recreate
```

### Build Failures

```bash
# Clean build without cache
docker compose build --no-cache

# Remove all images and rebuild
docker compose down --rmi all
docker compose build
docker compose up
```

### Database Connection Issues

```bash
# Check database is running
docker compose ps postgres

# Check database logs
docker compose logs postgres

# Reset database
docker compose down -v
docker compose up -d
```

### Permission Issues

```bash
# Fix ownership of mounted volumes
sudo chown -R $(id -u):$(id -g) logs/ storage/ data/

# Or run with user ID
docker compose run --user $(id -u):$(id -g) web bash
```

## Health Checks

All services include health checks:

### Web Service
```bash
curl http://localhost:8080/health
# Expected: {"status":"ok"}
```

### Redis
```bash
docker compose exec redis redis-cli ping
# Expected: PONG
```

### PostgreSQL
```bash
docker compose exec postgres pg_isready -U axolotl
# Expected: postgres:5432 - accepting connections
```

## Performance Tuning

### Gunicorn Workers

Adjust in `docker/Dockerfile.prod`:
```dockerfile
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "--threads", "2", ...]
```

Formula: `(2 x num_cores) + 1`

### Redis Memory

Add to `docker-compose.yml`:
```yaml
redis:
  command: redis-server --appendonly yes --maxmemory 512mb --maxmemory-policy allkeys-lru
```

### PostgreSQL

Add to `docker-compose.yml`:
```yaml
postgres:
  command: postgres -c max_connections=100 -c shared_buffers=256MB
```

## Security

### Non-Root User

The Dockerfile creates and uses a non-root user:
```dockerfile
RUN useradd -m -u 1000 appuser
USER appuser
```

### Secrets Management

Never commit secrets to `.env`. Use:
- Azure Key Vault (production)
- Docker secrets (Swarm/Kubernetes)
- Environment variable injection (CI/CD)

### Network Isolation

Services communicate via internal Docker network:
```yaml
networks:
  axolotl-network:
    driver: bridge
```

## CI/CD Integration

The Docker setup integrates with GitHub Actions. See:
- `.github/workflows/ci.yml` - Continuous Integration
- `.github/workflows/deploy.yml` - Deployment
- `CI_CD_IMPLEMENTATION.md` - Full documentation

## Metadata

**MODEL**: N/A (Infrastructure)  
**DATA**: N/A  
**TRAINING/BUILD RECIPE**: 
- Multi-stage Docker build with Node.js 20 and Python 3.11
- Frontend built with Vite
- Backend served with Gunicorn (4 workers, 2 threads)
- Build time: ~5-10 minutes full build, ~1-2 minutes with cache

**EVAL & ACCEPTANCE**:
- ✅ Docker image builds successfully
- ✅ Container starts and health check passes at /health
- ✅ All services connect to Redis
- ✅ SQLite fallback works without PostgreSQL
- ✅ Frontend static files served correctly at http://localhost:8080
- ✅ `docker compose up --build` successfully starts all services
- ✅ Start scripts support both dev and prod modes
- ✅ Non-root user (appuser) runs the application
- ✅ Azure environment variables respected

## Additional Resources

- [Docker Documentation](docker/README.md)
- [CI/CD Setup](CI_CD_IMPLEMENTATION.md)
- [Quick Start Guide](docker/QUICK_START.md)
- [Application Architecture](app/README.md)
