# 🚀 MenTora Deployment Guide

This guide covers deploying MenTora to production environments, including Azure Container Instances, Docker, and other cloud platforms.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Configuration](#environment-configuration)
- [Docker Deployment](#docker-deployment)
- [Azure Deployment](#azure-deployment)
- [Database Setup](#database-setup)
- [CDN Configuration](#cdn-configuration)
- [Monitoring & Logging](#monitoring--logging)
- [Security Checklist](#security-checklist)
- [Post-Deployment](#post-deployment)
- [Rollback Procedures](#rollback-procedures)

---

## Prerequisites

### Required Resources

- **Azure Account** with active subscription
- **Azure Cosmos DB** instance (serverless or provisioned)
- **Azure Container Registry** for Docker images
- **Domain Name** with SSL certificate
- **Stripe Account** for payment processing
- **Redis Instance** (optional, for caching)

### Required Tools

- **Docker** 20.10+
- **Azure CLI** 2.40+
- **Git** 2.0+
- **Python** 3.11+ (for local testing)

### Access Requirements

- Azure subscription admin access
- Cosmos DB connection strings
- Stripe API keys
- Domain DNS management access

---

## Environment Configuration

### Production Environment Variables

Create a `.env.production` file (DO NOT commit to git):

```bash
# ═══════════════════════════════════════
# Application Settings
# ═══════════════════════════════════════
APP_ENV=production
APP_NAME=MenTora
DEBUG=false
LOG_LEVEL=INFO

# ═══════════════════════════════════════
# Security
# ═══════════════════════════════════════
JWT_SECRET_KEY=<generate-secure-random-string-64-chars>
JWT_ALGORITHM=HS256
JWT_EXPIRATION_MINUTES=60
ALLOWED_ORIGINS=https://mentora.app,https://www.mentora.app

# ═══════════════════════════════════════
# Database
# ═══════════════════════════════════════
COSMOS_DB_ENDPOINT=https://your-account.documents.azure.com:443/
COSMOS_DB_KEY=<your-primary-key>
COSMOS_DB_DATABASE=mentora-prod
COSMOS_DB_THROUGHPUT=400

# PostgreSQL (if used)
DATABASE_URL=postgresql://user:password@host:5432/mentora

# Redis (optional)
REDIS_URL=redis://your-redis:6379
REDIS_PASSWORD=<redis-password>

# ═══════════════════════════════════════
# Payment Processing
# ═══════════════════════════════════════
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# ═══════════════════════════════════════
# Email (if configured)
# ═══════════════════════════════════════
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=<sendgrid-api-key>
FROM_EMAIL=noreply@mentora.app

# ═══════════════════════════════════════
# Frontend URLs
# ═══════════════════════════════════════
FRONTEND_URL=https://mentora.app
BACKEND_URL=https://api.mentora.app

# ═══════════════════════════════════════
# OAuth (Google)
# ═══════════════════════════════════════
GOOGLE_CLIENT_ID=<your-google-client-id>
GOOGLE_CLIENT_SECRET=<your-google-client-secret>

# ═══════════════════════════════════════
# Monitoring
# ═══════════════════════════════════════
PROMETHEUS_ENABLED=true
PROMETHEUS_PORT=9090

# ═══════════════════════════════════════
# Performance
# ═══════════════════════════════════════
WORKERS=4
MAX_CONNECTIONS=100
TIMEOUT=30
KEEPALIVE=5
```

### Generating Secure Secrets

```bash
# Generate JWT secret (64 characters)
openssl rand -hex 32

# Generate Python secret key
python -c 'import secrets; print(secrets.token_urlsafe(64))'
```

---

## Docker Deployment

### Build Docker Image

```bash
# Navigate to code directory
cd /path/to/THEDIFY/projects/MenTora/code

# Build the image
docker build -t mentora-backend:latest .

# Tag for registry
docker tag mentora-backend:latest your-registry.azurecr.io/mentora-backend:latest
docker tag mentora-backend:latest your-registry.azurecr.io/mentora-backend:v1.0.0
```

### Test Locally

```bash
# Run container with environment file
docker run -d \
  --name mentora-test \
  -p 8000:8000 \
  --env-file .env.production \
  mentora-backend:latest

# Check logs
docker logs -f mentora-test

# Test health endpoint
curl http://localhost:8000/health

# Stop and remove
docker stop mentora-test
docker rm mentora-test
```

### Push to Azure Container Registry

```bash
# Login to Azure
az login

# Login to ACR
az acr login --name your-registry

# Push images
docker push your-registry.azurecr.io/mentora-backend:latest
docker push your-registry.azurecr.io/mentora-backend:v1.0.0
```

---

## Azure Deployment

### Azure Container Instances

#### Create Resource Group

```bash
az group create \
  --name mentora-prod-rg \
  --location eastus
```

#### Deploy Container

```bash
# Create container instance
az container create \
  --resource-group mentora-prod-rg \
  --name mentora-api \
  --image your-registry.azurecr.io/mentora-backend:latest \
  --cpu 2 \
  --memory 4 \
  --registry-login-server your-registry.azurecr.io \
  --registry-username <username> \
  --registry-password <password> \
  --dns-name-label mentora-api \
  --ports 8000 \
  --environment-variables \
    APP_ENV=production \
    LOG_LEVEL=INFO \
  --secure-environment-variables \
    COSMOS_DB_KEY=<key> \
    JWT_SECRET_KEY=<key> \
    STRIPE_SECRET_KEY=<key>

# Check status
az container show \
  --resource-group mentora-prod-rg \
  --name mentora-api \
  --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" \
  --output table

# View logs
az container logs \
  --resource-group mentora-prod-rg \
  --name mentora-api \
  --follow
```

#### Container Configuration YAML

Alternatively, use a YAML configuration file:

```yaml
# mentora-deployment.yaml
apiVersion: 2021-07-01
location: eastus
name: mentora-api
properties:
  containers:
  - name: mentora-backend
    properties:
      image: your-registry.azurecr.io/mentora-backend:latest
      resources:
        requests:
          cpu: 2
          memoryInGb: 4
      ports:
      - port: 8000
        protocol: TCP
      environmentVariables:
      - name: APP_ENV
        value: production
      - name: LOG_LEVEL
        value: INFO
      - name: COSMOS_DB_ENDPOINT
        secureValue: https://your-cosmos.documents.azure.com:443/
      - name: COSMOS_DB_KEY
        secureValue: <secure-key>
      - name: JWT_SECRET_KEY
        secureValue: <secure-key>
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
  imageRegistryCredentials:
  - server: your-registry.azurecr.io
    username: <username>
    password: <password>
  ipAddress:
    type: Public
    ports:
    - protocol: tcp
      port: 8000
    dnsNameLabel: mentora-api
  osType: Linux
  restartPolicy: Always
tags:
  environment: production
  project: mentora
type: Microsoft.ContainerInstance/containerGroups
```

Deploy with YAML:

```bash
az container create \
  --resource-group mentora-prod-rg \
  --file mentora-deployment.yaml
```

### Azure App Service (Alternative)

```bash
# Create App Service Plan
az appservice plan create \
  --name mentora-plan \
  --resource-group mentora-prod-rg \
  --sku B1 \
  --is-linux

# Create Web App
az webapp create \
  --resource-group mentora-prod-rg \
  --plan mentora-plan \
  --name mentora-api \
  --deployment-container-image-name your-registry.azurecr.io/mentora-backend:latest

# Configure environment variables
az webapp config appsettings set \
  --resource-group mentora-prod-rg \
  --name mentora-api \
  --settings \
    APP_ENV=production \
    COSMOS_DB_ENDPOINT=https://your-cosmos.documents.azure.com:443/

# Enable logging
az webapp log config \
  --resource-group mentora-prod-rg \
  --name mentora-api \
  --docker-container-logging filesystem
```

---

## Database Setup

### Azure Cosmos DB

#### Create Cosmos DB Account

```bash
# Create account
az cosmosdb create \
  --name mentora-cosmos \
  --resource-group mentora-prod-rg \
  --kind GlobalDocumentDB \
  --default-consistency-level Session \
  --locations regionName=eastus failoverPriority=0 isZoneRedundant=False

# Create database
az cosmosdb sql database create \
  --account-name mentora-cosmos \
  --resource-group mentora-prod-rg \
  --name mentora-prod \
  --throughput 400
```

#### Create Containers

```bash
# Courses container
az cosmosdb sql container create \
  --account-name mentora-cosmos \
  --resource-group mentora-prod-rg \
  --database-name mentora-prod \
  --name courses \
  --partition-key-path "/id" \
  --indexing-policy @courses-indexing-policy.json

# Users container
az cosmosdb sql container create \
  --account-name mentora-cosmos \
  --resource-group mentora-prod-rg \
  --database-name mentora-prod \
  --name users \
  --partition-key-path "/id"

# Progress container
az cosmosdb sql container create \
  --account-name mentora-cosmos \
  --resource-group mentora-prod-rg \
  --database-name mentora-prod \
  --name progress \
  --partition-key-path "/user_id"
```

#### Indexing Policy (courses-indexing-policy.json)

```json
{
  "indexingMode": "consistent",
  "automatic": true,
  "includedPaths": [
    {
      "path": "/*"
    }
  ],
  "excludedPaths": [
    {
      "path": "/\"_etag\"/?"
    }
  ],
  "compositeIndexes": [
    [
      {
        "path": "/category",
        "order": "ascending"
      },
      {
        "path": "/difficulty",
        "order": "ascending"
      },
      {
        "path": "/enrollment_count",
        "order": "descending"
      }
    ]
  ]
}
```

### Database Migration

```bash
# Run migration script (if available)
python scripts/migrate_database.py --env production

# Verify data
python scripts/verify_database.py
```

---

## CDN Configuration

### Azure CDN

```bash
# Create CDN profile
az cdn profile create \
  --resource-group mentora-prod-rg \
  --name mentora-cdn \
  --sku Standard_Microsoft

# Create endpoint
az cdn endpoint create \
  --resource-group mentora-prod-rg \
  --name mentora-assets \
  --profile-name mentora-cdn \
  --origin your-storage-account.blob.core.windows.net \
  --origin-host-header your-storage-account.blob.core.windows.net

# Configure custom domain (after DNS setup)
az cdn custom-domain create \
  --resource-group mentora-prod-rg \
  --endpoint-name mentora-assets \
  --profile-name mentora-cdn \
  --name mentora-assets \
  --hostname assets.mentora.app

# Enable HTTPS
az cdn custom-domain enable-https \
  --resource-group mentora-prod-rg \
  --endpoint-name mentora-assets \
  --profile-name mentora-cdn \
  --name mentora-assets
```

---

## Monitoring & Logging

### Application Insights (Optional)

```bash
# Create Application Insights
az monitor app-insights component create \
  --app mentora-insights \
  --location eastus \
  --resource-group mentora-prod-rg \
  --application-type web

# Get instrumentation key
az monitor app-insights component show \
  --app mentora-insights \
  --resource-group mentora-prod-rg \
  --query instrumentationKey
```

### Structured Logging

MenTora uses JSON-formatted structured logging. Example configuration:

```python
# config/logging.py
import structlog

structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        structlog.processors.JSONRenderer()
    ]
)
```

View logs:

```bash
# Azure Container Instances
az container logs --resource-group mentora-prod-rg --name mentora-api

# Filter for errors
az container logs --resource-group mentora-prod-rg --name mentora-api | grep '"level":"error"'
```

### Health Checks

```bash
# Basic health check
curl https://api.mentora.app/health

# Expected response:
# {
#   "status": "healthy",
#   "database": "connected",
#   "redis": "connected",
#   "timestamp": "2024-12-17T10:30:00Z"
# }
```

---

## Security Checklist

### Pre-Deployment Security

- [ ] All secrets stored in Azure Key Vault (not environment files)
- [ ] HTTPS enabled with valid SSL certificate
- [ ] CORS origins restricted to production domains
- [ ] Rate limiting configured
- [ ] JWT tokens have appropriate expiration (1 hour)
- [ ] Database firewall rules configured (allow only Azure services)
- [ ] Admin accounts use strong passwords
- [ ] Stripe webhook signatures verified
- [ ] XSS protection enabled (Bleach sanitization)
- [ ] SQL injection protection via Pydantic validation

### Security Headers

Configure these headers in your reverse proxy (nginx/Azure App Gateway):

```nginx
add_header X-Frame-Options "DENY";
add_header X-Content-Type-Options "nosniff";
add_header X-XSS-Protection "1; mode=block";
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';";
```

---

## Post-Deployment

### Smoke Tests

Run these tests immediately after deployment:

```bash
# 1. Health check
curl https://api.mentora.app/health

# 2. Login test
curl -X POST https://api.mentora.app/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass"}'

# 3. Course search
curl -X GET "https://api.mentora.app/api/v1/courses/search?category=AI" \
  -H "Authorization: Bearer <token>"

# 4. Database connectivity
# (Check logs for successful connection messages)
```

### Performance Validation

```bash
# Response time check (should be < 500ms)
curl -w "@curl-format.txt" -o /dev/null -s https://api.mentora.app/api/v1/courses/search

# Load test (optional, use with caution)
ab -n 100 -c 10 https://api.mentora.app/health
```

### Monitoring Setup

1. Configure alerts for:
   - API response time > 1s
   - Error rate > 5%
   - Container restart
   - Database RU consumption > 80%
   - Memory usage > 90%

2. Set up dashboards for:
   - Request rate
   - Response times (p50, p95, p99)
   - Error rates by endpoint
   - Active users
   - Course enrollments

---

## Rollback Procedures

### Quick Rollback

```bash
# Rollback to previous container version
az container create \
  --resource-group mentora-prod-rg \
  --name mentora-api \
  --image your-registry.azurecr.io/mentora-backend:v0.9.0 \
  --file mentora-deployment.yaml

# Verify rollback
curl https://api.mentora.app/health
```

### Database Rollback

```bash
# Restore from point-in-time backup (if needed)
az cosmosdb sql database restore \
  --account-name mentora-cosmos \
  --resource-group mentora-prod-rg \
  --name mentora-prod \
  --restore-timestamp "2024-12-17T10:00:00Z"
```

---

## Maintenance

### Regular Tasks

**Daily:**
- Check error logs
- Monitor response times
- Verify database RU consumption

**Weekly:**
- Review security logs
- Update dependencies (patch versions only)
- Backup database (automated)

**Monthly:**
- Security audit
- Performance review
- Cost optimization review
- Update dependencies (minor versions)

**Quarterly:**
- SSL certificate renewal (if manual)
- Major dependency updates
- Disaster recovery drill

---

## Support

For deployment issues:
- **Email:** rasanti2008@gmail.com
- **Documentation:** [Deployment Checklist](documentation/DEPLOYMENT_CHECKLIST.md)
- **GitHub Issues:** https://github.com/THEDIFY/THEDIFY/issues

---

**Last Updated:** December 17, 2024  
**Version:** 1.0.0
