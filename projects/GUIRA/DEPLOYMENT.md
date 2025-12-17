# GUIRA - Deployment Guide

<div align="center">

![Deployment](https://img.shields.io/badge/Deployment-Production%20Ready-success?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-Supported-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)

**Complete Deployment & Operations Guide**

</div>

---

## Table of Contents

1. [Infrastructure Requirements](#infrastructure-requirements)
2. [Local Development Deployment](#local-development-deployment)
3. [Docker Deployment](#docker-deployment)
4. [Kubernetes Deployment](#kubernetes-deployment)
5. [Cloud Deployment](#cloud-deployment)
6. [Configuration Management](#configuration-management)
7. [Database Setup](#database-setup)
8. [Model Deployment](#model-deployment)
9. [Monitoring & Logging](#monitoring--logging)
10. [Backup & Recovery](#backup--recovery)
11. [Performance Tuning](#performance-tuning)
12. [Security Hardening](#security-hardening)
13. [Troubleshooting](#troubleshooting)

---

## Infrastructure Requirements

### Minimum Requirements

**Development Environment:**
- **CPU:** Intel i5 or AMD Ryzen 5 (4 cores)
- **RAM:** 16GB
- **GPU:** NVIDIA GTX 1660 Ti (6GB VRAM)
- **Storage:** 500GB SSD
- **OS:** Ubuntu 20.04+ or Windows 10+ with WSL2

**Production Environment:**
- **CPU:** Intel Xeon or AMD EPYC (16+ cores)
- **RAM:** 64GB+
- **GPU:** NVIDIA RTX 3080/4080 or A100 (10GB+ VRAM)
- **Storage:** 2TB NVMe SSD
- **OS:** Ubuntu 22.04 LTS Server

### Recommended Cloud Resources

**Azure (Recommended):**
```yaml
Virtual Machine:
  Type: Standard_NC12s_v3
  vCPUs: 12
  RAM: 112 GB
  GPU: 2x Tesla K80
  Storage: 1TB Premium SSD
  Cost: ~$2.50/hour

Alternative (GPU Optimized):
  Type: Standard_NC6s_v3
  vCPUs: 6
  RAM: 112 GB
  GPU: 1x Tesla V100
  Storage: 1TB Premium SSD
  Cost: ~$3.50/hour
```

**AWS:**
```yaml
Instance Type: p3.2xlarge
  vCPUs: 8
  RAM: 61 GB
  GPU: 1x Tesla V100
  Storage: 1TB EBS SSD
  Cost: ~$3.06/hour
```

**Google Cloud:**
```yaml
Machine Type: n1-standard-8 + 1x Tesla T4
  vCPUs: 8
  RAM: 30 GB
  GPU: 1x Tesla T4
  Storage: 1TB Persistent SSD
  Cost: ~$1.50/hour
```

---

## Local Development Deployment

### Quick Start

```bash
# 1. Clone repository
git clone https://github.com/THEDIFY/THEDIFY.git
cd THEDIFY/projects/GUIRA

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. Install dependencies
cd code
pip install -r requirements.txt

# 4. Install system dependencies
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
    gdal-bin \
    libgdal-dev \
    postgresql \
    postgresql-contrib \
    postgis \
    redis-server

# macOS
brew install gdal postgresql@15 postgis redis

# 5. Start services
sudo systemctl start postgresql
sudo systemctl start redis-server

# 6. Initialize database
./scripts/init_database.sh

# 7. Download model weights
python download_models.py --all

# 8. Start API server
uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

### Development Environment Variables

Create `.env.development`:

```bash
# Environment
ENV=development
DEBUG=true

# Database
DATABASE_URL=postgresql://guira_dev:dev_password@localhost:5432/guira_dev
REDIS_URL=redis://localhost:6379/0

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4

# Model Paths
MODELS_DIR=../models
DATA_DIR=../data
OUTPUT_DIR=../outputs

# Logging
LOG_LEVEL=DEBUG
LOG_FILE=../logs/guira_dev.log

# API Keys (Development - Use test keys)
WEATHER_API_KEY=test_weather_key
SATELLITE_API_KEY=test_satellite_key

# Processing
FRAME_BUFFER_SIZE=30
DETECTION_CONFIDENCE=0.60
ALERT_THRESHOLD=0.70
```

---

## Docker Deployment

### Single Container Deployment

**Dockerfile:**

```dockerfile
# Use NVIDIA CUDA base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3-pip \
    gdal-bin \
    libgdal-dev \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY code/requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy application code
COPY code/ .
COPY models/ /app/models/
COPY config/ /app/config/

# Create necessary directories
RUN mkdir -p /app/data /app/outputs /app/logs

# Expose API port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python3 -c "import requests; requests.get('http://localhost:8000/health')"

# Start application
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Build and Run:**

```bash
# Build image
docker build -t guira:latest .

# Run container
docker run -d \
    --name guira-api \
    --gpus all \
    -p 8000:8000 \
    -v $(pwd)/data:/app/data \
    -v $(pwd)/outputs:/app/outputs \
    -v $(pwd)/logs:/app/logs \
    --env-file .env.production \
    guira:latest

# View logs
docker logs -f guira-api

# Stop container
docker stop guira-api

# Remove container
docker rm guira-api
```

### Docker Compose Deployment

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgis/postgis:15-3.3
    container_name: guira-postgres
    environment:
      POSTGRES_USER: guira
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: guira
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init_db.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U guira"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: guira-redis
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # FastAPI Application
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: guira-api
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://guira:${DB_PASSWORD}@postgres:5432/guira
      REDIS_URL: redis://redis:6379/0
    volumes:
      - ./models:/app/models
      - ./data:/app/data
      - ./outputs:/app/outputs
      - ./logs:/app/logs
    ports:
      - "8000:8000"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped

  # Celery Worker (Fire Detection)
  worker-fire:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: guira-worker-fire
    command: celery -A tasks.celery_app worker -Q fire_detection -n fire@%h --loglevel=info
    depends_on:
      - redis
      - postgres
    environment:
      DATABASE_URL: postgresql://guira:${DB_PASSWORD}@postgres:5432/guira
      REDIS_URL: redis://redis:6379/0
    volumes:
      - ./models:/app/models
      - ./data:/app/data
      - ./outputs:/app/outputs
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    restart: unless-stopped

  # Celery Worker (Smoke Detection)
  worker-smoke:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: guira-worker-smoke
    command: celery -A tasks.celery_app worker -Q smoke_detection -n smoke@%h --loglevel=info
    depends_on:
      - redis
      - postgres
    environment:
      DATABASE_URL: postgresql://guira:${DB_PASSWORD}@postgres:5432/guira
      REDIS_URL: redis://redis:6379/0
    volumes:
      - ./models:/app/models
      - ./data:/app/data
      - ./outputs:/app/outputs
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    restart: unless-stopped

  # NGINX Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: guira-nginx
    depends_on:
      - api
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    ports:
      - "80:80"
      - "443:443"
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

**Start Services:**

```bash
# Create .env file
echo "DB_PASSWORD=your_secure_password" > .env

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

---

## Kubernetes Deployment

### Prerequisites

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify Helm
helm version
```

### Namespace Creation

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: guira
  labels:
    name: guira
    environment: production
```

```bash
kubectl apply -f k8s/namespace.yaml
```

### ConfigMap & Secrets

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: guira-config
  namespace: guira
data:
  API_HOST: "0.0.0.0"
  API_PORT: "8000"
  LOG_LEVEL: "INFO"
  FRAME_BUFFER_SIZE: "30"
  DETECTION_CONFIDENCE: "0.65"
  ALERT_THRESHOLD: "0.75"
```

```yaml
# secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: guira-secrets
  namespace: guira
type: Opaque
stringData:
  DATABASE_URL: "postgresql://guira:PASSWORD@postgres-service:5432/guira"
  REDIS_URL: "redis://redis-service:6379/0"
  WEATHER_API_KEY: "your_weather_api_key"
  SATELLITE_API_KEY: "your_satellite_api_key"
```

```bash
# Apply configurations
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
```

### Persistent Volumes

```yaml
# persistent-volumes.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: guira-models-pv
  namespace: guira
spec:
  capacity:
    storage: 50Gi
  volumeMode: Filesystem
  accessModes:
    - ReadOnlyMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: fast-ssd
  hostPath:
    path: /mnt/guira/models
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: guira-models-pvc
  namespace: guira
spec:
  accessModes:
    - ReadOnlyMany
  volumeMode: Filesystem
  resources:
    requests:
      storage: 50Gi
  storageClassName: fast-ssd
```

### Deployments

**API Deployment:**

```yaml
# api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: guira-api
  namespace: guira
  labels:
    app: guira-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: guira-api
  template:
    metadata:
      labels:
        app: guira-api
    spec:
      containers:
      - name: api
        image: guira:latest
        ports:
        - containerPort: 8000
          name: http
        envFrom:
        - configMapRef:
            name: guira-config
        - secretRef:
            name: guira-secrets
        volumeMounts:
        - name: models
          mountPath: /app/models
          readOnly: true
        resources:
          requests:
            memory: "4Gi"
            cpu: "2"
          limits:
            memory: "8Gi"
            cpu: "4"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: models
        persistentVolumeClaim:
          claimName: guira-models-pvc
```

**GPU Worker Deployment:**

```yaml
# gpu-worker-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: guira-fire-worker
  namespace: guira
spec:
  replicas: 2
  selector:
    matchLabels:
      app: guira-fire-worker
  template:
    metadata:
      labels:
        app: guira-fire-worker
    spec:
      containers:
      - name: worker
        image: guira:latest
        command: ["celery"]
        args: ["-A", "tasks.celery_app", "worker", "-Q", "fire_detection", "-n", "fire@%h", "--loglevel=info"]
        envFrom:
        - configMapRef:
            name: guira-config
        - secretRef:
            name: guira-secrets
        volumeMounts:
        - name: models
          mountPath: /app/models
          readOnly: true
        resources:
          requests:
            memory: "16Gi"
            cpu: "4"
            nvidia.com/gpu: "1"
          limits:
            memory: "24Gi"
            cpu: "8"
            nvidia.com/gpu: "1"
      volumes:
      - name: models
        persistentVolumeClaim:
          claimName: guira-models-pvc
      nodeSelector:
        accelerator: nvidia-gpu
```

### Services

```yaml
# services.yaml
apiVersion: v1
kind: Service
metadata:
  name: guira-api-service
  namespace: guira
spec:
  type: LoadBalancer
  selector:
    app: guira-api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
    name: http
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: guira
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
  clusterIP: None
---
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  namespace: guira
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
```

### Ingress

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: guira-ingress
  namespace: guira
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - api.guira.example.com
    secretName: guira-tls
  rules:
  - host: api.guira.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: guira-api-service
            port:
              number: 80
```

### Horizontal Pod Autoscaler

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: guira-api-hpa
  namespace: guira
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: guira-api
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Deploy to Kubernetes

```bash
# Apply all configurations
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/persistent-volumes.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/api-deployment.yaml
kubectl apply -f k8s/gpu-worker-deployment.yaml
kubectl apply -f k8s/services.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/hpa.yaml

# Check deployment status
kubectl get pods -n guira
kubectl get services -n guira
kubectl get ingress -n guira

# View logs
kubectl logs -n guira -l app=guira-api --tail=100 -f

# Scale deployment
kubectl scale deployment guira-api -n guira --replicas=5

# Check pod autoscaling
kubectl get hpa -n guira
```

---

## Cloud Deployment

### Azure Deployment

**1. Create Azure Resources:**

```bash
# Login to Azure
az login

# Create resource group
az group create --name guira-rg --location eastus

# Create AKS cluster
az aks create \
    --resource-group guira-rg \
    --name guira-cluster \
    --node-count 3 \
    --node-vm-size Standard_NC6s_v3 \
    --enable-addons monitoring \
    --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group guira-rg --name guira-cluster

# Create Azure Database for PostgreSQL
az postgres flexible-server create \
    --resource-group guira-rg \
    --name guira-postgres \
    --location eastus \
    --admin-user guiraadmin \
    --admin-password YourSecurePassword \
    --sku-name Standard_D2s_v3 \
    --version 15

# Enable PostGIS
az postgres flexible-server parameter set \
    --resource-group guira-rg \
    --server-name guira-postgres \
    --name shared_preload_libraries \
    --value postgis

# Create Azure Cache for Redis
az redis create \
    --resource-group guira-rg \
    --name guira-redis \
    --location eastus \
    --sku Standard \
    --vm-size c1

# Create Azure Container Registry
az acr create \
    --resource-group guira-rg \
    --name guiraregistry \
    --sku Premium

# Build and push image
az acr build \
    --registry guiraregistry \
    --image guira:latest \
    --file Dockerfile .
```

**2. Deploy Application:**

```bash
# Update Kubernetes manifests with Azure resources
# Then apply
kubectl apply -f k8s/azure/
```

### AWS Deployment

```bash
# Create EKS cluster
eksctl create cluster \
    --name guira-cluster \
    --region us-east-1 \
    --nodegroup-name gpu-nodes \
    --node-type p3.2xlarge \
    --nodes 2 \
    --nodes-min 1 \
    --nodes-max 5

# Create RDS PostgreSQL
aws rds create-db-instance \
    --db-instance-identifier guira-postgres \
    --db-instance-class db.t3.large \
    --engine postgres \
    --master-username guiraadmin \
    --master-user-password YourSecurePassword \
    --allocated-storage 100

# Create ElastiCache Redis
aws elasticache create-cache-cluster \
    --cache-cluster-id guira-redis \
    --cache-node-type cache.t3.medium \
    --engine redis \
    --num-cache-nodes 1
```

---

## Configuration Management

### Environment-Specific Configurations

**Production Configuration:**

```yaml
# config/production.yaml
environment: production
debug: false

database:
  pool_size: 20
  max_overflow: 40
  pool_timeout: 30
  pool_recycle: 3600

redis:
  max_connections: 100
  decode_responses: true

processing:
  workers: 8
  batch_size: 32
  gpu_memory_fraction: 0.9

monitoring:
  enabled: true
  metrics_port: 9090
  log_level: INFO
```

**Staging Configuration:**

```yaml
# config/staging.yaml
environment: staging
debug: true

database:
  pool_size: 10
  max_overflow: 20

redis:
  max_connections: 50

processing:
  workers: 4
  batch_size: 16

monitoring:
  enabled: true
  log_level: DEBUG
```

---

## Database Setup

### PostgreSQL + PostGIS Initialization

```sql
-- init_db.sql
-- Create database
CREATE DATABASE guira;

-- Connect to database
\c guira

-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- Create schema
CREATE SCHEMA IF NOT EXISTS guira_data;

-- Set search path
SET search_path TO guira_data, public;

-- Create tables (see ARCHITECTURE.md for full schema)

-- Create indexes
CREATE INDEX idx_detections_location ON detections USING GIST(location);
CREATE INDEX idx_detections_timestamp ON detections(timestamp);

-- Create views
CREATE OR REPLACE VIEW active_fires AS
SELECT * FROM fire_events WHERE status = 'active';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE guira TO guiraadmin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA guira_data TO guiraadmin;
```

**Run Initialization:**

```bash
psql -U postgres -f scripts/init_db.sql
```

---

## Model Deployment

### Model Download Script

```python
# download_models.py
import os
import requests
from tqdm import tqdm

MODELS = {
    "yolov8_fire.pt": "https://example.com/models/yolov8_fire.pt",
    "timesformer_smoke.pt": "https://example.com/models/timesformer_smoke.pt",
    "resnet50_vegetation.pt": "https://example.com/models/resnet50_vegetation.pt",
    "yolov8_fauna.pt": "https://example.com/models/yolov8_fauna.pt",
    "fire_spread_net.pt": "https://example.com/models/fire_spread_net.pt",
}

def download_model(url, filename):
    response = requests.get(url, stream=True)
    total_size = int(response.headers.get('content-length', 0))
    
    with open(f"models/{filename}", "wb") as file:
        with tqdm(total=total_size, unit='B', unit_scale=True) as pbar:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)
                pbar.update(len(chunk))

if __name__ == "__main__":
    os.makedirs("models", exist_ok=True)
    for filename, url in MODELS.items():
        print(f"Downloading {filename}...")
        download_model(url, filename)
```

---

## Monitoring & Logging

### Prometheus Monitoring

```yaml
# prometheus-config.yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'guira-api'
    static_configs:
      - targets: ['guira-api-service:9090']
        labels:
          component: 'api'
  
  - job_name: 'guira-workers'
    static_configs:
      - targets: ['guira-worker-fire:9090', 'guira-worker-smoke:9090']
        labels:
          component: 'worker'
```

### Grafana Dashboards

**Import Pre-built Dashboard:**

```bash
# Install Grafana via Helm
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana -n guira

# Access Grafana
kubectl port-forward -n guira svc/grafana 3000:80

# Import dashboard from JSON
# Navigate to Dashboards > Import > Upload JSON
```

### Logging with ELK Stack

```yaml
# filebeat-config.yaml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /app/logs/*.log
  fields:
    app: guira
    environment: production

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  
logging.level: info
```

---

## Backup & Recovery

### Database Backup

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/postgres"
FILENAME="guira_backup_$DATE.sql"

# Create backup
pg_dump -U guira -h postgres-service guira > $BACKUP_DIR/$FILENAME

# Compress backup
gzip $BACKUP_DIR/$FILENAME

# Upload to cloud storage
aws s3 cp $BACKUP_DIR/$FILENAME.gz s3://guira-backups/

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
```

**Schedule Backup (Kubernetes CronJob):**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: guira
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:15
            command: ["/bin/bash", "/scripts/backup.sh"]
            volumeMounts:
            - name: backup-script
              mountPath: /scripts
          restartPolicy: OnFailure
          volumes:
          - name: backup-script
            configMap:
              name: backup-script
```

### Restore Database

```bash
# Restore from backup
gunzip < guira_backup_20251217_020000.sql.gz | psql -U guira -h postgres-service guira
```

---

## Performance Tuning

### GPU Optimization

```python
# GPU configuration
import torch

# Set GPU memory fraction
torch.cuda.set_per_process_memory_fraction(0.9, device=0)

# Enable TensorFloat32 for faster computation
torch.backends.cuda.matmul.allow_tf32 = True
torch.backends.cudnn.allow_tf32 = True

# Enable cuDNN benchmark for optimal kernels
torch.backends.cudnn.benchmark = True

# Mixed precision training/inference
from torch.cuda.amp import autocast

with autocast():
    output = model(input)
```

### Database Tuning

```sql
-- PostgreSQL configuration tuning
ALTER SYSTEM SET shared_buffers = '8GB';
ALTER SYSTEM SET effective_cache_size = '24GB';
ALTER SYSTEM SET maintenance_work_mem = '2GB';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = '100';
ALTER SYSTEM SET random_page_cost = '1.1';
ALTER SYSTEM SET effective_io_concurrency = '200';
ALTER SYSTEM SET work_mem = '64MB';
ALTER SYSTEM SET min_wal_size = '1GB';
ALTER SYSTEM SET max_wal_size = '4GB';

-- Reload configuration
SELECT pg_reload_conf();
```

---

## Security Hardening

### SSL/TLS Configuration

```nginx
# nginx-ssl.conf
server {
    listen 443 ssl http2;
    server_name api.guira.example.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    location / {
        proxy_pass http://guira-api-service:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Network Policies

```yaml
# network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: guira-network-policy
  namespace: guira
spec:
  podSelector:
    matchLabels:
      app: guira-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: nginx
    ports:
    - protocol: TCP
      port: 8000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
```

---

## Troubleshooting

### Common Issues

**1. GPU Not Detected**

```bash
# Check NVIDIA driver
nvidia-smi

# Verify Docker GPU access
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi

# Check Kubernetes GPU plugin
kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.nvidia\.com/gpu}{"\n"}{end}'
```

**2. Database Connection Errors**

```bash
# Test connection
psql -h postgres-service -U guira -d guira

# Check logs
kubectl logs -n guira postgres-0

# Verify service
kubectl get svc -n guira postgres-service
```

**3. Model Loading Failures**

```bash
# Verify model files exist
ls -lh /app/models/

# Check model file integrity
md5sum /app/models/yolov8_fire.pt

# Test model loading
python -c "import torch; model = torch.load('/app/models/yolov8_fire.pt')"
```

**4. High Memory Usage**

```bash
# Monitor pod resources
kubectl top pods -n guira

# Adjust resource limits
kubectl set resources deployment guira-api -n guira --limits=memory=16Gi

# Check for memory leaks
kubectl exec -it -n guira guira-api-xxx -- python -m memory_profiler api/main.py
```

---

<div align="center">

**Deployment Guide Version:** 0.4.0  
**Last Updated:** December 2025  
**Status:** Production Ready

*For additional support, contact: rasanti2008@gmail.com*

</div>
