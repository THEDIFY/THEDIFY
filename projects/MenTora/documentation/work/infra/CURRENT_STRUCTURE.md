# Infrastructure Current Structure

**Last Updated**: 2025-11-22
**Created for**: Phase 0 - Mobile UX Redesign Feature 002

## Overview
The infrastructure is designed for Azure deployment with Cosmos DB (serverless), App Service, and GitHub Actions CI/CD.

## Directory Structure

```
infra/
├── app-service-config.json    # ARM template for Azure resources
├── azure-deploy.yml           # GitHub Actions workflow
├── deploy.sh                  # Manual deployment script
├── startup.sh                 # App Service startup script
├── environment-config.md      # Environment configuration guide
└── README.md                  # Infrastructure documentation
```

## Azure Resources

### App Service
- **Platform**: Linux-based App Service
- **SKU**: B1 (Basic tier)
- **Runtime**: Python 3.12
- **Auto-scaling**: Manual scaling available
- **Health Check**: `/health` endpoint
- **HTTPS**: Enforced by default
- **Custom Domain**: Configurable

### Cosmos DB
- **Mode**: Serverless (pay-per-request)
- **Database Name**: `edify-courses`
- **API**: Core (SQL)

**Collections/Containers**:
1. **users** - User accounts and authentication data
2. **profiles** - User learning profiles (onboarding data)
3. **learning_paths** - Course content and structure
4. **user_progress** - Learning progress tracking
5. **achievements** - User achievements and badges

**Indexes** (Current):
- Default automatic indexing
- **NEEDS ENHANCEMENT** in Phase 2:
  - Composite indexes for course filtering (category + difficulty)
  - Index for title search (text search)
  - Index for recommendation queries

### Application Insights
- **Purpose**: Application monitoring and logging
- **Features**:
  - Request tracking
  - Performance metrics
  - Exception logging
  - Custom telemetry

### Storage (Future)
- **Not Currently Configured**
- **May be needed** for:
  - Course thumbnails/images
  - Video content (or external CDN)
  - User uploads
  - Static assets

## Deployment Configuration

### app-service-config.json
ARM (Azure Resource Manager) template defining all Azure resources.

**Resources Defined**:
- App Service Plan (Linux B1)
- App Service (Python web app)
- Cosmos DB account
- Cosmos DB database
- Cosmos DB containers
- Application Insights

**Parameters**:
- Location (default: West US 2)
- App name (generated from resource group)
- Database name (edify-courses)

### deploy.sh
Manual deployment script for Azure CLI.

**Steps**:
1. Login to Azure
2. Create resource group
3. Deploy ARM template
4. Configure environment variables
5. Deploy application code
6. Restart App Service

**Usage**:
```bash
./infra/deploy.sh
```

### azure-deploy.yml
GitHub Actions workflow for CI/CD.

**Triggers**:
- Push to main/production branch
- Manual workflow dispatch

**Steps**:
1. Checkout code
2. Set up Python environment
3. Install dependencies
4. Run tests (if configured)
5. Build frontend
6. Deploy to Azure App Service

**Secrets Required**:
- `AZURE_CREDENTIALS` - Service principal credentials
- `AZURE_WEBAPP_NAME` - App Service name
- Other Azure-specific secrets

### startup.sh
App Service startup script.

**Purpose**:
- Initialize Python environment
- Install dependencies
- Start Gunicorn server
- Configure workers

**Configuration**:
- Workers: 4 (configurable)
- Worker class: uvicorn.workers.UvicornWorker
- Bind: 0.0.0.0:8000

## Environment Variables

### Required Variables

**Database**:
- `AZURE_COSMOS_ENDPOINT` - Cosmos DB endpoint URL
- `AZURE_COSMOS_KEY` - Cosmos DB access key
- `AZURE_COSMOS_DATABASE` - Database name (default: edify-courses)

**Security**:
- `JWT_SECRET` - Secret key for JWT token signing
- `GOOGLE_CLIENT_ID` - Google OAuth client ID

**Production Flags**:
- `DEBUG` - Set to "false" for production
- `DEV_AUTH` - Set to "false" for production

### Optional Variables

