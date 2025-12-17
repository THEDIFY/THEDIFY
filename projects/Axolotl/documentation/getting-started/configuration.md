# Configuration Guide

This guide explains how to configure the Axolotl Football Analysis Platform for different environments.

## Environment Files

The application uses environment variables for configuration. Create a `.env` file in the project root.

### Quick Setup

```bash
# Copy the example environment file
cp .env.example .env

# Edit with your settings
nano .env
```

## Database Configuration

### SQLite (Development - Default)

For local development, SQLite is the easiest option:

```bash
DATABASE_URL=sqlite:///data/axolotl.db
```

### PostgreSQL (Production)

For production or when using Docker with PostgreSQL:

```bash
# Local PostgreSQL
DATABASE_URL=postgresql://username:password@localhost:5432/axolotl

# Docker PostgreSQL
DATABASE_URL=postgresql://axolotl:axolotl@postgres:5432/axolotl

# Azure PostgreSQL
DATABASE_URL=postgresql://username@server:password@server.postgres.database.azure.com:5432/axolotl
```

## Redis Configuration

```bash
# Local Redis
REDIS_URL=redis://localhost:6379/0

# Docker Redis
REDIS_URL=redis://redis:6379/0

# Azure Redis
REDIS_URL=rediss://:password@your-redis.redis.cache.windows.net:6380/0
```

## Azure Services (Optional)

### Azure OpenAI

For AI-powered coaching feedback:

```bash
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key
AZURE_OPENAI_API_VERSION=2024-02-15-preview
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4
AZURE_OPENAI_EMBEDDING_DEPLOYMENT=text-embedding-3-large
```

### Azure Cognitive Search

For RAG (Retrieval-Augmented Generation) system:

```bash
AZURE_SEARCH_ENDPOINT=https://your-search.search.windows.net
AZURE_SEARCH_KEY=your-admin-key
AZURE_SEARCH_INDEX=football-analysis
```

### Azure Blob Storage

For storing videos and processed data:

```bash
AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;AccountName=...;AccountKey=...;EndpointSuffix=core.windows.net
AZURE_STORAGE_CONTAINER=football-videos
```

### Azure Key Vault

For secure secret management:

```bash
AZURE_KEYVAULT_URL=https://your-vault.vault.azure.net/
```

## Application Settings

### Flask Configuration

```bash
FLASK_ENV=development          # or 'production'
FLASK_DEBUG=true              # Enable debug mode (development only)
SECRET_KEY=your-secret-key    # Generate with: python -c "import secrets; print(secrets.token_hex(32))"
PORT=8080                     # Application port
```

### CORS Settings

```bash
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
```

### File Upload Limits

```bash
MAX_CONTENT_LENGTH=524288000  # 500MB in bytes
UPLOAD_FOLDER=storage/uploads
```

## AI Model Configuration

### YOLO Detection

```bash
YOLO_MODEL_PATH=models/yolov8n.pt
YOLO_CONFIDENCE_THRESHOLD=0.5
```

### Pose Estimation

```bash
POSE_MODEL=mediapipe           # or 'openpose', 'detectron2'
POSE_CONFIDENCE_THRESHOLD=0.5
```

### Event Spotting

```bash
EVENT_MODEL_PATH=models/event_spotting.pth
EVENT_CLASSES=goal,pass,shot,tackle
```

## Performance Tuning

### Worker Configuration

```bash
WORKER_CONCURRENCY=4          # Number of worker processes
WORKER_TIMEOUT=3600          # Worker timeout in seconds (1 hour)
```

### Gunicorn (Production)

```bash
GUNICORN_WORKERS=4           # Number of worker processes: (2 x CPU cores) + 1
GUNICORN_THREADS=2           # Threads per worker
GUNICORN_TIMEOUT=120         # Request timeout in seconds
```

### Redis Cache

```bash
REDIS_CACHE_TTL=3600         # Cache time-to-live in seconds (1 hour)
REDIS_MAX_MEMORY=512mb
```

## Logging

