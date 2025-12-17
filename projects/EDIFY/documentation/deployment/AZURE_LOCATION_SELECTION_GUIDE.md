# Azure Location Selection Guide for EDIFY Provisioner v2

## Overview

The EDIFY Azure Provisioner v2 allows you to select locations **interactively** during provisioning, similar to `azd up`, but with **enhanced control for AI services** that have varying regional availability.

## Quick Answer: Yes, You Can Choose Locations!

When you run:
```powershell
.\scripts\provision-azure-resources-v2.ps1
```

The script will guide you through location selection with two approaches:

### Approach 1: Simple (Like `azd up`)
- Choose **one primary location** for all services
- Fast setup, good for testing
- Example: All services in `eastus`

### Approach 2: Per-Service Customization (Recommended for Production)
- Choose **different locations for each service**
- Critical for AI services (OpenAI, Document Intelligence, etc.)
- Ensures you get the models you need in regions where they're available

---

## Interactive Workflow Example

### Step 1: Primary Location Selection

```
🌍 SERVICE LOCATION CUSTOMIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Recommended Azure Regions:
  1. eastus       - US East (Virginia)
  2. eastus2      - US East 2 (Virginia)
  3. westus       - US West (California)
  4. westus3      - US West 3 (Arizona)
  5. westeurope   - West Europe (Netherlands)
  6. northeurope  - North Europe (Ireland)
  7. uksouth      - UK South (London)
  8. japaneast    - Japan East (Tokyo)
  9. australiaeast - Australia East (Sydney)
 10. swedencentral - Sweden Central

Select primary region (1-10 or custom, default: 1): 1
✅ Primary location: eastus
```

### Step 2: AI Service Location Customization

```
AI services have different regional availability. You can:
  • Use primary location (eastus) for all services (faster setup)
  • Customize per-service (recommended for AI services like OpenAI)

Customize locations for individual services? [y/N]: y

📍 Configuring locations for each service...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 OpenAI Service

  Current location: eastus
  ℹ️  Note: GPT-4o available in eastus, swedencentral, westus
  ✅ Recommended regions: eastus, eastus2, swedencentral, westus, westus3
  ⚠️  AI service - verify model availability in target region!

  Enter new location (or press Enter to keep current): swedencentral
  ✓ Updated OpenAI location: swedencentral

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ Search Service

  Current location: eastus
  ℹ️  Note: Available in most regions
  ✅ Recommended regions: eastus, eastus2, westus, westus2, westus3

  Enter new location (or press Enter to keep current): [Enter]
  → Keeping current location: eastus
```

---

## AI Service Location Recommendations

### 🤖 Azure OpenAI Service

**Critical**: GPT-4o and GPT-4o-mini availability varies by region!

| Model | Available Regions |
|-------|------------------|
| **gpt-4o** | eastus, swedencentral, westus |
| **gpt-4o-mini** | eastus, northcentralus, swedencentral, westus |
| **text-embedding-3-large** | eastus, eastus2, northcentralus, swedencentral, westus |

**Recommendation**: 
- **Production**: `swedencentral` (best GPT-4o availability)
- **Development**: `eastus` (reliable, good for testing)
- **US West**: `westus` (low latency for West Coast users)

### 📄 Document Intelligence

**Limited Availability**: Not in all regions!

| Region | Status |
|--------|--------|
| eastus, westus2, westeurope | ✅ Fully available |
| swedencentral, japaneast | ⚠️ Limited or unavailable |

**Recommendation**: `eastus` or `westeurope`

### 🎤 Speech Service

**Wide Availability**: Available in most regions

**Recommendation**: Use primary location or choose based on latency

### 👁️ Computer Vision (for GPT-4V)

**Wide Availability**: Available in most regions

**Recommendation**: Use primary location

---

## Common Scenarios

### Scenario 1: All US East (Simple)
```powershell
# Run script
.\scripts\provision-azure-resources-v2.ps1

# When prompted:
Select primary region: 1  # eastus
Customize locations for individual services? [y/N]: N  # Use eastus for all
```

**Result**: All services in `eastus`

---

### Scenario 2: Optimize for GPT-4o (Production)
```powershell
# Run script
.\scripts\provision-azure-resources-v2.ps1

# When prompted:
Select primary region: 10  # swedencentral
Customize locations for individual services? [y/N]: y

# Then for each service:
OpenAI: swedencentral  # Best GPT-4o availability
Search: eastus  # Keep closer to primary data
Storage: eastus  # Keep with Search
Cosmos DB: eastus  # Keep with Storage
Document Intelligence: eastus  # Must be eastus/westus2/westeurope
```

