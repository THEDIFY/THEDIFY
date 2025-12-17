# Troubleshooting Guide

Common issues and solutions for the Axolotl Football Analysis Platform.

## Installation Issues

### Python Version Errors

**Problem**: `ImportError` or syntax errors when running the application.

**Solution**:
```bash
# Check Python version (requires 3.11+)
python --version

# Use the correct Python version
python3.11 -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
```

### Dependency Installation Failures

**Problem**: `pip install` fails with compilation errors.

**Solution**:
```bash
# Update pip and setuptools
pip install --upgrade pip setuptools wheel

# Install system dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install python3-dev build-essential

# Install specific problem packages separately
pip install numpy scipy
pip install opencv-python
pip install -r requirements.txt
```

## Docker Issues

### Port Already in Use

**Problem**: `Error: port 8080 already in use`

**Solution**:
```bash
# Find process using port
lsof -i :8080

# Or on Windows
netstat -ano | findstr :8080

# Kill the process
kill -9 <PID>

# Or change port in .env
PORT=8081
```

### Container Won't Start

**Problem**: Container exits immediately after starting.

**Solution**:
```bash
# View detailed logs
docker compose logs web

# Check container status
docker compose ps

# Force recreate
docker compose down
docker compose up --force-recreate

# Build without cache
docker compose build --no-cache
```

### Permission Denied Errors

**Problem**: `Permission denied` when accessing mounted volumes.

**Solution**:
```bash
# Fix ownership (Linux/Mac)
sudo chown -R $(id -u):$(id -g) logs/ storage/ data/

# Or run with user ID
docker compose run --user $(id -u):$(id -g) web bash
```

## Database Issues

### SQLite Database Locked

**Problem**: `database is locked` errors.

**Solution**:
```bash
# Close all connections
pkill python

# Remove lock file
rm data/axolotl.db-journal

# Or switch to PostgreSQL
docker compose --profile postgres up -d
```

### PostgreSQL Connection Refused

**Problem**: `connection to server at "postgres" (x.x.x.x), port 5432 failed`

**Solution**:
```bash
# Check PostgreSQL is running
docker compose ps postgres

# View PostgreSQL logs
docker compose logs postgres

# Restart PostgreSQL
docker compose restart postgres

# Verify connection from web container
docker compose exec web psql -h postgres -U axolotl -d axolotl
```

### Migration Errors

**Problem**: Database schema out of sync.

**Solution**:
```bash
# Apply migrations manually
docker compose exec web bash
cd migrations
psql $DATABASE_URL -f create_users_scans.sql

# Or reset database (CAUTION: destroys data)
docker compose down -v
docker compose up -d
```

## Azure Service Errors

### Azure OpenAI Authentication Failed

**Problem**: `AuthenticationError: Incorrect API key provided`

**Solution**:
```bash
# Verify credentials in .env
echo $AZURE_OPENAI_API_KEY

# Test connection
curl -X POST ${AZURE_OPENAI_ENDPOINT}openai/deployments/${AZURE_OPENAI_DEPLOYMENT_NAME}/chat/completions?api-version=${AZURE_OPENAI_API_VERSION} \
  -H "Content-Type: application/json" \
  -H "api-key: ${AZURE_OPENAI_API_KEY}" \
  -d '{"messages":[{"role":"user","content":"test"}]}'

# Regenerate key in Azure Portal if needed
```

### Azure Search Index Not Found

**Problem**: `ResourceNotFoundError: Index 'football-analysis' not found`

**Solution**:
```bash
# Create index manually via Azure Portal
# Or use the setup script
python scripts/setup_azure_search.py

# Verify index exists
curl -X GET "${AZURE_SEARCH_ENDPOINT}/indexes?api-version=2023-11-01" \
  -H "api-key: ${AZURE_SEARCH_KEY}"
```

### Azure Blob Storage Access Denied

**Problem**: `AuthorizationPermissionMismatch` or `403 Forbidden`

**Solution**:
```bash
# Check connection string format
echo $AZURE_STORAGE_CONNECTION_STRING

# Test access
az storage container list --connection-string "$AZURE_STORAGE_CONNECTION_STRING"

# Verify container exists
az storage container show --name football-videos --connection-string "$AZURE_STORAGE_CONNECTION_STRING"
```

## Application Errors

### ModuleNotFoundError

**Problem**: `ModuleNotFoundError: No module named 'app.backend'`

**Solution**:
```bash
# Ensure you're in project root
cd /path/to/axolotl

# Add project to PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:$(pwd)"

# Or install in development mode
pip install -e .
```

### Redis Connection Error

