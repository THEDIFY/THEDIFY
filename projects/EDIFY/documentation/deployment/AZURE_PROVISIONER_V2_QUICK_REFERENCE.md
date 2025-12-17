# Azure Provisioner v2.0 - Quick Reference Guide

**Purpose**: Quick command reference and usage patterns for the new provisioner  
**Scope**: Common commands, parameter combinations, quick troubleshooting  
**Audience**: Developers and DevOps engineers

---

## Quick Start

### Basic Interactive Deployment (Recommended)
```powershell
cd "YC EDIFY"
.\scripts\provision-azure-resources-v2.ps1
```
**What Happens**:
1. ✅ Validates prerequisites (Azure CLI, azd)
2. 🌍 **Lets you choose locations for AI services** (like `azd up` but with per-service control)
3. ⚙️ Configures environment variables
4. 🚀 Provisions Azure resources
5. 📋 Generates `.env` file for local development

**Location Selection**: 
- Choose **one primary location** for all services (simple)
- OR customize **per-service** (recommended for AI services like OpenAI)

💡 **See [AZURE_LOCATION_SELECTION_GUIDE.md](./AZURE_LOCATION_SELECTION_GUIDE.md) for detailed location selection guidance**

---

## Common Usage Patterns

### Standard Development Environment
```powershell
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-dev" `
    -Scenario Standard
```
**Creates**: OpenAI, Search, Storage, Cosmos, Document Intelligence  
**Cost**: ~$50-100/month  
**Use Case**: Most development work

---

### Full Production Environment
```powershell
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-prod" `
    -Scenario Full
```
**Creates**: All services including Speech and Computer Vision  
**Cost**: ~$150-250/month  
**Use Case**: Production deployments

---

### Minimal Testing Environment
```powershell
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-test" `
    -Scenario Minimal
```
**Creates**: OpenAI, Search, Storage only  
**Cost**: ~$20-40/month  
**Use Case**: Quick tests, CI/CD, demos

---

### CI/CD Pipeline Mode
```powershell
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-$env:BUILD_ID" `
    -Scenario Standard `
    -NonInteractive
```
**Features**: No prompts, uses defaults, suitable for automation  
**Use Case**: GitHub Actions, Azure Pipelines

---

### Configuration Only (No Provisioning)
```powershell
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-dev" `
    -Scenario Standard `
    -SkipProvisioning
```
**Features**: Sets up azd environment and .env file without provisioning  
**Use Case**: Testing configuration logic, updating .env

---

### Custom Subscription
```powershell
.\scripts\provision-azure-resources-v2.ps1 `
    -SubscriptionId "YOUR-SUBSCRIPTION-GUID" `
    -EnvironmentName "edify-custom"
```
**Use Case**: Multi-subscription setups

---

## Parameters Reference

| Parameter | Values | Default | Description |
|-----------|--------|---------|-------------|
| `-EnvironmentName` | string | prompt | azd environment name |
| `-SubscriptionId` | GUID | current | Azure subscription ID |
| `-Scenario` | Full, Standard, Minimal, Custom | prompt | Deployment preset |
| `-SkipProvisioning` | switch | false | Skip Azure provisioning |
| `-NonInteractive` | switch | false | No prompts (CI/CD) |

---

## Scenario Comparison

| Feature | Minimal | Standard | Full |
|---------|---------|----------|------|
| Azure OpenAI | ✅ | ✅ | ✅ |
| AI Search | ✅ | ✅ | ✅ |
| Storage | ✅ | ✅ | ✅ |
| Cosmos DB | ❌ | ✅ | ✅ |
| Document Intelligence | ❌ | ✅ | ✅ |
| Speech Service | ❌ | ❌ | ✅ |
| Computer Vision | ❌ | ❌ | ✅ |
| Vector Search | ✅ | ✅ | ✅ |
| GPT-4 Vision | ❌ | ❌ | ✅ |
| User Upload | ❌ | ✅ | ✅ |
| Chat History | Browser | Cosmos | Cosmos |
| Est. Monthly Cost | $20-40 | $50-100 | $150-250 |

---

## Location Selection Guide

### Most Reliable Regions for All Services
- `eastus` (US East - Virginia) - **Recommended default**
- `westus2` (US West 2 - Washington)
- `westeurope` (Netherlands)
- `uksouth` (London)

### Best for GPT-4o and Advanced Models
- `swedencentral` (Sweden)
- `switzerlandnorth` (Switzerland)
- `eastus2` (US East 2)

### Cost-Optimized Regions
- `eastus` (US East)
- `southcentralus` (US South Central)

---

## Quick Troubleshooting

### "Not authenticated"
```powershell
azd auth login
```

### "Resource already exists"
```powershell
azd env select existing-env
# Or delete and recreate:
azd down --purge
```