**Result**: OpenAI in Sweden, other services in US East

---

### Scenario 3: Multi-Region High Availability
```powershell
# Run script
.\scripts\provision-azure-resources-v2.ps1

# When prompted:
Select primary region: 1  # eastus
Customize locations for individual services? [y/N]: y

# Then for each service:
OpenAI: swedencentral  # Best model availability
Search: eastus  # Primary region
Storage: eastus2  # Geo-redundancy
Cosmos DB: eastus  # Multi-region writes enabled in Bicep
Document Intelligence: westus2  # Separate region for load distribution
```

**Result**: Geo-distributed deployment

---

## Non-Interactive Mode (CI/CD)

For automated deployments, use parameter overrides:

```powershell
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-prod" `
    -Location "eastus" `
    -Scenario "Full" `
    -NonInteractive
```

**Default Behavior**: Uses `eastus` for all services (no customization)

**To Customize in CI/CD**: Set environment variables before running:

```powershell
# Set primary location
azd env set AZURE_LOCATION "eastus"

# Override specific service locations
azd env set AZURE_OPENAI_RESOURCE_GROUP_LOCATION "swedencentral"
azd env set AZURE_SEARCH_SERVICE_LOCATION "eastus"
azd env set AZURE_DOCUMENTINTELLIGENCE_RESOURCE_GROUP_LOCATION "eastus"

# Then run provisioner
.\scripts\provision-azure-resources-v2.ps1 -NonInteractive
```

---

## Verification After Provisioning

Check which locations were used:

```powershell
# View all environment variables
azd env get-values | Select-String "LOCATION"

# Example output:
AZURE_LOCATION="eastus"
AZURE_OPENAI_RESOURCE_GROUP_LOCATION="swedencentral"
AZURE_SEARCH_SERVICE_LOCATION="eastus"
AZURE_DOCUMENTINTELLIGENCE_RESOURCE_GROUP_LOCATION="eastus"
```

Or check the Azure Portal:
1. Go to your resource group
2. View each resource's location in the list

---

## Troubleshooting

### Issue: "Model not available in this region"

**Symptom**: Deployment succeeds but model deployment fails

**Solution**: 
1. Check [Azure OpenAI model availability](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models#model-summary-table-and-region-availability)
2. Re-run provisioner and select correct region for OpenAI
3. Recommended: `swedencentral` for GPT-4o

### Issue: "Document Intelligence not available"

**Symptom**: Provisioning fails for Document Intelligence resource

**Solution**: Use one of these regions:
- `eastus`
- `westus2`
- `westeurope`

### Issue: "Want to change location after provisioning"

**Solution**: 
1. Delete the resource: `az resource delete --ids <resource-id>`
2. Re-run provisioner: `.\scripts\provision-azure-resources-v2.ps1`
3. Select different location when prompted

---

## Best Practices

### ✅ DO
- **Verify AI model availability** before selecting OpenAI location
- **Use `swedencentral`** for production OpenAI (best GPT-4o availability)
- **Keep data services together** (Search, Storage, Cosmos in same region for lower latency)
- **Test location choices** in dev environment before production

### ❌ DON'T
- **Don't assume all regions have all models** (GPT-4o is region-limited!)
- **Don't put all services in obscure regions** (some services aren't available everywhere)
- **Don't change locations frequently** (causes data migration overhead)

---

## Quick Reference Commands

```powershell
# Interactive with location selection (recommended for first-time)
.\scripts\provision-azure-resources-v2.ps1

# Non-interactive with defaults
.\scripts\provision-azure-resources-v2.ps1 -NonInteractive

# Check current locations
azd env get-values | Select-String "LOCATION"

# Change location manually (before provisioning)
azd env set AZURE_OPENAI_RESOURCE_GROUP_LOCATION "swedencentral"

# View Azure resource locations (after provisioning)
az resource list --resource-group "rg-edify-dev" --query "[].{Name:name, Location:location}" --output table
```

---

## Summary

**Yes, you can choose locations!** The EDIFY provisioner v2 gives you:

1. **Simple mode**: One location for all services (like `azd up`)
2. **Advanced mode**: Per-service location selection (better for AI services)
3. **AI service warnings**: Highlights when model availability varies by region
4. **Recommended regions**: Shows best regions for each service type

**Recommendation**: For production with GPT-4o, run interactively and put OpenAI in `swedencentral` while keeping other services in your primary region.
