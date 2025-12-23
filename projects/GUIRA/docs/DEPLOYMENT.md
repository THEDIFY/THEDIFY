# GUIRA Deployment Guide

Complete guide for deploying GUIRA in various environments, from local development to cloud production.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Docker Deployment](#docker-deployment)
- [Cloud Deployment](#cloud-deployment)
  - [Azure](#microsoft-azure)
  - [AWS](#amazon-web-services)
  - [Google Cloud](#google-cloud-platform)
- [Edge Deployment](#edge-deployment)
- [Configuration Management](#configuration-management)
- [Monitoring Setup](#monitoring-setup)
- [Backup & Recovery](#backup--recovery)

---

## Prerequisites

### Hardware Requirements

**Minimum:**
- CPU: 4 cores
- RAM: 16GB
- Storage: 100GB SSD
- Network: 10 Mbps

**Recommended:**
- CPU: 8+ cores
- RAM: 32GB+
- GPU: NVIDIA GPU with 8GB+ VRAM
- Storage: 500GB NVMe SSD
- Network: 100 Mbps+

### Software Requirements

- Linux (Ubuntu 22.04 LTS recommended)
- Docker 24.0+
- Docker Compose 2.0+
- PostgreSQL 15+
- Redis 7.0+
- GDAL 3.8+

---

## Local Development

### Quick Start

```bash
# Clone repository
git clone https://github.com/THEDIFY/THEDIFY.git
cd THEDIFY/projects/GUIRA

# Run with Docker Compose
docker-compose up -d

# Access services
# API: http://localhost:8000
# Dashboard: http://localhost:3000
# Database: localhost:5432
```

### Manual Setup

```bash
# Install system dependencies
sudo apt-get update
sudo apt-get install -y \
    postgresql-15 postgresql-15-postgis \
    redis-server \
    gdal-bin libgdal-dev \
    python3.11 python3.11-venv

# Create database
sudo -u postgres createdb guira
sudo -u postgres psql guira -c "CREATE EXTENSION postgis;"

# Python environment
cd code
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Run migrations
python manage.py migrate

# Start services
uvicorn api.main:app --reload &
celery -A tasks worker --loglevel=info &
```

---

## Docker Deployment

### Production Docker Compose

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  api:
    build:
      context: ./code
      dockerfile: Dockerfile.prod
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/guira
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '2'
          memory: 4G
  
  worker:
    build:
      context: ./code
      dockerfile: Dockerfile.worker
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/guira
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    deploy:
      replicas: 5
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
  
  db:
    image: postgis/postgis:15-3.3
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=guira
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=secure_password
  
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Deploy

```bash
# Build images
docker-compose -f docker-compose.prod.yml build

# Start services
docker-compose -f docker-compose.prod.yml up -d

# Check status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f api
```

---

## Cloud Deployment

### Microsoft Azure

#### Azure Kubernetes Service (AKS)

```bash
# Create resource group
az group create --name guira-rg --location eastus

# Create AKS cluster with GPU nodes
az aks create \
    --resource-group guira-rg \
    --name guira-aks \
    --node-count 3 \
    --node-vm-size Standard_NC6s_v3 \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 10 \
    --enable-addons monitoring

# Get credentials
az aks get-credentials --resource-group guira-rg --name guira-aks

# Deploy PostgreSQL
az postgres flexible-server create \
    --resource-group guira-rg \
    --name guira-postgres \
    --location eastus \
    --admin-user guiraadmin \
    --admin-password SecurePassword123! \
    --sku-name Standard_D4s_v3 \
    --storage-size 128

# Deploy Redis
az redis create \
    --resource-group guira-rg \
    --name guira-redis \
    --location eastus \
    --sku Standard \
    --vm-size c1

# Deploy application
kubectl apply -f kubernetes/

# Check deployment
kubectl get pods
kubectl get services
```

---

### Amazon Web Services (AWS)

#### EKS Deployment

```bash
# Create EKS cluster
eksctl create cluster \
    --name guira-cluster \
    --region us-east-1 \
    --nodegroup-name gpu-nodes \
    --node-type p3.2xlarge \
    --nodes 3 \
    --nodes-min 1 \
    --nodes-max 10

# Create RDS PostgreSQL
aws rds create-db-instance \
    --db-instance-identifier guira-postgres \
    --db-instance-class db.r5.xlarge \
    --engine postgres \
    --master-username admin \
    --master-user-password SecurePass123! \
    --allocated-storage 100 \
    --engine-version 15.3

# Create ElastiCache Redis
aws elasticache create-cache-cluster \
    --cache-cluster-id guira-redis \
    --cache-node-type cache.r5.large \
    --engine redis \
    --num-cache-nodes 1

# Deploy application
kubectl apply -f kubernetes/

# Set up load balancer
kubectl apply -f kubernetes/ingress.yaml
```

---

### Google Cloud Platform (GCP)

#### GKE Deployment

```bash
# Create GKE cluster
gcloud container clusters create guira-cluster \
    --zone us-central1-a \
    --num-nodes 3 \
    --machine-type n1-standard-4 \
    --accelerator type=nvidia-tesla-t4,count=1 \
    --enable-autoscaling \
    --min-nodes 1 \
    --max-nodes 10

# Create Cloud SQL PostgreSQL
gcloud sql instances create guira-postgres \
    --database-version POSTGRES_15 \
    --tier db-n1-standard-4 \
    --region us-central1

# Create Memorystore Redis
gcloud redis instances create guira-redis \
    --size 5 \
    --region us-central1

# Deploy application
kubectl apply -f kubernetes/

# Expose service
kubectl apply -f kubernetes/service.yaml
```

---

## Edge Deployment

### NVIDIA Jetson Setup

```bash
# Flash JetPack 5.1+
# Connect to Jetson

# Install dependencies
sudo apt-get update
sudo apt-get install -y python3-pip libhdf5-serial-dev hdf5-tools

# Install PyTorch for Jetson
pip3 install torch torchvision --index-url https://pypi.org/simple

# Clone and setup
git clone https://github.com/THEDIFY/THEDIFY.git
cd THEDIFY/projects/GUIRA/code
pip3 install -r requirements-edge.txt

# Download optimized models
python3 scripts/download_edge_models.py

# Configure for edge
cp config/edge.yaml config/config.yaml

# Run edge service
python3 edge_service.py
```

---

## Configuration Management

### Environment Variables

```bash
# Production .env
DATABASE_URL=postgresql://user:pass@db-host:5432/guira
REDIS_URL=redis://redis-host:6379/0
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=api.guira.com,guira.com

# Model paths
YOLOV8_MODEL=/models/yolov8_fire.pt
TIMESFORMER_MODEL=/models/timesformer_smoke.pt

# API keys
NOAA_API_KEY=your_noaa_key
COPERNICUS_USER=your_username
COPERNICUS_PASS=your_password

# Monitoring
SENTRY_DSN=https://your-sentry-dsn
LOG_LEVEL=INFO
```

### Kubernetes Secrets

```bash
# Create secrets
kubectl create secret generic guira-secrets \
    --from-literal=database-url='postgresql://...' \
    --from-literal=redis-url='redis://...' \
    --from-literal=secret-key='...'

# Use in deployment
# See kubernetes/deployment.yaml
```

---

## Monitoring Setup

### Prometheus + Grafana

```bash
# Install Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack

# Access Grafana
kubectl port-forward svc/prometheus-grafana 3000:80

# Import GUIRA dashboard
# Dashboard ID: coming soon
```

### Application Insights (Azure)

```python
# Add to code
from opencensus.ext.azure import metrics_exporter
from opencensus.stats import aggregation as aggregation_module
from opencensus.stats import measure as measure_module
from opencensus.stats import stats as stats_module
from opencensus.stats import view as view_module

# Configure
exporter = metrics_exporter.new_metrics_exporter(
    connection_string='InstrumentationKey=your-key'
)
```

---

## Backup & Recovery

### Database Backups

```bash
# Automated backup script
#!/bin/bash
BACKUP_DIR="/backups/postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

pg_dump -h localhost -U guirauser guira | \
    gzip > $BACKUP_DIR/guira_$TIMESTAMP.sql.gz

# Keep last 30 days
find $BACKUP_DIR -name "guira_*.sql.gz" -mtime +30 -delete
```

### Model Versioning

```bash
# Store models in object storage with versions
aws s3 cp models/yolov8_fire.pt \
    s3://guira-models/v0.4.0/yolov8_fire.pt

# Restore specific version
aws s3 cp s3://guira-models/v0.3.0/yolov8_fire.pt \
    models/yolov8_fire.pt
```

---

## Security Checklist

- [ ] SSL/TLS certificates configured
- [ ] Database connections encrypted
- [ ] API keys in environment variables (not code)
- [ ] Firewall rules configured
- [ ] Regular security updates scheduled
- [ ] Backup strategy tested
- [ ] Monitoring and alerting active
- [ ] Access logs enabled
- [ ] Rate limiting configured

---

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common deployment issues.

---

*Last Updated: December 17, 2025*
