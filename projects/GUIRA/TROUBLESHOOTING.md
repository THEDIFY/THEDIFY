# GUIRA - Troubleshooting Guide

<div align="center">

![Troubleshooting](https://img.shields.io/badge/Help-Available-success?style=for-the-badge)
![Support](https://img.shields.io/badge/Support-24%2F7-blue?style=for-the-badge)

**Common Issues and Solutions**

*Having problems? This guide will help you resolve the most common issues.*

</div>

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [GPU & CUDA Problems](#gpu--cuda-problems)
3. [Model Loading Errors](#model-loading-errors)
4. [Database Connection Issues](#database-connection-issues)
5. [Performance Problems](#performance-problems)
6. [API Errors](#api-errors)
7. [Docker & Container Issues](#docker--container-issues)
8. [Geospatial Processing Errors](#geospatial-processing-errors)
9. [Memory Issues](#memory-issues)
10. [Getting Additional Help](#getting-additional-help)

---

## Installation Issues

### Problem: `pip install` Fails for GDAL

**Symptoms:**
```
ERROR: Could not find a version that satisfies the requirement gdal>=3.8.0
```

**Solutions:**

**Ubuntu/Debian:**
```bash
# Install GDAL system libraries first
sudo apt-get update
sudo apt-get install -y gdal-bin libgdal-dev

# Get GDAL version
gdal-config --version  # e.g., 3.8.1

# Install matching Python package
pip install gdal==3.8.1
```

**macOS:**
```bash
# Install via Homebrew
brew install gdal

# Install Python package
pip install gdal==$(gdal-config --version)
```

**Windows:**
```bash
# Use conda (recommended for Windows)
conda install -c conda-forge gdal

# Or download prebuilt wheels
# https://www.lfd.uci.edu/~gohlke/pythonlibs/#gdal
pip install GDAL-3.8.1-cp311-cp311-win_amd64.whl
```

---

### Problem: PyTorch Installation Issues

**Symptoms:**
```
ERROR: Could not find a version that satisfies the requirement torch>=2.1.0
```

**Solutions:**

```bash
# CUDA 11.8 (most common)
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118

# CUDA 12.1
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# CPU only (no GPU)
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Verify installation
python -c "import torch; print(f'PyTorch: {torch.__version__}')"
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

---

### Problem: PostgreSQL/PostGIS Not Found

**Symptoms:**
```
ModuleNotFoundError: No module named 'psycopg2'
```

**Solutions:**

```bash
# Install PostgreSQL development files
# Ubuntu/Debian
sudo apt-get install -y postgresql-server-dev-15 libpq-dev

# macOS
brew install postgresql@15

# Install Python package
pip install psycopg2-binary

# For production, compile from source:
pip install psycopg2
```

---

## GPU & CUDA Problems

### Problem: GPU Not Detected

**Symptoms:**
```python
>>> import torch
>>> torch.cuda.is_available()
False
```

**Solutions:**

**1. Verify NVIDIA Driver:**
```bash
nvidia-smi

# Should show:
# +-----------------------------------------------------------------------------+
# | NVIDIA-SMI 535.129.03   Driver Version: 535.129.03   CUDA Version: 12.2   |
# +-----------------------------------------------------------------------------+
```

If `nvidia-smi` fails:
```bash
# Ubuntu/Debian - Install NVIDIA driver
sudo apt-get install -y nvidia-driver-535

# Reboot required
sudo reboot

# Verify after reboot
nvidia-smi
```

**2. Verify CUDA Installation:**
```bash
nvcc --version

# Should show CUDA version
```

If CUDA not found:
```bash
# Ubuntu - Install CUDA Toolkit 11.8
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-repo-ubuntu2204-11-8-local_11.8.0-520.61.05-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-11-8-local_11.8.0-520.61.05-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda
```

**3. Verify PyTorch CUDA Compatibility:**
```bash
# Reinstall PyTorch with correct CUDA version
pip uninstall torch torchvision
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
```

**4. Set CUDA Environment Variables:**
```bash
# Add to ~/.bashrc or ~/.zshrc
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# Reload shell
source ~/.bashrc
```

---

### Problem: Out of GPU Memory

**Symptoms:**
```
RuntimeError: CUDA out of memory. Tried to allocate 2.00 GiB
```

**Solutions:**

**1. Reduce Batch Size:**
```python
# config.yaml
processing:
  batch_size: 8  # Reduce from 16 or 32
```

**2. Use Mixed Precision:**
```python
from torch.cuda.amp import autocast

with autocast():
    output = model(input)
```

**3. Clear GPU Cache:**
```python
import torch

# Free unused GPU memory
torch.cuda.empty_cache()

# Check GPU memory usage
print(torch.cuda.memory_summary())
```

**4. Use Gradient Checkpointing:**
```python
# For training only
model.gradient_checkpointing_enable()
```

**5. Use Smaller Model:**
```yaml
# config.yaml
fire_detection:
  model: yolov8n  # Use nano instead of medium/large
```

---

### Problem: CUDA Version Mismatch

**Symptoms:**
```
The detected CUDA version (12.2) mismatches the version that was used to compile PyTorch (11.8)
```

**Solutions:**

```bash
# Option 1: Install PyTorch matching your CUDA
pip uninstall torch torchvision
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# Option 2: Downgrade CUDA to match PyTorch
# (Not recommended - complex process)

# Option 3: Use Docker with matching versions
docker pull pytorch/pytorch:2.1.0-cuda11.8-cudnn8-runtime
```

---

## Model Loading Errors

### Problem: Model File Not Found

**Symptoms:**
```
FileNotFoundError: [Errno 2] No such file or directory: 'models/yolov8_fire.pt'
```

**Solutions:**

```bash
# 1. Download models
python download_models.py --all

# 2. Verify models exist
ls -lh models/
# Should show:
# yolov8_fire.pt
# timesformer_smoke.pt
# resnet50_vegetation.pt
# yolov8_fauna.pt
# fire_spread_net.pt

# 3. Check model paths in config
cat config/model_config.yaml

# 4. Set absolute paths if needed
export FIRE_MODEL_PATH=/absolute/path/to/models/yolov8_fire.pt
```

---

### Problem: Model Loading Fails with RuntimeError

**Symptoms:**
```
RuntimeError: Error(s) in loading state_dict for YOLOv8
```

**Solutions:**

**1. Version Mismatch:**
```bash
# Check ultralytics version
pip show ultralytics

# Reinstall specific version
pip install ultralytics==8.0.200
```

**2. Corrupted Model File:**
```bash
# Re-download model
rm models/yolov8_fire.pt
python download_models.py --model fire

# Verify file integrity
md5sum models/yolov8_fire.pt
```

**3. GPU/CPU Loading Issue:**
```python
# Load model on CPU if GPU unavailable
import torch

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = torch.load("models/yolov8_fire.pt", map_location=device)
```

---

## Database Connection Issues

### Problem: Cannot Connect to PostgreSQL

**Symptoms:**
```
psycopg2.OperationalError: could not connect to server: Connection refused
```

**Solutions:**

**1. Check PostgreSQL Service:**
```bash
# Ubuntu/Debian
sudo systemctl status postgresql

# Start if not running
sudo systemctl start postgresql

# Enable on boot
sudo systemctl enable postgresql
```

**2. Check Connection String:**
```bash
# Format: postgresql://user:password@host:port/database
# Example: postgresql://guira:password@localhost:5432/guira

# Test connection
psql -h localhost -U guira -d guira

# If prompted for password, enter it
```

**3. Create Database and User:**
```bash
# Switch to postgres user
sudo -u postgres psql

# Create user and database
CREATE USER guira WITH PASSWORD 'your_password';
CREATE DATABASE guira OWNER guira;

# Enable PostGIS
\c guira
CREATE EXTENSION postgis;

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE guira TO guira;

# Exit
\q
```

**4. Configure PostgreSQL to Accept Connections:**
```bash
# Edit pg_hba.conf
sudo nano /etc/postgresql/15/main/pg_hba.conf

# Add line (for local development):
host    all             all             127.0.0.1/32            md5

# Restart PostgreSQL
sudo systemctl restart postgresql
```

---

### Problem: PostGIS Extension Not Available

**Symptoms:**
```
ERROR: could not open extension control file "/usr/share/postgresql/15/extension/postgis.control"
```

**Solutions:**

```bash
# Ubuntu/Debian
sudo apt-get install -y postgis postgresql-15-postgis-3

# macOS
brew install postgis

# Verify installation
sudo -u postgres psql -c "SELECT PostGIS_version();"
```

---

### Problem: Redis Connection Failed

**Symptoms:**
```
redis.exceptions.ConnectionError: Error 111 connecting to localhost:6379. Connection refused.
```

**Solutions:**

```bash
# Check Redis service
sudo systemctl status redis-server

# Start Redis
sudo systemctl start redis-server

# Test connection
redis-cli ping
# Should return: PONG

# Check Redis configuration
redis-cli config get bind
# Should show: 127.0.0.1 (for local)

# For remote connections, edit redis.conf
sudo nano /etc/redis/redis.conf
# Change: bind 127.0.0.1 to bind 0.0.0.0
# Then restart: sudo systemctl restart redis-server
```

---

## Performance Problems

### Problem: Slow Inference Speed

**Symptoms:**
- Detection takes >1 second per frame
- GPU utilization low (<50%)

**Solutions:**

**1. Batch Processing:**
```python
# Process multiple frames at once
images = [frame1, frame2, frame3, ...]
results = model.predict(images, batch=len(images))
```

**2. Model Optimization:**
```bash
# Export to TensorRT for faster inference
python export_tensorrt.py --model yolov8_fire.pt --batch-size 8

# Use optimized model
model = torch.jit.load("yolov8_fire_tensorrt.pt")
```

**3. Mixed Precision:**
```python
# config.yaml
processing:
  mixed_precision: true
```

**4. Reduce Input Size:**
```yaml
# config.yaml
fire_detection:
  input_size: 416  # Reduce from 640
```

**5. Use Lighter Model:**
```yaml
fire_detection:
  model: yolov8n  # Nano (fastest)
  # yolov8s = Small
  # yolov8m = Medium
  # yolov8l = Large (slowest but most accurate)
```

---

### Problem: High CPU Usage

**Symptoms:**
- CPU at 100% constantly
- System slowdown

**Solutions:**

**1. Reduce Worker Processes:**
```yaml
# config.yaml
api:
  workers: 2  # Reduce from 4 or 8
```

**2. Optimize Data Loading:**
```python
# Use fewer DataLoader workers
train_loader = DataLoader(
    dataset,
    batch_size=16,
    num_workers=2,  # Reduce from 4 or 8
    pin_memory=True
)
```

**3. Profile CPU Usage:**
```bash
# Find CPU-intensive processes
top -o %CPU

# Profile Python code
python -m cProfile -o profile.stats api/main.py
python -m pstats profile.stats
```

---

## API Errors

### Problem: FastAPI Server Won't Start

**Symptoms:**
```
ERROR: [Errno 98] Address already in use
```

**Solutions:**

```bash
# Find process using port 8000
lsof -i :8000

# Kill the process
kill -9 <PID>

# Or use different port
uvicorn api.main:app --port 8001
```

---

### Problem: API Returns 500 Internal Server Error

**Symptoms:**
```json
{"detail": "Internal Server Error"}
```

**Solutions:**

**1. Check API Logs:**
```bash
# Docker
docker logs guira-api

# Kubernetes
kubectl logs -n guira guira-api-xxx

# Local
tail -f logs/guira.log
```

**2. Enable Debug Mode:**
```python
# api/main.py
app = FastAPI(debug=True)

# Or via environment
DEBUG=true uvicorn api.main:app --reload
```

**3. Check Database Connection:**
```python
# Test database connectivity
from sqlalchemy import create_engine

engine = create_engine(DATABASE_URL)
conn = engine.connect()
print("Database connected!")
```

---

### Problem: API Endpoint Not Found (404)

**Symptoms:**
```json
{"detail": "Not Found"}
```

**Solutions:**

**1. Verify Endpoint Path:**
```bash
# List all routes
curl http://localhost:8000/docs

# Check OpenAPI spec
curl http://localhost:8000/openapi.json
```

**2. Check Router Registration:**
```python
# api/main.py
from api.routers import detection, simulation

app.include_router(detection.router, prefix="/api/v1")
app.include_router(simulation.router, prefix="/api/v1")
```

---

## Docker & Container Issues

### Problem: Docker Cannot Access GPU

**Symptoms:**
```
docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]
```

**Solutions:**

**1. Install NVIDIA Container Toolkit:**
```bash
# Ubuntu/Debian
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Restart Docker
sudo systemctl restart docker
```

**2. Verify GPU Access:**
```bash
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

---

### Problem: Docker Build Fails

**Symptoms:**
```
ERROR [internal] load metadata for docker.io/nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04
```

**Solutions:**

```bash
# Login to Docker Hub (if using private images)
docker login

# Pull base image separately
docker pull nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Build with --no-cache
docker build --no-cache -t guira:latest .

# Build with increased memory
docker build --memory=8g -t guira:latest .
```

---

### Problem: Docker Container Crashes on Startup

**Symptoms:**
```
Container exited with code 137 (Out of Memory)
```

**Solutions:**

**1. Increase Container Memory:**
```bash
# Docker run
docker run --memory=16g --memory-swap=32g guira:latest

# Docker Compose
services:
  api:
    deploy:
      resources:
        limits:
          memory: 16G
```

**2. Check Container Logs:**
```bash
docker logs guira-api
docker logs --tail=100 guira-api
```

---

## Geospatial Processing Errors

### Problem: DEM File Not Loading

**Symptoms:**
```
rasterio.errors.RasterioIOError: No such file or directory: 'data/dem/elevation.tif'
```

**Solutions:**

**1. Download DEM Data:**
```bash
# Create DEM directory
mkdir -p data/dem

# Download from USGS Earth Explorer or OpenTopography
# Or use sample DEM
wget https://example.com/sample_dem.tif -O data/dem/elevation.tif
```

**2. Verify DEM Format:**
```python
import rasterio

with rasterio.open("data/dem/elevation.tif") as src:
    print(f"CRS: {src.crs}")
    print(f"Bounds: {src.bounds}")
    print(f"Shape: {src.shape}")
```

---

### Problem: Coordinate Projection Errors

**Symptoms:**
```
pyproj.exceptions.CRSError: Invalid projection
```

**Solutions:**

**1. Verify Coordinate System:**
```python
from pyproj import CRS

# Check CRS validity
crs = CRS.from_epsg(4326)  # WGS84
print(crs.is_valid)
```

**2. Update PROJ Database:**
```bash
# Ubuntu/Debian
sudo apt-get install proj-bin proj-data

# Or update via conda
conda install -c conda-forge proj
```

---

## Memory Issues

### Problem: Python Process Killed (OOM)

**Symptoms:**
```
Killed
```

**Solutions:**

**1. Monitor Memory Usage:**
```bash
# Watch memory in real-time
watch -n 1 free -h

# Profile memory
python -m memory_profiler code/api/main.py
```

**2. Reduce Memory Consumption:**
```python
# Process data in chunks
def process_large_dataset(dataset_path):
    chunk_size = 1000
    for chunk in pd.read_csv(dataset_path, chunksize=chunk_size):
        process_chunk(chunk)
        # Explicitly free memory
        del chunk
        gc.collect()
```

**3. Use Generator for Large Files:**
```python
def read_large_file(file_path):
    with open(file_path) as f:
        for line in f:
            yield line  # Yield instead of loading all at once
```

**4. Increase Swap Space:**
```bash
# Create 8GB swap file
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## Getting Additional Help

### Before Asking for Help

**1. Search Existing Issues:**
- Check [GitHub Issues](https://github.com/THEDIFY/THEDIFY/issues)
- Search for similar problems

**2. Gather Information:**
```bash
# System information
uname -a
python --version
pip list | grep torch
nvidia-smi

# Error logs
cat logs/guira.log | tail -100

# Configuration
cat .env
cat config/model_config.yaml
```

**3. Create Minimal Reproducible Example:**
```python
# minimal_example.py
import torch
from detection.fire_detection import FireDetector

# Simplified code that reproduces the error
detector = FireDetector()
# ... your code that causes the error
```

---

### How to Report Issues

**Create a GitHub Issue with:**

```markdown
### Environment
- OS: Ubuntu 22.04
- Python: 3.11.0
- PyTorch: 2.1.0
- CUDA: 11.8
- GPU: NVIDIA RTX 3080

### Description
[Clear description of the problem]

### Steps to Reproduce
1. [First step]
2. [Second step]
3. [Error occurs]

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Error Message
```
[Full error traceback]
```

### Additional Context
[Any other relevant information]
```

---

### Contact Support

**Community Support:**
- 💬 [GitHub Discussions](https://github.com/THEDIFY/THEDIFY/discussions)
- 📖 [Documentation](documentation/)

**Direct Support:**
- 📧 Email: rasanti2008@gmail.com
- 🐛 [Report Bug](https://github.com/THEDIFY/THEDIFY/issues/new)

**Response Time:**
- Community: 24-48 hours
- Direct email: 2-5 business days
- Critical issues: Prioritized

---

## FAQ

**Q: Can I run GUIRA without a GPU?**
A: Yes, but performance will be significantly slower. Use smaller models and reduce batch sizes.

**Q: Which Python version is required?**
A: Python 3.11+ is required. Python 3.12 is also supported.

**Q: How much GPU memory do I need?**
A: Minimum 6GB (with small models), recommended 10GB+ for production.

**Q: Can I use AMD GPUs?**
A: PyTorch supports ROCm for AMD GPUs, but NVIDIA GPUs are recommended and better tested.

**Q: How do I update to the latest version?**
```bash
git pull origin main
pip install -r requirements.txt --upgrade
```

**Q: Where are logs stored?**
A: Default location is `logs/guira.log`. Configure in `.env` with `LOG_FILE`.

**Q: How do I reset the database?**
```bash
sudo -u postgres psql -c "DROP DATABASE guira;"
sudo -u postgres psql -c "CREATE DATABASE guira OWNER guira;"
./scripts/init_database.sh
```

---

<div align="center">

**Still Having Issues?**

Don't hesitate to reach out! We're here to help. 💚

<img src="https://user-images.githubusercontent.com/74038190/212284100-561aa473-3905-4a80-b561-0d28506553ee.gif" width="100%">

**Version:** 0.4.0  
**Last Updated:** December 2025

</div>