**Problem**: `redis.exceptions.ConnectionError: Error connecting to Redis`

**Solution**:
```bash
# Check Redis is running
docker compose ps redis

# Test Redis connection
redis-cli -h localhost -p 6379 ping

# Restart Redis
docker compose restart redis

# Check Redis logs
docker compose logs redis
```

### Worker Not Processing Jobs

**Problem**: Background jobs stuck in queue.

**Solution**:
```bash
# Check worker logs
docker compose logs worker

# Restart worker
docker compose restart worker

# Check Redis queue
docker compose exec redis redis-cli
> LLEN rq:queue:default

# Clear stuck jobs (CAUTION)
> DEL rq:queue:default
```

## Frontend Issues

### Frontend Build Failures

**Problem**: `npm run build` fails with errors.

**Solution**:
```bash
# Clear node_modules and reinstall
cd app/frontend
rm -rf node_modules package-lock.json
npm install

# Use correct Node version (20+)
nvm use 20
npm install

# Build with verbose output
npm run build -- --debug
```

### Frontend Not Loading

**Problem**: Blank page or 404 errors in browser.

**Solution**:
```bash
# Check if frontend was built
ls -la app/backend/static/

# Rebuild frontend
cd app/frontend
npm run build

# Check web server is serving static files
curl http://localhost:8080/
```

### CORS Errors

**Problem**: `Access-Control-Allow-Origin` errors in browser console.

**Solution**:
```bash
# Update CORS_ORIGINS in .env
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Restart application
docker compose restart web
```

## Performance Issues

### Slow Video Processing

**Problem**: Video analysis takes too long.

**Solution**:
```bash
# Check GPU availability
docker compose exec web python -c "import torch; print(torch.cuda.is_available())"

# Use smaller models
YOLO_MODEL=yolov8n.pt  # Instead of yolov8x.pt

# Reduce video resolution
# Process at 720p instead of 1080p

# Increase worker processes
GUNICORN_WORKERS=8  # Adjust based on CPU cores
```

### High Memory Usage

**Problem**: Application uses too much RAM.

**Solution**:
```bash
# Monitor memory usage
docker stats

# Reduce worker processes
GUNICORN_WORKERS=2

# Reduce batch size for ML models
# In code: batch_size=4 instead of batch_size=16

# Set Redis memory limit
docker compose exec redis redis-cli CONFIG SET maxmemory 512mb
```

## Testing Issues

### Tests Failing

**Problem**: `pytest` tests fail unexpectedly.

**Solution**:
```bash
# Run tests with verbose output
pytest -v tests/

# Run specific test
pytest tests/unit/test_basic_llm.py -v

# Skip slow tests
pytest -m "not slow" tests/

# Check test dependencies
pip install -r app/backend/requirements-dev.txt
```

### Test Database Issues

**Problem**: Tests failing due to database state.

**Solution**:
```bash
# Use test database
export DATABASE_URL=sqlite:///test_axolotl.db

# Clean up after tests
pytest tests/ --create-db --reuse-db=false

# Or use pytest fixtures for isolation
```

## Debugging Tips

### Enable Debug Logging

```bash
# In .env
LOG_LEVEL=DEBUG
FLASK_DEBUG=true

# Restart application
docker compose restart web
```

### Access Container Shell

```bash
# Web container
docker compose exec web bash

# Worker container
docker compose exec worker bash

# Run Python REPL
docker compose exec web python
```

### Check All Services Health

```bash
# Web health
curl http://localhost:8080/health

# Redis health
docker compose exec redis redis-cli ping

# PostgreSQL health
docker compose exec postgres pg_isready -U axolotl

# View all logs
docker compose logs -f
```

## Getting Help

If you're still stuck:

1. **Check logs**: `docker compose logs -f`
2. **Search issues**: [GitHub Issues](https://github.com/THEDIFY/axolotl/issues)
3. **Open issue**: Include logs, environment details, and steps to reproduce
4. **Ask community**: Provide minimal reproducible example

## Useful Commands Reference

```bash
# Full reset (CAUTION: destroys all data)
docker compose down -v
rm -rf data/ logs/ storage/
docker compose up --build

# Clean Docker system
docker system prune -a

# View resource usage
docker compose top
docker stats

# Export logs
docker compose logs > app_logs.txt

# Backup database
docker compose exec postgres pg_dump -U axolotl axolotl > backup.sql
```

## Next Steps

- [Configuration Guide](configuration.md) - Adjust settings
- [Development Guide](../development/) - Set up for development
- [Architecture](../architecture/overview.md) - Understand the system