```bash
LOG_LEVEL=INFO               # DEBUG, INFO, WARNING, ERROR, CRITICAL
LOG_FILE=logs/axolotl.log
LOG_MAX_BYTES=10485760       # 10MB
LOG_BACKUP_COUNT=5
```

## Feature Flags

Enable or disable specific features:

```bash
ENABLE_LIVE_ANALYSIS=true
ENABLE_CALENDAR=true
ENABLE_AI_FEEDBACK=true
ENABLE_MOBILE_PAIRING=true
ENABLE_EVENT_SPOTTING=true
```

## Complete Example: Development

```bash
# Database
DATABASE_URL=sqlite:///data/axolotl.db

# Redis
REDIS_URL=redis://localhost:6379/0

# Flask
FLASK_ENV=development
FLASK_DEBUG=true
SECRET_KEY=dev-secret-key-change-in-production
PORT=8080

# Logging
LOG_LEVEL=DEBUG
LOG_FILE=logs/axolotl.log

# Features
ENABLE_LIVE_ANALYSIS=true
ENABLE_CALENDAR=true
ENABLE_AI_FEEDBACK=false     # Disabled without Azure credentials
ENABLE_MOBILE_PAIRING=true
```

## Complete Example: Production

```bash
# Database
DATABASE_URL=postgresql://axolotl:secure-password@postgres:5432/axolotl

# Redis
REDIS_URL=redis://redis:6379/0

# Flask
FLASK_ENV=production
FLASK_DEBUG=false
SECRET_KEY=CHANGE-THIS-TO-RANDOM-SECRET
PORT=8080

# Azure OpenAI
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=${AZURE_OPENAI_API_KEY}  # From environment or secrets
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4

# Azure Search
AZURE_SEARCH_ENDPOINT=https://your-search.search.windows.net
AZURE_SEARCH_KEY=${AZURE_SEARCH_KEY}  # From environment or secrets
AZURE_SEARCH_INDEX=football-analysis

# Azure Storage
AZURE_STORAGE_CONNECTION_STRING=${AZURE_STORAGE_CONNECTION_STRING}
AZURE_STORAGE_CONTAINER=football-videos

# Gunicorn
GUNICORN_WORKERS=4
GUNICORN_THREADS=2
GUNICORN_TIMEOUT=120

# Logging
LOG_LEVEL=INFO
LOG_FILE=/var/log/axolotl/app.log

# Features
ENABLE_LIVE_ANALYSIS=true
ENABLE_CALENDAR=true
ENABLE_AI_FEEDBACK=true
ENABLE_MOBILE_PAIRING=true
```

## Security Best Practices

### Never Commit Secrets

Ensure `.env` is in `.gitignore`:

```bash
# Check if .env is ignored
git check-ignore .env
# Should output: .env
```

### Use Strong Secrets

Generate secure random keys:

```python
# For SECRET_KEY
python -c "import secrets; print(secrets.token_hex(32))"

# For API keys
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Environment-Specific Files

Use different env files for different environments:

```bash
.env.development
.env.staging
.env.production
```

Load with:
```bash
docker compose --env-file .env.production up
```

## Troubleshooting

### Database Connection Errors

```bash
# Test PostgreSQL connection
psql -h localhost -U axolotl -d axolotl -c "SELECT 1;"

# Test SQLite path
ls -la data/axolotl.db
```

### Redis Connection Errors

```bash
# Test Redis connection
redis-cli -h localhost -p 6379 ping
# Expected: PONG
```

### Azure Service Errors

```bash
# Test Azure OpenAI
curl -X POST ${AZURE_OPENAI_ENDPOINT}openai/deployments/${AZURE_OPENAI_DEPLOYMENT_NAME}/chat/completions?api-version=${AZURE_OPENAI_API_VERSION} \
  -H "Content-Type: application/json" \
  -H "api-key: ${AZURE_OPENAI_API_KEY}" \
  -d '{"messages":[{"role":"user","content":"test"}]}'
```

## Next Steps

- [Quick Start](quick-start.md) - Start the application
- [Installation](installation.md) - Manual installation guide
- [Docker Development](../development/docker.md) - Docker-specific configuration
- [Production Deployment](../deployment/production.md) - Production setup
