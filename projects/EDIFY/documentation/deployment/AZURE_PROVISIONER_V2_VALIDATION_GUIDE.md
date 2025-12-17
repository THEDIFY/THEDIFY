# Azure Provisioner v2.0 - Validation Guide

**Purpose**: Comprehensive validation procedures for the new Azure resource provisioner  
**Scope**: Testing scenarios, expected behaviors, troubleshooting  
**Audience**: DevOps engineers, developers validating Azure deployments

## Overview

The new `provision-azure-resources-v2.ps1` script introduces interactive location selection, scenario presets, and enhanced validation. This guide covers all testing scenarios and validation procedures.

---

## Pre-Validation Checklist

### Prerequisites
- [ ] Azure CLI installed (`az version`)
- [ ] Azure Developer CLI installed (`azd version`)
- [ ] Authenticated with azd (`azd auth login`)
- [ ] PowerShell 7.0+ (`$PSVersionTable.PSVersion`)
- [ ] Valid Azure subscription access

### Verify Installation
```powershell
# Check Azure CLI
az version

# Check Azure Developer CLI
azd version

# Check authentication
azd auth login --check-status

# Verify subscription
az account show
```

---

## Validation Scenarios

### Scenario 1: Fresh Installation - Standard Preset

**Purpose**: Validate new environment creation with Standard scenario (most common use case)

**Steps**:
```powershell
cd "YC EDIFY"
.\scripts\provision-azure-resources-v2.ps1
```

**Interactive Prompts** (select these options):
1. Environment name: `edify-dev-test`
2. Scenario: `2` (Standard)
3. Primary region: `1` (eastus)
4. Customize locations per service: `n`
5. Proceed with provisioning: `y`

**Expected Results**:
- ✅ Environment created: `edify-dev-test`
- ✅ Resources provisioned: OpenAI, Search, Storage, Cosmos, Document Intelligence
- ✅ Features enabled: Vectors, Chat History (Cosmos), User Upload, Application Insights
- ✅ Features disabled: Speech, GPT-4V
- ✅ `.env` file created in `YC EDIFY/` directory
- ✅ Resource connectivity validated (auth warnings are normal)

**Validation Commands**:
```powershell
# Verify environment
azd env list
azd env get-values | Select-String "AZURE_"

# Check .env file
Get-Content .env | Select-String "AZURE_OPENAI"

# Test local app
.\app\start-enhanced.ps1 -Port 8000
# Navigate to http://localhost:8000
```

**Cleanup**:
```powershell
azd down --purge
azd env delete edify-dev-test
```

---

### Scenario 2: Full Feature Deployment with Custom Locations

**Purpose**: Validate full scenario with per-service location customization

**Steps**:
```powershell
.\scripts\provision-azure-resources-v2.ps1
```

**Interactive Prompts**:
1. Environment name: `edify-full-test`
2. Scenario: `1` (Full)
3. Primary region: `1` (eastus)
4. Customize locations per service: `y`
   - OpenAI: `swedencentral` (for GPT-4o availability)
   - Search: `eastus` (keep default)
   - Storage: `eastus` (keep default)
   - Cosmos: `eastus` (keep default)
   - Document Intelligence: `westus2`
   - Speech: `eastus`
   - Computer Vision: `eastus`
5. Proceed with provisioning: `y`

**Expected Results**:
- ✅ All services provisioned across multiple regions
- ✅ OpenAI in swedencentral, Document Intelligence in westus2
- ✅ All features enabled including Speech and GPT-4V
- ✅ Configuration summary shows correct location mappings

**Validation**:
```powershell
# Verify service locations
azd env get-values | Select-String "LOCATION"

# Should show:
# AZURE_LOCATION=eastus
# AZURE_OPENAI_RESOURCE_GROUP_LOCATION=swedencentral
# AZURE_DOCUMENTINTELLIGENCE_RESOURCE_GROUP_LOCATION=westus2
```

**Cleanup**:
```powershell
azd down --purge
azd env delete edify-full-test
```

---

### Scenario 3: Minimal Deployment (Cost-Optimized)

**Purpose**: Validate minimal scenario for development/testing with lowest cost

**Steps**:
```powershell
.\scripts\provision-azure-resources-v2.ps1 -Scenario Minimal -EnvironmentName "edify-minimal"
```

**Interactive Prompts**:
1. Primary region: `1` (eastus)
2. Customize locations: `n`
3. Proceed with provisioning: `y`

**Expected Results**:
- ✅ Only essential services: OpenAI, Search, Storage
- ✅ NO Cosmos DB (browser chat history instead)
- ✅ NO Document Intelligence, Speech, Computer Vision
- ✅ Local parsers enabled (USE_LOCAL_PDF_PARSER=true)
- ✅ Lower monthly cost (no Cosmos DB serverless)

