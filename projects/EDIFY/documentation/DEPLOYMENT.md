# EDIFY Deployment Guide

This guide covers deploying EDIFY to production environments, including Azure cloud infrastructure, Docker containers, and various deployment scenarios.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Azure Infrastructure Setup](#azure-infrastructure-setup)
- [Docker Deployment](#docker-deployment)
- [Environment Configuration](#environment-configuration)
- [Database Setup](#database-setup)
- [Production Checklist](#production-checklist)
- [Monitoring & Logging](#monitoring--logging)
- [Backup & Disaster Recovery](#backup--disaster-recovery)
- [Scaling Strategies](#scaling-strategies)
- [Troubleshooting Deployment](#troubleshooting-deployment)

---

## Overview

EDIFY is designed for cloud-native deployment on Microsoft Azure, leveraging managed services for scalability, reliability, and security.

**Recommended Architecture:**
- **Compute:** Azure App Service or Azure Container Instances
- **AI Services:** Azure OpenAI, Azure AI Search
- **Database:** Azure Cosmos DB
- **Cache:** Azure Cache for Redis
- **Storage:** Azure Blob Storage
- **CDN:** Azure CDN for static assets

**Deployment Options:**
1. **Azure (Recommended):** Fully managed, auto-scaling
2. **Docker Compose:** Self-hosted, single-server
3. **Kubernetes:** Self-hosted, multi-server orchestration

---

## Prerequisites

### Required Azure Resources

- **Azure Subscription:** With appropriate permissions
- **Azure OpenAI:** GPT-4 deployment
- **Azure AI Search:** Standard tier or higher
- **Azure Cosmos DB:** Account with SQL API
- **Azure Cache for Redis:** Standard C1 or higher
- **Azure Blob Storage:** General Purpose v2 account

### Required Tools

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Docker
sudo apt-get update
sudo apt-get install docker.io docker-compose

# Install Azure Developer CLI (azd)
curl -fsSL https://aka.ms/install-azd.sh | bash
```

### Cost Estimation

**Monthly costs (approximate):**

| Service | Tier | Monthly Cost |
|---------|------|-------------|
| Azure OpenAI (GPT-4) | Pay-per-use | $500-2000 |
| Azure AI Search | Standard S1 | $250 |
| Azure Cosmos DB | Provisioned 1000 RU/s | $60 |
| Azure Cache for Redis | Standard C1 | $75 |
| Azure App Service | Premium P1V2 | $150 |
| Azure Blob Storage | Standard | $20 |
| **Total** | | **$1,055-2,555** |

*Costs vary based on usage. Use Azure Pricing Calculator for accurate estimates.*

---

## Azure Infrastructure Setup

### Option 1: Automated Deployment (Recommended)

Use Azure Developer CLI for one-command deployment:

```bash
# 1. Clone repository
git clone https://github.com/THEDIFY/THEDIFY.git
cd THEDIFY/projects/EDIFY

# 2. Initialize Azure Developer CLI
azd init

# 3. Provision infrastructure and deploy
azd up

# This will:
# - Create resource group
# - Provision all Azure services
# - Configure networking and security
# - Deploy application code
# - Set up monitoring
```

**Configuration prompts:**
```
? Select an Azure region: East US
? Select environment name: edify-prod
? Deploy with default settings? Yes
```

**Expected output:**
```
✓ Provisioning Azure resources (10-15 minutes)
  ✓ Resource group created
  ✓ Azure OpenAI deployed
  ✓ Azure AI Search configured
  ✓ Cosmos DB provisioned
  ✓ Redis cache created
  ✓ App Service deployed
  
✓ Deploying application (3-5 minutes)
  ✓ Docker image built
  ✓ Code deployed to App Service
  ✓ Environment variables set
  ✓ Health checks passed

SUCCESS: EDIFY deployed to https://edify-prod.azurewebsites.net
```

### Option 2: Manual Azure Setup

#### Step 1: Create Resource Group

```bash
# Set variables
RESOURCE_GROUP="edify-prod-rg"
LOCATION="eastus"
SUBSCRIPTION_ID="your-subscription-id"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --subscription $SUBSCRIPTION_ID
```

#### Step 2: Deploy Azure OpenAI

```bash
# Create Azure OpenAI resource
az cognitiveservices account create \
  --name edify-openai \
  --resource-group $RESOURCE_GROUP \
  --kind OpenAI \
  --sku S0 \
  --location eastus

# Deploy GPT-4 model
az cognitiveservices account deployment create \
  --name edify-openai \
  --resource-group $RESOURCE_GROUP \
  --deployment-name gpt-4 \
  --model-name gpt-4 \
  --model-version "0613" \
  --model-format OpenAI \
  --sku-capacity 10 \
  --sku-name "Standard"

# Get API key
OPENAI_KEY=$(az cognitiveservices account keys list \
  --name edify-openai \
  --resource-group $RESOURCE_GROUP \
  --query key1 -o tsv)
```

#### Step 3: Create Azure AI Search

```bash
# Create search service
az search service create \
  --name edify-search \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard

# Get API key
SEARCH_KEY=$(az search admin-key show \
  --service-name edify-search \
  --resource-group $RESOURCE_GROUP \
  --query primaryKey -o tsv)
```

#### Step 4: Provision Cosmos DB

```bash
# Create Cosmos DB account
az cosmosdb create \
  --name edify-cosmos \
  --resource-group $RESOURCE_GROUP \
  --locations regionName=$LOCATION failoverPriority=0 \
  --default-consistency-level Session \
  --enable-automatic-failover true

# Create database
az cosmosdb sql database create \
  --account-name edify-cosmos \
  --resource-group $RESOURCE_GROUP \
  --name edify-db

# Create container
az cosmosdb sql container create \
  --account-name edify-cosmos \
  --database-name edify-db \
  --resource-group $RESOURCE_GROUP \
  --name users \
  --partition-key-path "/userId" \
  --throughput 1000

# Get connection string
COSMOS_KEY=$(az cosmosdb keys list \
  --name edify-cosmos \
  --resource-group $RESOURCE_GROUP \
  --query primaryMasterKey -o tsv)
```

#### Step 5: Create Redis Cache

```bash
# Create Redis cache
az redis create \
  --name edify-redis \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard \
  --vm-size C1

# Get access key
REDIS_KEY=$(az redis list-keys \
  --name edify-redis \
  --resource-group $RESOURCE_GROUP \
  --query primaryKey -o tsv)
```

#### Step 6: Create Storage Account

```bash
# Create storage account
az storage account create \
  --name edifystorage \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

# Create blob container
az storage container create \
  --name documents \
  --account-name edifystorage
```

---

## Docker Deployment

### Build Docker Image

```bash
# Navigate to code directory
cd THEDIFY/projects/EDIFY/code

# Build image
docker build -t edify:latest .

# Tag for registry (if using Azure Container Registry)
docker tag edify:latest edifyregistry.azurecr.io/edify:latest

# Push to registry
docker push edifyregistry.azurecr.io/edify:latest
```

### Docker Compose (Single Server)

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  api:
    image: edify:latest
    container_name: edify-api
    ports:
      - "8000:8000"
    environment:
      - AZURE_OPENAI_ENDPOINT=${AZURE_OPENAI_ENDPOINT}
      - AZURE_OPENAI_API_KEY=${AZURE_OPENAI_API_KEY}
      - AZURE_SEARCH_ENDPOINT=${AZURE_SEARCH_ENDPOINT}
      - AZURE_SEARCH_API_KEY=${AZURE_SEARCH_API_KEY}
      - AZURE_COSMOS_ENDPOINT=${AZURE_COSMOS_ENDPOINT}
      - AZURE_COSMOS_KEY=${AZURE_COSMOS_KEY}
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    container_name: edify-redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    restart: unless-stopped
    command: redis-server --appendonly yes

  nginx:
    image: nginx:alpine
    container_name: edify-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - api
    restart: unless-stopped

volumes:
  redis-data:
```

**Deploy:**

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Update and restart
docker-compose pull
docker-compose up -d
```

---

## Environment Configuration

### Production Environment Variables

Create `.env.production` file:

```bash
# ═══════════════════════════════════════════════
# AZURE OPENAI CONFIGURATION
# ═══════════════════════════════════════════════
AZURE_OPENAI_ENDPOINT=https://edify-openai.openai.azure.com/
AZURE_OPENAI_API_KEY=your_openai_api_key_here
AZURE_OPENAI_DEPLOYMENT=gpt-4
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# ═══════════════════════════════════════════════
# AZURE AI SEARCH CONFIGURATION
# ═══════════════════════════════════════════════
AZURE_SEARCH_ENDPOINT=https://edify-search.search.windows.net
AZURE_SEARCH_API_KEY=your_search_api_key_here
AZURE_SEARCH_INDEX_NAME=edify-content

# ═══════════════════════════════════════════════
# AZURE COSMOS DB CONFIGURATION
# ═══════════════════════════════════════════════
AZURE_COSMOS_ENDPOINT=https://edify-cosmos.documents.azure.com:443/
AZURE_COSMOS_KEY=your_cosmos_key_here
AZURE_COSMOS_DATABASE_NAME=edify-db
AZURE_COSMOS_CONTAINER_NAME=users

# ═══════════════════════════════════════════════
# REDIS CONFIGURATION
# ═══════════════════════════════════════════════
REDIS_URL=redis://edify-redis.redis.cache.windows.net:6380
REDIS_PASSWORD=your_redis_password_here
REDIS_SSL=true

# ═══════════════════════════════════════════════
# APPLICATION CONFIGURATION
# ═══════════════════════════════════════════════
SECRET_KEY=your-super-secret-key-minimum-32-chars
ENVIRONMENT=production
DEBUG=false
LOG_LEVEL=INFO

# ═══════════════════════════════════════════════
# AUTHENTICATION (GOOGLE OAUTH)
# ═══════════════════════════════════════════════
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your_google_client_secret

# ═══════════════════════════════════════════════
# STRIPE PAYMENT (OPTIONAL)
# ═══════════════════════════════════════════════
STRIPE_PUBLISHABLE_KEY=pk_live_your_live_publishable_key
STRIPE_SECRET_KEY=sk_live_your_live_secret_key

# ═══════════════════════════════════════════════
# MONITORING & LOGGING
# ═══════════════════════════════════════════════
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=your-key
ENABLE_METRICS=true
ENABLE_TRACING=true
```

### Security Best Practices

**Never commit secrets to Git:**

```bash
# Add to .gitignore
echo ".env" >> .gitignore
echo ".env.*" >> .gitignore
echo "*.key" >> .gitignore
```

**Use Azure Key Vault for secrets (recommended):**

```bash
# Create Key Vault
az keyvault create \
  --name edify-keyvault \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Store secrets
az keyvault secret set \
  --vault-name edify-keyvault \
  --name OpenAIKey \
  --value $OPENAI_KEY

# Retrieve in application
OPENAI_KEY=$(az keyvault secret show \
  --vault-name edify-keyvault \
  --name OpenAIKey \
  --query value -o tsv)
```

---

## Database Setup

### Cosmos DB Initialization

```bash
# Run database setup script
cd THEDIFY/projects/EDIFY/code
python scripts/setup_cosmos_db.py

# Expected output:
# ✓ Connected to Cosmos DB
# ✓ Database 'edify-db' ready
# ✓ Container 'users' created
# ✓ Container 'conversations' created
# ✓ Container 'analytics' created
# ✓ Indexes configured
# ✓ Setup complete
```

### Azure AI Search Index Setup

```bash
# Create search index with schema
python scripts/create_search_index.py

# Upload initial content
python scripts/ingest_content.py --source data/educational_content/

# Verify indexing
curl -X GET \
  "https://edify-search.search.windows.net/indexes/edify-content/docs/$count?api-version=2023-11-01" \
  -H "api-key: $SEARCH_KEY"

# Expected: {"value": 15247}  (number of indexed documents)
```

---

## Production Checklist

### Pre-Deployment

- [ ] **Environment variables configured** (all required keys set)
- [ ] **Secrets stored securely** (Azure Key Vault or encrypted)
- [ ] **Database initialized** (Cosmos DB containers created)
- [ ] **Search index created** (Azure AI Search schema configured)
- [ ] **Content ingested** (educational materials uploaded)
- [ ] **SSL certificates obtained** (for custom domain)
- [ ] **DNS configured** (domain points to App Service)
- [ ] **OAuth configured** (Google OAuth redirect URIs set)
- [ ] **Payment gateway tested** (Stripe in live mode)

### Post-Deployment

- [ ] **Health check passes** (`/health` endpoint returns 200)
- [ ] **Smoke tests pass** (critical user flows work)
- [ ] **Monitoring configured** (Application Insights connected)
- [ ] **Logging operational** (logs flowing to Azure Monitor)
- [ ] **Alerts configured** (error rate, latency, uptime)
- [ ] **Backup configured** (Cosmos DB automatic backups enabled)
- [ ] **CDN configured** (static assets cached globally)
- [ ] **Rate limiting tested** (API limits enforced)
- [ ] **Load testing passed** (performance under expected load)
- [ ] **Security scan passed** (no critical vulnerabilities)

### Validation Tests

```bash
# 1. Health check
curl https://edify.ai/health
# Expected: {"status": "healthy", "components": {...}}

# 2. API authentication
curl -X POST https://edify.ai/api/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query": "test", "user_id": "test_user"}'
# Expected: 200 OK with response

# 3. Database connectivity
curl https://edify.ai/api/users/me \
  -H "Authorization: Bearer $TOKEN"
# Expected: 200 OK with user profile

# 4. Cache operational
curl https://edify.ai/api/chat \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query": "same query"}' \
  --write-out '%{time_total}'
# Second request should be faster (cached)

# 5. Monitoring
curl https://edify.ai/metrics
# Expected: Prometheus metrics
```

---

## Monitoring & Logging

### Application Insights Setup

```bash
# Create Application Insights
az monitor app-insights component create \
  --app edify-insights \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Get instrumentation key
INSIGHTS_KEY=$(az monitor app-insights component show \
  --app edify-insights \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey -o tsv)

# Add to environment variables
export APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=$INSIGHTS_KEY"
```

### Key Metrics to Monitor

**Application Metrics:**
- Request rate (requests/sec)
- Response time (p50, p95, p99)
- Error rate (errors/total requests)
- Throughput (successful requests/sec)

**AI Service Metrics:**
- OpenAI API latency
- OpenAI token usage
- Search query latency
- Cache hit rate

**Infrastructure Metrics:**
- CPU utilization
- Memory usage
- Network I/O
- Disk I/O

### Logging Configuration

**Structured JSON logging:**

```python
import logging
from pythonjsonlogger import jsonlogger

logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)

logger.info("User query processed", extra={
    "user_id": user_id,
    "query": query,
    "latency_ms": latency,
    "tokens_used": tokens
})
```

### Alerting Rules

**Critical Alerts (immediate notification):**
- Error rate > 5%
- Response time p95 > 5s
- Service uptime < 99%
- Database connection failures

**Warning Alerts (notification within 1 hour):**
- Error rate > 2%
- Response time p95 > 3s
- Cache hit rate < 50%
- OpenAI API rate limit approaching

---

## Backup & Disaster Recovery

### Automated Backups

**Cosmos DB:**
- Automatic backups every 4 hours
- Retention: 30 days
- Point-in-time restore available

**Enable continuous backup:**
```bash
az cosmosdb update \
  --name edify-cosmos \
  --resource-group $RESOURCE_GROUP \
  --backup-policy-type Continuous
```

**Azure Blob Storage:**
- Geo-redundant storage (GRS)
- Soft delete enabled (14-day retention)

### Disaster Recovery Plan

**Recovery Time Objective (RTO):** 5 minutes  
**Recovery Point Objective (RPO):** 0 seconds (continuous replication)

**Failover Procedure:**

1. **Detect outage** (automated health checks)
2. **Verify regional outage** (check Azure status)
3. **Trigger failover** (manual or automatic)
   ```bash
   az cosmosdb failover-priority-change \
     --name edify-cosmos \
     --resource-group $RESOURCE_GROUP \
     --failover-policies westeurope=0 eastus=1
   ```
4. **Update DNS** (point to secondary region)
5. **Verify service health** (run smoke tests)
6. **Monitor performance** (ensure metrics normal)

**Backup Restoration:**

```bash
# Restore Cosmos DB to point-in-time
az cosmosdb restore \
  --target-database-account-name edify-cosmos-restored \
  --account-name edify-cosmos \
  --resource-group $RESOURCE_GROUP \
  --restore-timestamp "2025-12-17T10:00:00Z" \
  --location eastus
```

---

## Scaling Strategies

### Horizontal Scaling (Add Instances)

**Azure App Service:**

```bash
# Scale out to 5 instances
az appservice plan update \
  --name edify-app-plan \
  --resource-group $RESOURCE_GROUP \
  --number-of-workers 5

# Enable autoscaling
az monitor autoscale create \
  --resource-group $RESOURCE_GROUP \
  --resource edify-app-service \
  --min-count 3 \
  --max-count 10 \
  --count 3

# Add autoscale rule (CPU-based)
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name edify-autoscale \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 2
```

### Vertical Scaling (Increase Size)

```bash
# Upgrade to larger App Service plan
az appservice plan update \
  --name edify-app-plan \
  --resource-group $RESOURCE_GROUP \
  --sku P2V2  # 2 cores, 7GB RAM
```

### Database Scaling

**Cosmos DB throughput:**

```bash
# Increase provisioned throughput
az cosmosdb sql container throughput update \
  --account-name edify-cosmos \
  --database-name edify-db \
  --name users \
  --resource-group $RESOURCE_GROUP \
  --throughput 5000

# Enable autoscale
az cosmosdb sql container throughput migrate \
  --account-name edify-cosmos \
  --database-name edify-db \
  --name users \
  --resource-group $RESOURCE_GROUP \
  --throughput-type autoscale \
  --max-throughput 10000
```

### Caching Optimization

**Redis scaling:**

```bash
# Upgrade Redis tier
az redis update \
  --name edify-redis \
  --resource-group $RESOURCE_GROUP \
  --sku Standard \
  --vm-size C3  # 6GB cache
```

---

## Troubleshooting Deployment

### Common Issues

**1. Application won't start**

```bash
# Check logs
az webapp log tail \
  --name edify-app-service \
  --resource-group $RESOURCE_GROUP

# Common causes:
# - Missing environment variables
# - Invalid Azure credentials
# - Database connection failure
```

**2. Slow response times**

```bash
# Check Application Insights
# - High OpenAI latency → increase deployment capacity
# - High search latency → upgrade search tier
# - Low cache hit rate → increase cache size
```

**3. Database connection errors**

```bash
# Verify Cosmos DB connectivity
az cosmosdb check-name-availability \
  --name edify-cosmos \
  --type Microsoft.DocumentDB/databaseAccounts

# Check firewall rules
az cosmosdb network-rule list \
  --name edify-cosmos \
  --resource-group $RESOURCE_GROUP
```

**4. High costs**

```bash
# Review resource usage
az consumption usage list \
  --start-date 2025-12-01 \
  --end-date 2025-12-31

# Optimization strategies:
# - Reduce OpenAI token usage (better caching)
# - Downgrade unused services
# - Enable autoscaling (scale down during off-peak)
```

---

## Support

**Deployment Issues:** deployment-support@edify.ai  
**Azure Questions:** [Azure Support](https://azure.microsoft.com/support/)  
**Documentation:** https://docs.edify.ai/deployment

---

*Deployment Guide Version: 1.2.0 | Last Updated: December 17, 2025*
