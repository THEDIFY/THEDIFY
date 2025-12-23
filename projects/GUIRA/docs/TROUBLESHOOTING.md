# GUIRA Troubleshooting Guide

Common issues and solutions for GUIRA deployment and operation.

## 📋 Table of Contents

- [Installation Issues](#installation-issues)
- [Runtime Errors](#runtime-errors)
- [Performance Problems](#performance-problems)
- [API Issues](#api-issues)
- [Database Problems](#database-problems)
- [Model Loading Errors](#model-loading-errors)
- [Geospatial Processing](#geospatial-processing)
- [Getting Help](#getting-help)

---

## Installation Issues

### GDAL Installation Failures

**Problem:** `ERROR: Failed building wheel for GDAL`

**Solutions:**

```bash
# Ubuntu/Debian
sudo apt-get install -y gdal-bin libgdal-dev
export GDAL_CONFIG=/usr/bin/gdal-config
pip install GDAL==$(gdal-config --version)

# macOS (Homebrew)
brew install gdal
export GDAL_CONFIG=/usr/local/bin/gdal-config
pip install GDAL==$(gdal-config --version)

# Set environment variables permanently
echo 'export GDAL_DATA=/usr/share/gdal' >> ~/.bashrc
echo 'export PROJ_LIB=/usr/share/proj' >> ~/.bashrc
```

---

### PyTorch GPU Not Detected

**Problem:** `CUDA not available` or `No GPU detected`

**Check CUDA Installation:**

```bash
# Verify NVIDIA driver
nvidia-smi

# Check CUDA version
nvcc --version

# Test PyTorch GPU
python -c "import torch; print(torch.cuda.is_available())"
python -c "import torch; print(torch.cuda.get_device_name(0))"
```

**Solutions:**

```bash
# Install correct PyTorch version for your CUDA
# For CUDA 11.8
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118

# For CUDA 12.1
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
```

---

### PostgreSQL PostGIS Extension Error

**Problem:** `ERROR: could not open extension control file`

**Solution:**

```bash
# Install PostGIS
sudo apt-get install -y postgresql-15-postgis-3

# Connect to database
sudo -u postgres psql guira

# Enable extension
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

# Verify
SELECT PostGIS_version();
```

---

## Runtime Errors

### Out of Memory (OOM)

**Problem:** Process killed due to OOM

**Symptoms:**
- `Killed` message when running inference
- Container restarts unexpectedly
- System becomes unresponsive

**Solutions:**

```python
# Reduce batch size
BATCH_SIZE = 4  # Down from 16

# Use gradient checkpointing
model.gradient_checkpointing_enable()

# Clear cache regularly
import torch
torch.cuda.empty_cache()

# Use mixed precision
from torch.cuda.amp import autocast
with autocast():
    outputs = model(inputs)
```

```bash
# Increase Docker memory limit
docker run -m 16g ...

# Kubernetes resource limits
resources:
  limits:
    memory: "16Gi"
```

---

### Import Errors

**Problem:** `ModuleNotFoundError: No module named 'xyz'`

**Solutions:**

```bash
# Verify virtual environment is activated
which python  # Should show venv path

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Check for conflicts
pip check

# Install specific version
pip install package==version
```

---

## Performance Problems

### Slow Inference

**Problem:** Model inference taking too long

**Diagnostics:**

```python
import time

start = time.time()
outputs = model(inputs)
print(f"Inference time: {time.time() - start:.3f}s")
```

**Solutions:**

1. **Use GPU:**
```python
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = model.to(device)
inputs = inputs.to(device)
```

2. **Optimize Model:**
```python
# TorchScript compilation
model = torch.jit.script(model)

# ONNX export for faster inference
torch.onnx.export(model, dummy_input, "model.onnx")
```

3. **Batch Processing:**
```python
# Process multiple images at once
batch = torch.stack([img1, img2, img3])
outputs = model(batch)
```

---

### High CPU Usage

**Problem:** CPU at 100% constantly

**Check:**

```bash
# Monitor processes
top
htop

# Profile Python
pip install py-spy
py-spy top -- python app.py
```

**Solutions:**

- Reduce worker processes
- Enable GPU processing
- Optimize data loading (num_workers, prefetch)
- Cache expensive computations

---

## API Issues

### 401 Unauthorized

**Problem:** API requests failing with 401

**Check:**

```bash
# Verify API key
curl -H "X-API-Key: YOUR_KEY" http://localhost:8000/api/v1/health

# Check key in database
psql guira -c "SELECT * FROM api_keys WHERE key_hash = 'hash';"
```

**Solution:**

```bash
# Generate new API key
python manage.py create_api_key

# Update .env
export API_KEY=new_key_here
```

---

### 500 Internal Server Error

**Problem:** API returns 500 errors

**Debug:**

```bash
# Check logs
docker logs guira-api

# Enable debug mode
export DEBUG=True

# Check error details
curl -v http://localhost:8000/api/v1/endpoint
```

**Common Causes:**
- Database connection lost
- Model file missing or corrupted
- Configuration error
- Uncaught exception in code

---

## Database Problems

### Connection Refused

**Problem:** `could not connect to server: Connection refused`

**Check:**

```bash
# Is PostgreSQL running?
sudo systemctl status postgresql

# Start if needed
sudo systemctl start postgresql

# Check port
netstat -an | grep 5432

# Test connection
psql -h localhost -U guirauser -d guira
```

**Solution:**

```bash
# Update pg_hba.conf for network access
sudo nano /etc/postgresql/15/main/pg_hba.conf

# Add line:
# host    all             all             0.0.0.0/0               md5

# Restart
sudo systemctl restart postgresql
```

---

### Slow Queries

**Problem:** Database queries taking too long

**Diagnose:**

```sql
# Enable query logging
ALTER DATABASE guira SET log_min_duration_statement = 1000;  -- Log queries >1s

# Check slow queries
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

# Analyze query plan
EXPLAIN ANALYZE SELECT * FROM detections WHERE ...;
```

**Solutions:**

```sql
# Add missing indexes
CREATE INDEX idx_detections_timestamp ON detections(timestamp);
CREATE INDEX idx_detections_geom ON detections USING GIST(geom);

# Vacuum database
VACUUM ANALYZE detections;

# Update statistics
ANALYZE detections;
```

---

## Model Loading Errors

### Model File Not Found

**Problem:** `FileNotFoundError: model.pt not found`

**Solution:**

```bash
# Download models
python scripts/download_models.py

# Verify paths in config
cat config/settings.yaml

# Check file exists
ls -lh models/

# Set correct path
export YOLOV8_MODEL=/absolute/path/to/model.pt
```

---

### Model Incompatibility

**Problem:** `RuntimeError: Model was trained with PyTorch X but using Y`

**Solution:**

```bash
# Check PyTorch version
python -c "import torch; print(torch.__version__)"

# Reinstall correct version
pip install torch==2.1.0

# Re-download compatible models
python scripts/download_models.py --pytorch-version 2.1.0
```

---

## Geospatial Processing

### Coordinate Transformation Errors

**Problem:** `PROJ: proj_create_from_database: Cannot find proj.db`

**Solution:**

```bash
# Install PROJ data
sudo apt-get install proj-data

# Set environment variable
export PROJ_LIB=/usr/share/proj

# Verify
python -c "from osgeo import osr; print(osr.GetPROJVersionMicro())"
```

---

### DEM Loading Issues

**Problem:** `ERROR: Unable to open DEM file`

**Check:**

```python
from osgeo import gdal

ds = gdal.Open('dem.tif')
if ds is None:
    print("Failed to open")
else:
    print(f"Size: {ds.RasterXSize} x {ds.RasterYSize}")
    print(f"Projection: {ds.GetProjection()}")
```

**Solution:**

```bash
# Verify file format
gdalinfo dem.tif

# Convert if needed
gdal_translate -of GTiff input.dem output.tif

# Reproject to WGS84
gdalwarp -t_srs EPSG:4326 input.tif output_wgs84.tif
```

---

## Docker Issues

### Container Won't Start

**Problem:** Container exits immediately

**Debug:**

```bash
# Check logs
docker logs container_name

# Run interactively
docker run -it --entrypoint /bin/bash image_name

# Check resource limits
docker stats
```

---

### Volume Permission Issues

**Problem:** `Permission denied` when accessing mounted volumes

**Solution:**

```bash
# Set ownership
sudo chown -R $USER:$USER ./data

# Or run container as current user
docker run --user $(id -u):$(id -g) ...
```

---

## Kubernetes Issues

### Pod Crashloop

**Problem:** Pod keeps restarting

**Debug:**

```bash
# Check pod events
kubectl describe pod pod_name

# View logs
kubectl logs pod_name --previous

# Get pod shell
kubectl exec -it pod_name -- /bin/bash
```

---

### ImagePullBackOff

**Problem:** Can't pull Docker image

**Solution:**

```bash
# Check image exists
docker pull image:tag

# Verify registry credentials
kubectl get secret regcred --output=yaml

# Create pull secret
kubectl create secret docker-registry regcred \
    --docker-server=registry.com \
    --docker-username=user \
    --docker-password=pass
```

---

## Getting Help

### Collect System Information

```bash
# System info
uname -a
python --version
pip list | grep -E 'torch|gdal|postgres'

# GPU info (if applicable)
nvidia-smi

# Disk space
df -h

# Memory
free -h

# Logs
tail -n 100 /var/log/guira/app.log
```

### Submit Issue

When reporting issues, include:

1. **Error message** (full traceback)
2. **System information** (OS, Python version, GPU)
3. **Steps to reproduce**
4. **Expected vs actual behavior**
5. **Relevant logs**
6. **Configuration** (sanitized, no secrets)

**GitHub Issues:** https://github.com/THEDIFY/THEDIFY/issues

---

## FAQ

**Q: Why is fire detection slow on CPU?**  
A: YOLOv8 is optimized for GPU. Consider using YOLOv8-nano for CPU or adding GPU.

**Q: Can I run without GPU?**  
A: Yes, but expect 5-10x slower inference. Recommended for development only.

**Q: How much disk space needed?**  
A: ~20GB for models and dependencies, plus data storage (varies by usage).

**Q: What's the minimum RAM?**  
A: 16GB minimum, 32GB recommended for full pipeline.

---

## Support

**Email:** rasanti2008@gmail.com  
**GitHub Issues:** https://github.com/THEDIFY/THEDIFY/issues  
**Discussions:** https://github.com/THEDIFY/THEDIFY/discussions

---

*Last Updated: December 17, 2025*