**Validation**:
```powershell
# Verify minimal services
azd env get-values | Select-String "COSMOS"
# Should be empty or not set

azd env get-values | Select-String "USE_LOCAL"
# Should show USE_LOCAL_PDF_PARSER=true
```

**Cleanup**:
```powershell
azd down --purge
azd env delete edify-minimal
```

---

### Scenario 4: Existing Environment Preservation

**Purpose**: Validate that re-running preserves custom settings

**Setup**:
```powershell
# Create initial environment
.\scripts\provision-azure-resources-v2.ps1 -Scenario Standard -EnvironmentName "edify-preserve-test"

# After provisioning, customize a feature
azd env set USE_GPT4V true
azd env set CUSTOM_SETTING "my-custom-value"
```

**Steps**:
```powershell
# Re-run provisioner
.\scripts\provision-azure-resources-v2.ps1
```

**Interactive Prompts**:
1. Environment name: `edify-preserve-test` (same as before)
2. Continue with existing environment: `y`
3. Scenario: `4` (Custom)
4. Customize features: `n` (to keep preserved)
5. Skip provisioning: (optional, if only testing preservation)

**Expected Results**:
- ✅ Script detects existing environment
- ✅ Shows "Preserved X existing settings" message
- ✅ Custom settings remain: `USE_GPT4V=true`, `CUSTOM_SETTING=my-custom-value`
- ✅ `.env` file regenerated with all settings

**Validation**:
```powershell
azd env get-values | Select-String "GPT4V|CUSTOM_SETTING"
# Should show both custom settings preserved
```

**Cleanup**:
```powershell
azd down --purge
azd env delete edify-preserve-test
```

---

### Scenario 5: Non-Interactive Mode (CI/CD)

**Purpose**: Validate automated deployment without user interaction

**Steps**:
```powershell
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-ci-test" `
    -Scenario Standard `
    -NonInteractive
```

**Expected Results**:
- ✅ No interactive prompts
- ✅ Uses default values: eastus region, Standard scenario
- ✅ Runs `azd provision` without confirmation
- ✅ Suitable for CI/CD pipelines

**Validation**:
```powershell
# Check environment
azd env select edify-ci-test
azd env get-values | Select-String "AZURE_LOCATION"
# Should show AZURE_LOCATION=eastus (default)
```

**Cleanup**:
```powershell
azd down --purge
azd env delete edify-ci-test
```

---

### Scenario 6: Skip Provisioning (Configuration Only)

**Purpose**: Validate environment configuration without Azure provisioning

**Steps**:
```powershell
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-config-test" `
    -Scenario Full `
    -SkipProvisioning
```

**Expected Results**:
- ✅ Environment variables set in azd
- ✅ `.env` file created
- ✅ No Azure resources provisioned (fast execution)
- ✅ Useful for testing configuration logic

**Validation**:
```powershell
# Verify configuration
azd env get-values

# Check .env file exists
Test-Path .env

# Verify no resources in Azure (should fail or show none)
az resource list --resource-group rg-edify-config-test
```

**Cleanup**:
```powershell
azd env delete edify-config-test
Remove-Item .env
```

---

## Integration Validation

### Test with start-enhanced.ps1

After provisioning, validate integration with the local development startup script:

```powershell
# Provision first
.\scripts\provision-azure-resources-v2.ps1 -Scenario Standard

# Start local app
cd app
.\start-enhanced.ps1

# Expected behavior:
# - Loads environment variables from azd
# - Merges with .env file
# - Validates required Azure services
# - Tests connectivity to OpenAI, Search, Storage
# - Starts backend on port 8000
```

**Validation Checklist**:
- [ ] Backend starts without errors
- [ ] Health check responds: `curl http://localhost:8000/health`
- [ ] Chat endpoint works: Test in browser at `http://localhost:8000`
- [ ] No "missing environment variable" errors
- [ ] Azure services authenticate successfully

---

## Common Issues and Solutions

### Issue 1: "Not authenticated to Azure via azd"

**Symptom**: Script exits with authentication error

**Solution**:
```powershell
azd auth login
# Follow browser prompts to authenticate
azd auth login --check-status  # Verify
```

---

### Issue 2: "Deployment preview failed"

**Symptom**: `azd provision --preview` returns errors

**Possible Causes**:
- Invalid location for service
- Subscription quota exceeded
- SKU not available in region

**Solution**:
```powershell
# Check service availability in region
az provider show --namespace Microsoft.CognitiveServices --query "resourceTypes[?resourceType=='accounts'].locations"

# Try different region or change SKU
azd env set AZURE_LOCATION westus2
```