**Payments**:
- `STRIPE_SECRET_KEY` - Stripe API secret key
- `STRIPE_PUBLISHABLE_KEY` - Stripe publishable key

**CORS**:
- `FRONTEND_URL` - Frontend URL for CORS (auto-detected)

**Monitoring** (if not using Application Insights):
- Custom logging endpoints
- External monitoring services

### Missing Variables (To Add in Phase 1+)

**Logging**:
- `LOG_LEVEL` - Logging level (INFO, DEBUG, ERROR)
- `STRUCTLOG_CONFIG` - Structlog configuration

**Security**:
- `AZURE_KEY_VAULT_URL` - Key Vault URL for secrets
- `RATE_LIMIT_CONFIG` - Rate limiting configuration

**Performance**:
- `REDIS_URL` - Redis cache URL (if added)
- `CACHE_TTL` - Cache time-to-live settings

## Deployment Process

### Manual Deployment
1. **Prerequisites**:
   - Azure CLI installed
   - Azure subscription active
   - Required credentials ready

2. **Steps**:
   ```bash
   # Login to Azure
   az login
   
   # Run deployment script
   ./infra/deploy.sh
   
   # Configure secrets in Azure Portal
   # - Navigate to App Service > Configuration
   # - Add GOOGLE_CLIENT_ID
   # - Add STRIPE keys (if using payments)
   
   # Restart App Service
   az webapp restart --name <app-name> --resource-group <rg-name>
   ```

### GitHub Actions Deployment
1. **Setup**:
   - Configure GitHub repository secrets
   - Set up Azure service principal
   - Configure workflow triggers

2. **Automatic Deployment**:
   - Push to main branch
   - GitHub Actions runs automatically
   - Tests execute (if configured)
   - Builds frontend
   - Deploys to Azure
   - Verifies deployment

### Post-Deployment Configuration
1. Set environment variables in Azure Portal
2. Configure custom domain (if applicable)
3. Set up SSL certificate
4. Configure Application Insights
5. Test health endpoint
6. Verify Google OAuth
7. Test database connectivity

## Security Configuration

### Current Security Measures
- ✅ HTTPS enforced by default
- ✅ Cosmos DB keys stored in App Settings (encrypted)
- ✅ JWT tokens signed with secret key
- ✅ CORS configured for production domains
- ✅ Google OAuth for authentication

### Missing Security Features (To Add in Phase 1+)
- ⬜ Azure Key Vault integration for secrets
- ⬜ Rate limiting middleware
- ⬜ Audit logging for sensitive operations
- ⬜ IP whitelisting (if needed)
- ⬜ Web Application Firewall (WAF)
- ⬜ DDoS protection configuration

## Monitoring & Logging

### Current Monitoring
- **Application Insights**:
  - Request/response tracking
  - Performance metrics
  - Exception logging
  - Custom telemetry

- **App Service Logs**:
  - stdout/stderr capture
  - Platform logs
  - Web server logs

### Missing Monitoring (To Add in Phase 1+)
- ⬜ Structured JSON logging (structlog)
- ⬜ Custom dashboards
- ⬜ Alerting rules
- ⬜ Performance baselines
- ⬜ User behavior analytics
- ⬜ Error rate monitoring
- ⬜ API response time tracking

## Scalability Configuration

### Current Scalability
- **App Service Plan**: B1 (1 core, 1.75 GB RAM)
  - Manual scale-up available
  - No auto-scaling configured

- **Cosmos DB**: Serverless mode
  - Auto-scales request units (RUs)
  - Pay-per-request pricing
  - No provisioned throughput

### Scalability Enhancements (Future)
- ⬜ Auto-scaling rules for App Service
- ⬜ Scale-out to multiple instances
- ⬜ CDN for static assets
- ⬜ Redis cache for frequently accessed data
- ⬜ Database read replicas (if needed)
- ⬜ Load balancer configuration

## Backup & Disaster Recovery

### Current Backup Strategy
- **Cosmos DB**:
  - Automatic backups every 4 hours
  - 7-day retention by default
  - Point-in-time restore available

- **App Service**:
  - Code deployed from Git repository
  - Configuration stored in ARM template
  - Easy redeployment from source

