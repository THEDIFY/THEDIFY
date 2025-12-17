# Deployment Guide

Complete guide for deploying Axolotl in various environments.

## Table of Contents
- [Deployment Options](#deployment-options)
- [Local Development](#local-development)
- [Docker Deployment](#docker-deployment)
- [Production Deployment](#production-deployment)
- [Azure Cloud Deployment](#azure-cloud-deployment)
- [Edge Deployment](#edge-deployment)
- [Configuration](#configuration)
- [Monitoring](#monitoring)
- [Backup & Recovery](#backup--recovery)

---

## Deployment Options

| Environment | Use Case | Complexity | Cost |
|-------------|----------|------------|------|
| **Local Dev** | Development and testing | Low | Free |
| **Docker** | Consistent local/staging | Low | Free |
| **Cloud (Azure)** | Production at scale | Medium | $$$ |
| **Edge** | Offline/low-latency | Medium | $ |

---

## Local Development

### Quick Start

```bash
# Clone repository
git clone https://github.com/THEDIFY/THEDIFY.git
cd THEDIFY/projects/Axolotl

# Install dependencies
pip install -r code/requirements.txt

# Set up environment
cp .env.example .env
# Edit .env as needed

# Start services
redis-server &
python app/backend/app.py
```

### Manual Setup (Detailed)

#### 1. Install Prerequisites

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y python3.11 python3-pip redis-server
```

**macOS:**
```bash
brew install python@3.11 redis
```

**Windows:**
- Install Python 3.11 from python.org
- Install Redis from GitHub releases or use WSL

#### 2. Create Virtual Environment

```bash
python3.11 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

#### 3. Install Python Dependencies

```bash
pip install --upgrade pip
pip install -r code/requirements.txt
```

#### 4. Set Up Database

**SQLite (Development):**
```bash
# Already included, no setup needed
export DATABASE_URL="sqlite:///data/axolotl.db"
```

**PostgreSQL (Recommended for production-like dev):**
```bash
# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Create database
sudo -u postgres createdb axolotl
sudo -u postgres createuser axolotl_user -P

# Set environment variable
export DATABASE_URL="postgresql://axolotl_user:password@localhost/axolotl"
```

#### 5. Initialize Database

```bash
# Run migrations
python app/backend/migrate.py upgrade
```

#### 6. Start Services

**Terminal 1 - Redis:**
```bash
redis-server
```

**Terminal 2 - Web Application:**
```bash
cd app/backend
python app.py
```

**Terminal 3 - GPU Worker:**
```bash
cd app/backend
python worker.py
```

**Terminal 4 - Frontend (Optional):**
```bash
cd app/frontend
npm install
npm run dev
```

#### 7. Verify Installation

```bash
curl http://localhost:8080/health
# Expected: {"status":"ok"}
```

---

## Docker Deployment

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- NVIDIA Container Runtime (for GPU support)

### Quick Start

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

### GPU Support

#### Install NVIDIA Container Runtime

**Ubuntu:**
```bash
# Add NVIDIA repository
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install nvidia-container-runtime
sudo apt-get update
sudo apt-get install -y nvidia-container-runtime

# Restart Docker
sudo systemctl restart docker
```

#### Enable GPU in Docker Compose

```yaml
# docker-compose.yml
services:
  worker:
    image: axolotl-worker:latest
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

### Production Docker Setup

```bash
# Build production image
docker build -t axolotl:latest -f code/Dockerfile .

# Run with production settings
docker run -d \
  --name axolotl-web \
  -p 8080:8080 \
  --env-file .env.production \
  -v /data/axolotl:/app/data \
  -v /storage/videos:/app/storage \
  axolotl:latest

# Run GPU worker
docker run -d \
  --name axolotl-worker \
  --gpus all \
  --env-file .env.production \
  -v /data/axolotl:/app/data \
  -v /storage/videos:/app/storage \
  axolotl:latest \
  python worker.py
```

### Docker Compose Production

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    restart: always
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes

  postgres:
    image: postgres:15-alpine
    restart: always
    environment:
      POSTGRES_DB: axolotl
      POSTGRES_USER: axolotl
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    secrets:
      - db_password

  web:
    image: axolotl:latest
    restart: always
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: postgresql://axolotl:${DB_PASSWORD}@postgres:5432/axolotl
      REDIS_URL: redis://redis:6379/0
    depends_on:
      - redis
      - postgres
    volumes:
      - video_storage:/app/storage
      - logs:/app/logs

  worker:
    image: axolotl:latest
    restart: always
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    environment:
      DATABASE_URL: postgresql://axolotl:${DB_PASSWORD}@postgres:5432/axolotl
      REDIS_URL: redis://redis:6379/0
    depends_on:
      - redis
      - postgres
    volumes:
      - video_storage:/app/storage
      - models:/app/models
    command: python worker.py

volumes:
  redis_data:
  postgres_data:
  video_storage:
  logs:
  models:

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

---

## Production Deployment

### Infrastructure Requirements

**Minimum:**
- 4 CPU cores
- 16 GB RAM
- 100 GB SSD storage
- NVIDIA GPU (8GB+ VRAM)
- 100 Mbps network

**Recommended:**
- 8+ CPU cores
- 32 GB RAM
- 500 GB SSD storage
- NVIDIA RTX 3090 / A100 GPU
- 1 Gbps network

### Production Checklist

- [ ] Use PostgreSQL (not SQLite)
- [ ] Enable HTTPS/TLS
- [ ] Set up proper firewall rules
- [ ] Configure backup strategy
- [ ] Set up monitoring (Prometheus + Grafana)
- [ ] Configure log aggregation
- [ ] Enable rate limiting
- [ ] Use environment variables for secrets
- [ ] Set up CI/CD pipeline
- [ ] Configure auto-scaling (if using cloud)
- [ ] Set up load balancer
- [ ] Configure CDN for static assets

---

## Azure Cloud Deployment

### Architecture

```
Azure Front Door (CDN + WAF)
    ↓
Azure Load Balancer
    ↓
Azure Kubernetes Service (AKS)
    ├── Web Pods (3+ replicas)
    ├── Worker Pods (2+ GPU nodes)
    └── Redis Cache
    
Azure PostgreSQL (Managed)
Azure Blob Storage (Videos)
Azure Cognitive Search (RAG)
Azure OpenAI (GPT-4)
```

### Step-by-Step Deployment

#### 1. Provision Azure Resources

```bash
# Set variables
RESOURCE_GROUP="axolotl-prod"
LOCATION="eastus"
AKS_NAME="axolotl-aks"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster with GPU nodes
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count 3 \
  --vm-set-type VirtualMachineScaleSets \
  --enable-cluster-autoscaler \
  --min-count 3 \
  --max-count 10 \
  --node-vm-size Standard_NC6s_v3  # GPU nodes

# Get credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
```

#### 2. Create PostgreSQL Database

```bash
# Create PostgreSQL server
az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name axolotl-db \
  --location $LOCATION \
  --admin-user axolotl_admin \
  --admin-password <strong_password> \
  --sku-name Standard_D2s_v3 \
  --tier GeneralPurpose \
  --version 15 \
  --storage-size 128

# Create database
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name axolotl-db \
  --database-name axolotl
```

#### 3. Create Blob Storage

```bash
# Create storage account
az storage account create \
  --name axolotlstorage \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

# Create container for videos
az storage container create \
  --name videos \
  --account-name axolotlstorage \
  --public-access off
```

#### 4. Deploy to AKS

```bash
# Create Kubernetes secrets
kubectl create secret generic axolotl-secrets \
  --from-literal=database-url="postgresql://..." \
  --from-literal=azure-storage-connection="..." \
  --from-literal=azure-openai-key="..."

# Deploy application
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

**Kubernetes Deployment Example (k8s/deployment.yaml):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: axolotl-web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: axolotl-web
  template:
    metadata:
      labels:
        app: axolotl-web
    spec:
      containers:
      - name: web
        image: axolotl:latest
        ports:
        - containerPort: 8080
        envFrom:
        - secretRef:
            name: axolotl-secrets
        resources:
          requests:
            memory: "4Gi"
            cpu: "2"
          limits:
            memory: "8Gi"
            cpu: "4"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: axolotl-worker
spec:
  replicas: 2
  selector:
    matchLabels:
      app: axolotl-worker
  template:
    metadata:
      labels:
        app: axolotl-worker
    spec:
      nodeSelector:
        accelerator: nvidia-gpu
      containers:
      - name: worker
        image: axolotl:latest
        command: ["python", "worker.py"]
        envFrom:
        - secretRef:
            name: axolotl-secrets
        resources:
          limits:
            nvidia.com/gpu: 1
            memory: "16Gi"
            cpu: "4"
```

---

## Edge Deployment

Deploy Axolotl on edge devices (Raspberry Pi, NVIDIA Jetson, Intel NUC) for offline operation.

### Supported Edge Devices

| Device | CPU | RAM | GPU | Suitability |
|--------|-----|-----|-----|-------------|
| Raspberry Pi 4 (8GB) | ARM Cortex-A72 | 8GB | None | Basic tracking only |
| NVIDIA Jetson Nano | ARM Cortex-A57 | 4GB | 128 CUDA cores | Light processing |
| NVIDIA Jetson Xavier NX | ARM v8.2 | 8GB | 384 CUDA cores | Full processing |
| Intel NUC + GPU | Intel i7 | 32GB | External GPU | Full processing |

### Edge Installation

```bash
# Install dependencies (Jetson example)
sudo apt update
sudo apt install -y python3-pip redis-server

# Install PyTorch for Jetson
pip3 install torch torchvision --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v50

# Install Axolotl
git clone https://github.com/THEDIFY/THEDIFY.git
cd THEDIFY/projects/Axolotl
pip3 install -r code/requirements.txt

# Use lightweight models
export YOLO_MODEL="yolov8n"  # Nano version for edge
export ENABLE_SMPL="false"   # Disable heavy 3D fitting

# Start services
./scripts/start_edge.sh
```

---

## Configuration

### Environment Variables

**Required:**
```bash
DATABASE_URL=postgresql://user:pass@host:5432/axolotl
REDIS_URL=redis://localhost:6379/0
```

**Optional:**
```bash
# Azure Services
AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;...
AZURE_OPENAI_API_KEY=your_key_here
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_SEARCH_ENDPOINT=https://your-search.search.windows.net
AZURE_SEARCH_KEY=your_search_key

# Application Settings
PORT=8080
FLASK_ENV=production
LOG_LEVEL=INFO
MAX_VIDEO_SIZE_MB=500

# GPU Settings
GPU_ENABLED=true
CUDA_VISIBLE_DEVICES=0

# Performance
WORKER_CONCURRENCY=2
REDIS_MAX_CONNECTIONS=50
DB_POOL_SIZE=20
```

---

## Monitoring

### Prometheus + Grafana Setup

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards

volumes:
  prometheus_data:
  grafana_data:
```

### Key Metrics to Monitor

- **Application Metrics:**
  - Request rate (req/s)
  - Response time (p50, p95, p99)
  - Error rate (%)
  - Active WebSocket connections

- **Processing Metrics:**
  - Video processing time
  - Queue depth
  - GPU utilization
  - Worker availability

- **System Metrics:**
  - CPU usage
  - Memory usage
  - Disk I/O
  - Network throughput

---

## Backup & Recovery

### Database Backups

```bash
# Automated daily backups
# Add to cron: 0 2 * * * /path/to/backup_db.sh

#!/bin/bash
# backup_db.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/postgres"
DB_NAME="axolotl"

# Create backup
pg_dump $DB_NAME | gzip > "$BACKUP_DIR/axolotl_$DATE.sql.gz"

# Keep only last 30 days
find $BACKUP_DIR -name "axolotl_*.sql.gz" -mtime +30 -delete

# Upload to Azure Blob Storage (optional)
az storage blob upload \
  --container-name backups \
  --file "$BACKUP_DIR/axolotl_$DATE.sql.gz" \
  --name "postgres/axolotl_$DATE.sql.gz"
```

### Video Storage Backup

```bash
# Sync to Azure Blob Storage
azcopy sync "/storage/videos" \
  "https://axolotlstorage.blob.core.windows.net/videos" \
  --recursive
```

### Disaster Recovery

**Recovery Time Objective (RTO):** < 4 hours  
**Recovery Point Objective (RPO):** < 24 hours

**Recovery Steps:**
1. Provision new infrastructure
2. Restore latest database backup
3. Sync video storage from backup
4. Deploy application
5. Verify functionality
6. Update DNS

---

## Security Hardening

### Firewall Configuration

```bash
# Allow only necessary ports
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### SSL/TLS Configuration

```bash
# Using Let's Encrypt with Certbot
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d axolotl.yourdomain.com
```

### Regular Updates

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Python dependencies
pip install --upgrade -r code/requirements.txt

# Update Docker images
docker compose pull
docker compose up -d
```

---

## Related Documentation

- [Architecture Overview](ARCHITECTURE.md)
- [Configuration Guide](documentation/getting-started/configuration.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Monitoring Guide](documentation/deployment/monitoring.md)
