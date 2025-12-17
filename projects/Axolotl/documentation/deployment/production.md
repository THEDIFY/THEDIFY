# Deployment Guide for Axolotl Football Analysis Platform

This guide covers deployment of the Axolotl platform to Azure using GitHub Actions CI/CD pipelines.

## Table of Contents

- [Prerequisites](#prerequisites)
- [GitHub Secrets Configuration](#github-secrets-configuration)
- [CI Workflow](#ci-workflow)
- [Deployment Workflow](#deployment-workflow)
- [Local Development with Docker](#local-development-with-docker)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before deploying, ensure you have:

1. **Azure Resources Created**: Use the infrastructure setup scripts
   ```bash
   ./infra/azure_cli_create.sh
   ```
   Or validate existing resources:
   ```bash
   python infra/setup_existing.py --json
   ```

2. **Azure Service Principal**: For GitHub Actions authentication
   ```bash
   az ad sp create-for-rbac --name "axolotl-github-actions" \
     --role contributor \
     --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
     --sdk-auth
   ```

3. **Azure Container Registry (ACR)**: Created during infrastructure setup

4. **Azure App Service or AKS Cluster**: Deployment target

## GitHub Secrets Configuration

Configure the following secrets in your GitHub repository (`Settings > Secrets and variables > Actions`):

### Required Secrets

#### Azure Authentication

- **`AZURE_CREDENTIALS`**: Service principal credentials (JSON format from `az ad sp create-for-rbac`)
  ```json
  {
    "clientId": "<client-id>",
    "clientSecret": "<client-secret>",
    "subscriptionId": "<subscription-id>",
    "tenantId": "<tenant-id>"
  }
  ```

#### Azure Container Registry

- **`ACR_NAME`**: Name of your Azure Container Registry (e.g., `axolotlacr123`)
- **`ACR_USERNAME`**: ACR username (for AKS deployments)
- **`ACR_PASSWORD`**: ACR password (for AKS deployments)

#### Azure Resources

- **`AZURE_RESOURCE_GROUP`**: Name of your Azure resource group
- **`AZURE_WEBAPP_NAME`**: Name of your Azure App Service (for App Service deployments)
- **`AKS_CLUSTER_NAME`**: Name of your AKS cluster (for AKS deployments)

#### Azure Services (Environment Variables)

- **`AZURE_OPENAI_ENDPOINT`**: Your Azure OpenAI endpoint URL
- **`AZURE_SEARCH_ENDPOINT`**: Your Azure Cognitive Search endpoint URL
- **`KEYVAULT_URI`**: Your Azure Key Vault URI (e.g., `https://your-keyvault.vault.azure.net/`)

### Optional Secrets

- **`APP_URL`**: Public URL of your application (for smoke tests)

### Setting Up Secrets via CLI

```bash
# Set Azure credentials
gh secret set AZURE_CREDENTIALS < azure-credentials.json

# Set ACR details
gh secret set ACR_NAME --body "your-acr-name"
gh secret set ACR_USERNAME --body "$(az acr credential show --name your-acr-name --query username -o tsv)"
gh secret set ACR_PASSWORD --body "$(az acr credential show --name your-acr-name --query passwords[0].value -o tsv)"

# Set resource details
gh secret set AZURE_RESOURCE_GROUP --body "axolotl-rg"
gh secret set AZURE_WEBAPP_NAME --body "axolotl-app"

# Set service endpoints
gh secret set AZURE_OPENAI_ENDPOINT --body "https://your-openai.openai.azure.com/"
gh secret set AZURE_SEARCH_ENDPOINT --body "https://your-search.search.windows.net"
gh secret set KEYVAULT_URI --body "https://your-keyvault.vault.azure.net/"
```

## CI Workflow

The CI workflow (`.github/workflows/ci.yml`) runs automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

### CI Steps

1. **Checkout Code**: Clone the repository
2. **Set up Python 3.11**: Install Python and cache dependencies
3. **Set up Node.js 20**: Install Node and cache npm packages
4. **Install Python Dependencies**: Install requirements for backend
5. **Lint with flake8**: Check Python code quality
   - Fails on syntax errors and undefined names
   - Warnings for other issues
6. **Run Python Tests**: Execute pytest on all test files
7. **Install Frontend Dependencies**: Run `npm ci` in `app/frontend`
8. **Lint Frontend**: Run ESLint on TypeScript/React code
9. **Type Check Frontend**: Validate TypeScript types
10. **Build Frontend**: Compile frontend to `app/backend/static`
11. **Run Frontend Tests**: Execute Vitest tests
12. **Upload Build Artifacts**: Save frontend build for 7 days
13. **Check Backend Startup**: Verify Flask app can start

### Running CI Locally

```bash
# Python linting
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics --exclude=.git,__pycache__,node_modules,venv,.venv,build,dist

# Python tests
pytest tests/ -v

# Frontend build
cd app/frontend
npm ci
npm run lint
npm run type-check
npm run build
npm run test:run
```

## Deployment Workflow

The deployment workflow (`.github/workflows/deploy.yml`) runs on:
- Push of version tags (e.g., `v1.0.0`, `release-1.0`)
- Manual trigger via `workflow_dispatch`

### Deployment Targets

Choose between two deployment options:

#### Option 1: Azure App Service (Web App for Containers)

**Best for**: Simple deployments, managed infrastructure, automatic scaling

Manual trigger with App Service:
```bash
gh workflow run deploy.yml -f environment=production -f deploy_target=app-service
```

#### Option 2: Azure Kubernetes Service (AKS)

**Best for**: Advanced orchestration, microservices, custom networking

Manual trigger with AKS:
```bash
gh workflow run deploy.yml -f environment=production -f deploy_target=aks
```

### Deployment Steps

#### Build and Push Job

1. **Checkout Code**: Clone the repository
2. **Set up Docker Buildx**: Enable advanced Docker build features
3. **Log in to Azure**: Authenticate with Azure CLI
4. **Log in to ACR**: Authenticate with Azure Container Registry
5. **Extract Metadata**: Generate Docker tags and labels
6. **Build and Push**: 
   - Build multi-stage Docker image
   - Push to ACR with appropriate tags
   - Use build cache for faster builds

#### Deploy to App Service Job

1. **Log in to Azure**: Authenticate with Azure CLI
2. **Deploy to Web App**: Deploy container image
3. **Configure Settings**: Set environment variables
   - Uses Key Vault references for secrets
   - Configures port and service endpoints
4. **Restart App Service**: Apply new configuration

#### Deploy to AKS Job

1. **Log in to Azure**: Authenticate with Azure CLI
2. **Set AKS Context**: Connect to Kubernetes cluster
3. **Create Namespace**: Ensure `axolotl` namespace exists
4. **Create Image Pull Secret**: Allow pulling from ACR
5. **Deploy to AKS**: Apply Kubernetes manifests
6. **Check Status**: Verify deployment rollout

#### Smoke Test Job

1. **Wait for Deployment**: Allow services to start
2. **Health Check**: Verify application is responding

### Triggering Deployments

#### Via Git Tags

```bash
# Create and push a version tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

#### Manual Trigger

Via GitHub UI:
1. Go to `Actions` tab
2. Select `Deploy to Azure` workflow
3. Click `Run workflow`
4. Choose environment and deployment target
5. Click `Run workflow`

Via GitHub CLI:
```bash
gh workflow run deploy.yml -f environment=staging -f deploy_target=app-service
```

## Local Development with Docker

Use Docker Compose for local development with all services:

### Quick Start

```bash
# Create .env file with Azure credentials
cp .env.example .env
# Edit .env with your Azure credentials

# Start all services
cd docker
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

### Services Included

- **Backend**: Flask application on port 8000
- **Worker**: Background task processor
- **Redis**: Task queue and caching on port 6379
- **PostgreSQL**: Database on port 5432

### Docker Compose Commands

```bash
# Start services in background
docker-compose up -d

# View logs
docker-compose logs -f [service_name]

# Restart a service
docker-compose restart backend

# Rebuild after code changes
docker-compose up -d --build

# Stop and remove containers
docker-compose down

# Stop and remove containers with volumes
docker-compose down -v
```

### Development with Hot Reload

The docker-compose setup mounts local directories for hot reload:
- `/app/backend` → enables Flask auto-reload
- `/src` → enables source code changes
- `/models` → enables model updates

Changes to Python files will automatically reload the application.

## Kubernetes Manifests

For AKS deployments, create Kubernetes manifests in `docker/k8s/`:

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: axolotl-app
  namespace: axolotl
spec:
  replicas: 3
  selector:
    matchLabels:
      app: axolotl
  template:
    metadata:
      labels:
        app: axolotl
    spec:
      containers:
      - name: axolotl
        image: ${ACR_NAME}.azurecr.io/axolotl-app:${IMAGE_TAG}
        ports:
        - containerPort: 8000
        env:
        - name: AZURE_OPENAI_ENDPOINT
          valueFrom:
            secretKeyRef:
              name: azure-secrets
              key: openai-endpoint
        - name: AZURE_SEARCH_ENDPOINT
          valueFrom:
            secretKeyRef:
              name: azure-secrets
              key: search-endpoint
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
      imagePullSecrets:
      - name: acr-secret
```

### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: axolotl-service
  namespace: axolotl
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8000
    protocol: TCP
  selector:
    app: axolotl
```

## Troubleshooting

### CI Workflow Issues

**Build fails during Python dependency installation**
```bash
# Solution: Check requirements.txt for version conflicts
pip install -r requirements.txt --dry-run
```

**Frontend build fails**
```bash
# Solution: Clear node_modules and reinstall
cd app/frontend
rm -rf node_modules package-lock.json
npm install
npm run build
```

**Tests fail**
```bash
# Solution: Run tests locally to debug
pytest tests/ -v --tb=long
cd app/frontend && npm test
```

### Deployment Workflow Issues

**ACR login fails**
```bash
# Solution: Verify ACR credentials
az acr login --name your-acr-name
az acr credential show --name your-acr-name
```

**Docker build fails**
```bash
# Solution: Test Docker build locally
docker build -f docker/Dockerfile.prod -t axolotl-test .
docker run -p 8000:8000 axolotl-test
```

**App Service deployment fails**
```bash
# Solution: Check App Service logs
az webapp log tail --name axolotl-app --resource-group axolotl-rg
```

**AKS deployment fails**
```bash
# Solution: Check Kubernetes pod status
kubectl get pods -n axolotl
kubectl describe pod <pod-name> -n axolotl
kubectl logs <pod-name> -n axolotl
```

### Health Check Failures

**Application not responding**
```bash
# Check if container is running
docker ps

# Check application logs
docker logs axolotl-backend

# Check health endpoint
curl http://localhost:8000/health
```

**Key Vault access denied**
```bash
# Solution: Verify App Service has managed identity with Key Vault access
az webapp identity assign --name axolotl-app --resource-group axolotl-rg
az keyvault set-policy --name your-keyvault --object-id <identity-id> --secret-permissions get list
```

## Best Practices

1. **Use Key Vault References**: Store secrets in Azure Key Vault and reference them in App Service settings
2. **Enable Managed Identity**: Use managed identities instead of connection strings where possible
3. **Tag Releases**: Use semantic versioning for release tags (v1.0.0, v1.1.0, etc.)
4. **Monitor Deployments**: Set up Application Insights for monitoring and alerting
5. **Test Locally**: Always test Docker builds locally before pushing
6. **Review Logs**: Check CI/CD logs for warnings and optimization opportunities
7. **Use Staging**: Deploy to staging environment first, then promote to production

## Additional Resources

- [Azure Container Registry Documentation](https://docs.microsoft.com/azure/container-registry/)
- [Azure App Service Docker Documentation](https://docs.microsoft.com/azure/app-service/containers/)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/azure/aks/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)

## Support

For issues or questions:
- Check [docs/AUDIT.md](AUDIT.md) for system architecture
- Review [infra/README.md](../infra/README.md) for infrastructure setup
- Check GitHub Actions logs for deployment errors
- Contact the development team