### Missing DR Features (To Add Later)
- ⬜ Regular backup testing
- ⬜ Multi-region deployment
- ⬜ Failover procedures
- ⬜ Recovery time objective (RTO) definition
- ⬜ Recovery point objective (RPO) definition

## Cost Optimization

### Current Costs (Estimated)
- **App Service B1**: ~$13/month
- **Cosmos DB Serverless**: Variable (pay-per-request)
  - ~$0.25 per million RUs
  - ~$0.25 per GB storage/month
- **Application Insights**: Free tier available
- **Total**: ~$20-50/month for low traffic

### Cost Optimization Strategies
- Use serverless Cosmos DB for variable traffic
- Scale down during off-hours (manual)
- Monitor and optimize RU consumption
- Use CDN for static assets (reduce egress)
- Consider reserved instances for production

## CI/CD Pipeline

### GitHub Actions Workflow
**File**: azure-deploy.yml

**Stages**:
1. **Build**:
   - Checkout code
   - Install dependencies
   - Run linters
   - Run tests

2. **Test** (if configured):
   - Unit tests
   - Integration tests
   - Coverage reports

3. **Deploy**:
   - Build frontend (Vite)
   - Package backend
   - Deploy to Azure App Service
   - Run smoke tests

**Environments**:
- Development (auto-deploy from dev branch)
- Staging (auto-deploy from staging branch)
- Production (manual approval from main branch)

### Missing CI/CD Features (To Add in Phase 1+)
- ⬜ Frontend E2E tests in pipeline
- ⬜ Security scanning
- ⬜ Dependency vulnerability checks
- ⬜ Performance testing
- ⬜ Blue-green deployment
- ⬜ Rollback automation

## Infrastructure as Code (IaC)

### Current IaC
- **ARM Templates**: app-service-config.json
  - Declarative resource definition
  - Version controlled
  - Reproducible deployments

### Alternative IaC Options (Future)
- ⬜ **Terraform**: More portable across clouds
- ⬜ **Bicep**: Simpler ARM template syntax
- ⬜ **Pulumi**: Infrastructure as code with Python

## Notes for Phase 1+ Implementation

### Must Preserve
- ✅ Existing Azure resource configuration
- ✅ Cosmos DB collections and data
- ✅ App Service deployment process
- ✅ GitHub Actions workflow
- ✅ Environment variable configuration
- ✅ HTTPS/SSL configuration

### Must Add (Phase 2+)
- ⬜ Composite indexes in Cosmos DB for filtering
- ⬜ Structured logging configuration
- ⬜ Azure Key Vault integration
- ⬜ Rate limiting configuration
- ⬜ Enhanced monitoring dashboards
- ⬜ Auto-scaling rules

### Must Test (Phase 9)
- ⬜ Deployment process end-to-end
- ⬜ Environment variable propagation
- ⬜ Database connectivity
- ⬜ OAuth flow in production
- ⬜ Payment processing (if enabled)
- ⬜ Performance under load
- ⬜ Failover scenarios

### Phase-Specific Infrastructure Tasks

**Phase 2** (Foundational Infrastructure):
- T024: Update Cosmos DB indexes for course filtering
  - Add composite index: (category, difficulty, title)
  - Add text search index for title
  - Run backend/app/db/cosmos_setup.py

**Phase 9.4** (Security & Compliance):
- T200: Implement Azure Key Vault integration
  - Move sensitive secrets to Key Vault
  - Configure managed identity
  - Update config.py to read from Key Vault

**Phase 9.8** (Deployment & DevOps):
- T219: Update Dockerfile with new dependencies
- T220: Update docker-compose.yml (if using)
- T221: Create Azure infrastructure scripts
- T222: Update CI/CD pipeline
- T223: Create deployment checklist

## Conclusion

The infrastructure is production-ready for current application but needs enhancements for feature 002:
- Cosmos DB indexes need optimization for filtering
- Structured logging not configured
- Azure Key Vault not integrated
- Rate limiting not implemented
- Auto-scaling not configured
- Enhanced monitoring not set up

Phase 1+ will add these capabilities while maintaining existing infrastructure stability.