---

### Issue 3: "Resource already exists"

**Symptom**: Provisioning fails with resource name conflict

**Solution**:
```powershell
# Option 1: Use existing environment
azd env select existing-env-name

# Option 2: Delete conflicting resources
azd down --purge

# Option 3: Use different environment name
.\scripts\provision-azure-resources-v2.ps1 -EnvironmentName "edify-new"
```

---

### Issue 4: Storage connection string not retrieved

**Symptom**: `.env` file missing `AZURE_STORAGE_CONNECTION_STRING`

**Solution**:
```powershell
# Manually retrieve connection string
$storageAccount = azd env get-values | Select-String "AZURE_STORAGE_ACCOUNT=" | ForEach-Object { ($_ -split "=")[1] -replace '"' }
$resourceGroup = azd env get-values | Select-String "AZURE_RESOURCE_GROUP=" | ForEach-Object { ($_ -split "=")[1] -replace '"' }

az storage account show-connection-string `
    --name $storageAccount `
    --resource-group $resourceGroup `
    --output tsv

# Add to .env manually or re-run export step
```

---

### Issue 5: Connectivity tests show warnings

**Symptom**: "⚠️ Auth Required" in connectivity tests

**Expected**: This is NORMAL behavior. The script tests endpoint reachability, but full authentication happens at application runtime.

**No Action Needed**: The application will authenticate successfully when running with proper credentials.

---

## Performance Benchmarks

### Expected Execution Times

| Scenario | Configuration | Provisioning | Total Time |
|----------|--------------|--------------|------------|
| Minimal | 3 services | 8-10 min | 9-11 min |
| Standard | 5 services | 12-15 min | 13-16 min |
| Full | 7 services | 15-18 min | 16-19 min |
| Skip Provisioning | Any | 0 min | 1-2 min |

*Times measured on standard Azure regions (eastus, westus2) with good network connectivity*

---

## Validation Checklist Summary

After running the provisioner, verify:

### Environment
- [ ] `azd env list` shows your environment
- [ ] `azd env get-values` returns 50+ variables
- [ ] `.env` file exists in `YC EDIFY/` directory
- [ ] Environment name matches expected value

### Resources
- [ ] Resource group exists in Azure Portal
- [ ] Expected services visible in resource group
- [ ] Service locations match configuration
- [ ] No provisioning errors in `azd show` logs

### Configuration
- [ ] Feature flags match selected scenario
- [ ] Service-specific locations preserved if customized
- [ ] OpenAI models configured (chat, embedding, gpt-4o)
- [ ] Search index name set (`gptkbindex`)
- [ ] Storage containers configured

### Connectivity
- [ ] OpenAI endpoint reachable
- [ ] Search service endpoint reachable
- [ ] Storage account endpoint reachable
- [ ] Cosmos DB endpoint reachable (if enabled)

### Integration
- [ ] `start-enhanced.ps1` runs without errors
- [ ] Backend starts on port 8000
- [ ] Health check endpoint responds
- [ ] Chat functionality works in browser

---

## Next Steps After Validation

1. **Deploy Application**:
   ```powershell
   azd deploy
   ```

2. **Monitor Resources**:
   ```powershell
   azd monitor  # Opens Application Insights
   ```

3. **View Logs**:
   ```powershell
   azd logs --follow
   ```

4. **Modify Features** (if needed):
   ```powershell
   azd env set USE_GPT4V true
   azd provision  # Re-provision with new settings
   ```

5. **Clean Up** (when done):
   ```powershell
   azd down --purge  # Removes all resources
   ```

---

## Troubleshooting Resources

- **Azure Status**: https://status.azure.com/
- **azd Documentation**: https://aka.ms/azd
- **Azure CLI Reference**: https://learn.microsoft.com/cli/azure/
- **EDIFY Deployment Guide**: `YC EDIFY/COMPREHENSIVE_DEPLOYMENT_GUIDE.md`
- **Local Development Guide**: `YC EDIFY/LOCAL_DEVELOPMENT_GUIDE.md`

---

## Reporting Issues

If validation fails, collect this information:

```powershell
# Environment details
azd version
az version
$PSVersionTable

# Configuration
azd env get-values > validation-env-dump.txt

# Logs
azd show > validation-azd-logs.txt

# Error details
$Error[0] | Format-List * -Force > validation-error-details.txt
```

Include these files when reporting issues to the development team.

---

**Last Updated**: October 14, 2025  
**Script Version**: provision-azure-resources-v2.ps1  
**Validated By**: EDIFY DevOps Team