### "Quota exceeded"
```powershell
# Try different region
azd env set AZURE_LOCATION westus2
```

### Missing connection strings
```powershell
# Re-run with skip provisioning
.\scripts\provision-azure-resources-v2.ps1 -SkipProvisioning
```

---

## Post-Provisioning Commands

### Start Local Development
```powershell
cd app
.\start-enhanced.ps1
```

### Deploy to Azure
```powershell
azd deploy
```

### View Application Logs
```powershell
azd logs --follow
```

### Monitor Resources
```powershell
azd monitor
```

### Modify Feature Flags
```powershell
azd env set USE_GPT4V true
azd provision  # Re-provision with new settings
```

### Clean Up Resources
```powershell
azd down  # Keeps environment config
azd down --purge  # Removes everything
```

---

## Environment Management

### List Environments
```powershell
azd env list
```

### Switch Environments
```powershell
azd env select edify-prod
```

### View Configuration
```powershell
azd env get-values
azd env get-values | Select-String "OPENAI"
```

### Export Configuration
```powershell
azd env get-values > my-config.txt
```

### Delete Environment
```powershell
azd env delete edify-old
```

---

## Integration with Existing Workflows

### After Provisioning
The script creates `.env` file in `YC EDIFY/` directory. This is automatically loaded by:
- `app/start-enhanced.ps1` (local development)
- Docker Compose (containerized development)
- Backend application (runtime configuration)

### No Manual Steps Required
The script handles:
- ✅ azd environment configuration
- ✅ Azure resource provisioning
- ✅ Connection string retrieval
- ✅ .env file generation
- ✅ Feature flag configuration

---

## Tips and Best Practices

### 1. Use Descriptive Environment Names
```powershell
# Good
-EnvironmentName "edify-dev-john"
-EnvironmentName "edify-prod-v2"
-EnvironmentName "edify-feature-vectors"

# Avoid
-EnvironmentName "test"
-EnvironmentName "env1"
```

### 2. Start with Standard Scenario
Most developers should use Standard. Only use Full if you need Speech/Vision features.

### 3. Preserve Custom Settings
Re-running the script on an existing environment preserves your customizations. It's safe to re-run.

### 4. Use Skip Provisioning for Config Changes
If you only want to update feature flags or regenerate .env:
```powershell
.\scripts\provision-azure-resources-v2.ps1 -SkipProvisioning
```

### 5. Clean Up Test Environments
```powershell
# List all your environments
azd env list

# Delete unused ones
azd down --purge
azd env delete old-env-name
```

---

## Example Workflows

### Scenario: New Developer Onboarding
```powershell
# 1. Install prerequisites
winget install Microsoft.AzureCLI
winget install Microsoft.Azd

# 2. Authenticate
azd auth login

# 3. Provision development environment
cd "YC EDIFY"
.\scripts\provision-azure-resources-v2.ps1

# 4. Start local app
cd app
.\start-enhanced.ps1
```

### Scenario: Feature Branch Testing
```powershell
# Create temporary environment for feature
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-feature-$env:USERNAME" `
    -Scenario Minimal `
    -NonInteractive

# Test your feature
cd app
.\start-enhanced.ps1

# Clean up after merge
azd down --purge
azd env delete "edify-feature-$env:USERNAME"
```

### Scenario: Production Deployment
```powershell
# 1. Provision production environment
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-prod" `
    -Scenario Full

# Follow prompts, select production regions

# 2. Deploy application
azd deploy

# 3. Verify deployment
azd logs --follow

# 4. Set up monitoring
azd monitor
```

---

## Getting Help

### View Script Help
```powershell
Get-Help .\scripts\provision-azure-resources-v2.ps1 -Full
```

### Script Examples
```powershell
Get-Help .\scripts\provision-azure-resources-v2.ps1 -Examples
```

### Validation Guide
See: `documentation/deployment/AZURE_PROVISIONER_V2_VALIDATION_GUIDE.md`

### Comprehensive Deployment Guide
See: `YC EDIFY/COMPREHENSIVE_DEPLOYMENT_GUIDE.md`

---

**Quick Reference Card**

```
INTERACTIVE:  .\scripts\provision-azure-resources-v2.ps1
STANDARD:     -Scenario Standard
FULL:         -Scenario Full
MINIMAL:      -Scenario Minimal
CI/CD:        -NonInteractive
CONFIG ONLY:  -SkipProvisioning
CUSTOM SUB:   -SubscriptionId "GUID"

POST-PROVISION:
  Start:      .\app\start-enhanced.ps1
  Deploy:     azd deploy
  Logs:       azd logs --follow
  Monitor:    azd monitor
  Clean:      azd down --purge
```

---

**Last Updated**: October 14, 2025  
**Script Version**: provision-azure-resources-v2.ps1
