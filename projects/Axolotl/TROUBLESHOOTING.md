# Troubleshooting Guide

Common issues and solutions for Axolotl Football Analysis Platform.

## Table of Contents
- [Installation Issues](#installation-issues)
- [Runtime Errors](#runtime-errors)
- [Performance Issues](#performance-issues)
- [GPU/CUDA Issues](#gpucuda-issues)
- [Database Issues](#database-issues)
- [Video Processing Issues](#video-processing-issues)
- [API Issues](#api-issues)
- [Frontend Issues](#frontend-issues)
- [Docker Issues](#docker-issues)
- [Getting Help](#getting-help)

---

## Installation Issues

### Issue: `pip install` fails with dependency conflicts

**Symptoms:**
```
ERROR: Cannot install package X because these packages depend on different versions
```

**Solution:**
```bash
# Create fresh virtual environment
python -m venv venv_new
source venv_new/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

# Install dependencies one by one if needed
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
pip install -r code/requirements.txt
```

### Issue: `ModuleNotFoundError: No module named 'cv2'`

**Symptoms:**
```python
ImportError: No module named 'cv2'
```

**Solution:**
```bash
# Install OpenCV
pip install opencv-python opencv-contrib-python

# If still fails, try system install (Ubuntu)
sudo apt install python3-opencv
```

### Issue: CUDA not available / PyTorch not detecting GPU

**Symptoms:**
```python
>>> import torch
>>> torch.cuda.is_available()
False
```

**Solution:**
```bash
# Check NVIDIA driver
nvidia-smi

# If driver missing, install:
sudo apt install nvidia-driver-525  # Adjust version

# Check CUDA version
nvcc --version

# Install correct PyTorch version for your CUDA
# For CUDA 11.8:
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118

# For CUDA 12.1:
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
```

---

## Runtime Errors

### Issue: `Flask application fails to start`

**Symptoms:**
```
Address already in use: Port 8080
```

**Solution:**
```bash
# Find process using port 8080
lsof -i :8080
# or
netstat -tulpn | grep 8080

# Kill the process
kill -9 <PID>

# Or use different port
export PORT=8081
python app.py
```

### Issue: Redis connection refused

**Symptoms:**
```
redis.exceptions.ConnectionError: Error 111 connecting to localhost:6379. Connection refused.
```

**Solution:**
```bash
# Check if Redis is running
redis-cli ping
# Expected: PONG

# If not running, start Redis
redis-server

# Or with Docker
docker run -d -p 6379:6379 redis:7-alpine

# Check Redis is accessible
redis-cli
> ping
PONG
```

### Issue: Database migration fails

**Symptoms:**
```
sqlalchemy.exc.OperationalError: could not connect to server
```

**Solution:**
```bash
# Check database is running
psql -h localhost -U axolotl -d axolotl

# If PostgreSQL not running
sudo systemctl start postgresql

# Verify DATABASE_URL is correct
echo $DATABASE_URL

# Run migrations with verbose output
python app/backend/migrate.py upgrade --sql

# Reset migrations if corrupted
python app/backend/migrate.py downgrade base
python app/backend/migrate.py upgrade
```

---

## Performance Issues

### Issue: Video processing is very slow (< 5 FPS)

**Possible Causes & Solutions:**

**1. No GPU acceleration:**
```bash
# Check GPU is being used
nvidia-smi

# Set GPU device explicitly
export CUDA_VISIBLE_DEVICES=0

# Verify PyTorch sees GPU
python -c "import torch; print(torch.cuda.is_available())"
```

**2. Using large YOLO model:**
```bash
# Switch to lighter model
export YOLO_MODEL="yolov8n"  # Nano (fastest)
# Instead of yolov8m or yolov8l
```

**3. Processing at too high resolution:**
```python
# In detection config, reduce input size
detector = YOLODetector(imgsz=640)  # Instead of 1280
```

**4. Too many concurrent jobs:**
```bash
# Reduce worker concurrency
export WORKER_CONCURRENCY=1
```

### Issue: High memory usage / Out of memory errors

**Symptoms:**
```
RuntimeError: CUDA out of memory
```

**Solution:**
```bash
# 1. Reduce batch size
export BATCH_SIZE=8  # Instead of 32

# 2. Use gradient checkpointing
export USE_GRADIENT_CHECKPOINTING=true

# 3. Clear GPU cache periodically
python -c "import torch; torch.cuda.empty_cache()"

# 4. Use smaller models
export YOLO_MODEL="yolov8n"
export ENABLE_SMPL="false"  # Disable SMPL if not needed

# 5. Reduce video resolution before processing
ffmpeg -i input.mp4 -vf scale=1280:720 output.mp4
```

### Issue: Web interface is slow/laggy

**Solutions:**

**1. Enable Redis caching:**
```bash
# Verify Redis is running and connected
redis-cli ping

# Check cache hit rate
redis-cli info stats | grep keyspace
```

**2. Optimize database queries:**
```bash
# Add database indexes
python app/backend/migrate.py upgrade

# Check slow queries
tail -f /var/log/postgresql/postgresql-15-main.log | grep "duration"
```

**3. Enable CDN for static assets:**
```nginx
# nginx.conf
location /static/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

---

## GPU/CUDA Issues

### Issue: Multiple GPU conflicts

**Symptoms:**
```
RuntimeError: CUDA error: device-side assert triggered
```

**Solution:**
```bash
# Use specific GPU
export CUDA_VISIBLE_DEVICES=0

# Check GPU memory
nvidia-smi --query-gpu=memory.used,memory.total --format=csv

# Clear processes using GPU
sudo fuser -v /dev/nvidia*
kill -9 <PID>
```

### Issue: CUDA version mismatch

**Symptoms:**
```
UserWarning: CUDA initialization: Found no NVIDIA driver on your system
```

**Solution:**
```bash
# Check CUDA version
nvcc --version
nvidia-smi  # Check driver version

# Reinstall matching PyTorch
# For CUDA 11.8:
pip uninstall torch torchvision
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
```

---

## Database Issues

### Issue: PostgreSQL connection pool exhausted

**Symptoms:**
```
OperationalError: connection pool exhausted
```

**Solution:**
```python
# In app config, increase pool size
app.config['SQLALCHEMY_POOL_SIZE'] = 20
app.config['SQLALCHEMY_MAX_OVERFLOW'] = 10

# Or in environment
export DB_POOL_SIZE=20
export DB_MAX_OVERFLOW=10
```

### Issue: Database locked (SQLite)

**Symptoms:**
```
OperationalError: database is locked
```

**Solution:**
```bash
# SQLite is not suitable for production with concurrent writes
# Switch to PostgreSQL:

# 1. Export data
python scripts/export_sqlite_data.py > data_backup.json

# 2. Set up PostgreSQL
sudo apt install postgresql
sudo -u postgres createdb axolotl

# 3. Update DATABASE_URL
export DATABASE_URL="postgresql://user:pass@localhost/axolotl"

# 4. Import data
python scripts/import_data.py < data_backup.json
```

---

## Video Processing Issues

### Issue: Video upload fails

**Symptoms:**
```
413 Request Entity Too Large
```

**Solution:**
```bash
# 1. Increase max upload size in Flask
export MAX_CONTENT_LENGTH=524288000  # 500MB

# 2. If using NGINX, update config:
# nginx.conf
client_max_body_size 500M;

# 3. Reload NGINX
sudo nginx -s reload
```

### Issue: Video processing stuck

**Symptoms:**
Job shows "processing" status but never completes.

**Diagnosis:**
```bash
# Check worker logs
docker logs axolotl-worker
# or
tail -f logs/worker.log

# Check Redis queue
redis-cli
> LLEN video_processing
> LRANGE video_processing 0 -1
```

**Solution:**
```bash
# Clear stuck jobs
redis-cli
> DEL video_processing

# Restart worker
docker restart axolotl-worker
# or
pkill -f worker.py
python worker.py
```

### Issue: Poor detection accuracy

**Symptoms:**
Players not detected or false positives.

**Solutions:**

**1. Check video quality:**
```bash
# Video should be at least 720p
ffprobe video.mp4 | grep Video

# If too low quality, players may be too small to detect
```

**2. Adjust confidence threshold:**
```python
# Lower threshold for more detections (more false positives)
detector = YOLODetector(conf_threshold=0.3)  # Default: 0.5

# Higher threshold for fewer false positives (may miss some players)
detector = YOLODetector(conf_threshold=0.7)
```

**3. Use larger model:**
```bash
export YOLO_MODEL="yolov8s"  # Or yolov8m for better accuracy
```

---

## API Issues

### Issue: 401 Unauthorized errors

**Symptoms:**
```json
{"error": "Unauthorized", "code": 401}
```

**Solution:**
```bash
# Check API key is valid
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:8080/health

# Regenerate API key if needed
python scripts/generate_api_key.py
```

### Issue: 429 Too Many Requests

**Symptoms:**
```json
{"error": "Rate limit exceeded", "retry_after": 3600}
```

**Solution:**
```bash
# Wait for rate limit to reset
# Or increase rate limits in config:

export RATE_LIMIT_PER_HOUR=200  # Default: 100
```

### Issue: CORS errors in frontend

**Symptoms:**
```
Access to XMLHttpRequest has been blocked by CORS policy
```

**Solution:**
```python
# In app.py, ensure CORS is configured:
from flask_cors import CORS

CORS(app, origins=["http://localhost:3000", "https://yourdomain.com"])
```

---

## Frontend Issues

### Issue: Frontend not loading / blank screen

**Diagnosis:**
```bash
# Check browser console for errors
# Open DevTools (F12) → Console tab

# Check if backend is running
curl http://localhost:8080/health
```

**Solutions:**

**1. Build frontend:**
```bash
cd app/frontend
npm install
npm run build
```

**2. Clear browser cache:**
- Chrome: Ctrl+Shift+Delete
- Firefox: Ctrl+Shift+Delete

**3. Check API endpoint:**
```typescript
// app/frontend/src/config.ts
export const API_BASE_URL = "http://localhost:8080";
```

### Issue: WebSocket connection fails

**Symptoms:**
```
WebSocket connection to 'ws://localhost:8080/socket.io/' failed
```

**Solution:**
```bash
# Check Flask-SocketIO is installed
pip install flask-socketio

# Verify WebSocket endpoint
curl -i -N -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  http://localhost:8080/socket.io/

# Check firewall allows WebSocket
sudo ufw allow 8080/tcp
```

---

## Docker Issues

### Issue: Docker build fails

**Symptoms:**
```
ERROR [internal] load metadata for docker.io/library/python:3.11
```

**Solution:**
```bash
# Update Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli

# Clear Docker cache
docker system prune -a

# Build with no cache
docker build --no-cache -t axolotl:latest .
```

### Issue: Container crashes immediately

**Diagnosis:**
```bash
# View container logs
docker logs axolotl-web

# Check exit code
docker ps -a
```

**Common Causes:**

**1. Missing environment variables:**
```bash
# Verify .env file exists
ls -la .env

# Check required variables
docker run --env-file .env axolotl:latest env | grep DATABASE_URL
```

**2. Port already in use:**
```bash
# Use different port
docker run -p 8081:8080 axolotl:latest
```

**3. Permission issues:**
```bash
# Fix volume permissions
sudo chown -R $(id -u):$(id -g) ./data ./logs
```

---

## Getting Help

### Before Asking for Help

1. **Check the logs:**
   ```bash
   # Application logs
   tail -f logs/app.log
   
   # Worker logs
   tail -f logs/worker.log
   
   # Docker logs
   docker compose logs -f
   ```

2. **Search existing issues:**
   - [GitHub Issues](../../issues)
   - [Discussions](../../discussions)

3. **Verify your environment:**
   ```bash
   # Python version
   python --version
   
   # CUDA version
   nvidia-smi
   
   # Dependencies
   pip list | grep -E "torch|ultralytics|opencv"
   
   # Environment variables
   env | grep -E "DATABASE|REDIS|CUDA"
   ```

### How to Report an Issue

Include the following information:

**1. Environment:**
- OS and version
- Python version
- GPU model and CUDA version
- Docker version (if applicable)

**2. Steps to reproduce:**
- Exact commands run
- Configuration used
- Sample data (if possible)

**3. Error output:**
- Complete error message
- Stack trace
- Relevant log excerpts

**4. Expected vs actual behavior:**
- What you expected to happen
- What actually happened

### Contact Options

- **GitHub Issues:** [Open an issue](../../issues/new)
- **GitHub Discussions:** [Start a discussion](../../discussions/new)
- **Email:** rasanti2008@gmail.com

### Debug Mode

Enable debug mode for more detailed logs:

```bash
# Flask debug mode
export FLASK_ENV=development
export FLASK_DEBUG=1

# Python debug logging
export LOG_LEVEL=DEBUG

# PyTorch debug
export TORCH_DISTRIBUTED_DEBUG=DETAIL
```

---

## Frequently Asked Questions

### Q: Can I run Axolotl without a GPU?

**A:** Yes, but performance will be significantly slower (5-10 FPS vs 30-60 FPS with GPU). For CPU-only:
```bash
export GPU_ENABLED=false
export YOLO_MODEL="yolov8n"
export ENABLE_SMPL="false"
```

### Q: What video formats are supported?

**A:** MP4, MOV, AVI. Use H.264 codec for best compatibility.

### Q: How much GPU memory do I need?

**A:** 
- Minimum: 4GB (YOLOv8n only)
- Recommended: 8GB (all features)
- Optimal: 16GB+ (multiple concurrent sessions)

### Q: Can I process multiple videos simultaneously?

**A:** Yes, scale worker processes:
```bash
# Start multiple workers
docker compose up --scale worker=3
```

### Q: How do I update to the latest version?

**A:**
```bash
git pull origin main
pip install -r code/requirements.txt --upgrade
docker compose pull
docker compose up -d
```

---

## Related Documentation

- [Installation Guide](documentation/getting-started/quick-start.md)
- [Configuration Guide](documentation/getting-started/configuration.md)
- [Deployment Guide](DEPLOYMENT.md)
- [API Documentation](API.md)
