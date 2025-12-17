# Example: Interactive Location Selection Session

## What You'll See When You Run the Script

This document shows **exactly** what the interactive location selection looks like when you run:

```powershell
.\scripts\provision-azure-resources-v2.ps1
```

---

## Full Session Example

### Part 1: Primary Location Selection (Like `azd up`)

```powershell
PS C:\Users\rasan\EDIFY0\EDIFYbeta\YC EDIFY> .\scripts\provision-azure-resources-v2.ps1

╔════════════════════════════════════════════════════════════════════════╗
║     EDIFY Azure Resource Provisioner v2.0                               ║
║     Interactive Azure Infrastructure Deployment                         ║
╚════════════════════════════════════════════════════════════════════════╝

[Step 1/9] Validating Prerequisites
  ✓ Azure CLI found: 2.63.0
  ✓ Azure Developer CLI found: 1.11.0
  ✓ Authenticated as: molmosantillon14@gmail.com
  ✓ Subscription: 76511550-ea91-445e-925f-e3c4ff04c0b0
✅ Prerequisites validated

[Step 2/9] Initializing Azure Developer Environment
Enter environment name (default: edify-dev): [Enter]
✅ Environment initialized: edify-dev

[Step 3/9] Selecting Deployment Scenario
Available Scenarios:
  1. Full     - All features (OpenAI, Search, Storage, Cosmos, DocIntel, Speech, Vision)
  2. Standard - Core features (OpenAI, Search, Storage, Cosmos, DocIntel)
  3. Minimal  - Essential only (OpenAI, Search, Storage)
  4. Custom   - Select features manually

Select scenario (1-4, default: 2): 2
✅ Scenario selected: Standard

[Step 4/9] Configuring Service Locations

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

### Part 2: AI Service Location Customization (New Feature!)

```powershell
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌍 SERVICE LOCATION CUSTOMIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ Storage Service

  Current location: eastus
  ℹ️  Note: Available in all regions
  ✅ Recommended regions: eastus, eastus2, westus, westus2, westus3

  Enter new location (or press Enter to keep current): [Enter]
  → Keeping current location: eastus

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ Cosmos Service

  Current location: eastus
  ℹ️  Note: Multi-region replication available
  ✅ Recommended regions: eastus, eastus2, westus, westus2, westeurope

  Enter new location (or press Enter to keep current): [Enter]
  → Keeping current location: eastus

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 DocumentIntelligence Service

  Current location: eastus
  ℹ️  Note: Limited regional availability
  ✅ Recommended regions: eastus, westus2, westeurope, northeurope
  ⚠️  AI service - verify model availability in target region!

  Enter new location (or press Enter to keep current): [Enter]
  → Keeping current location: eastus

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Service locations configured
```

### Part 3: Remaining Steps (Standard Flow)

```powershell
[Step 5/9] Configuring Environment Variables
  ✓ Set AZURE_LOCATION: eastus
  ✓ Set AZURE_OPENAI_RESOURCE_GROUP_LOCATION: swedencentral
  ✓ Set AZURE_SEARCH_SERVICE_LOCATION: eastus
  ✓ Set AZURE_DOCUMENTINTELLIGENCE_RESOURCE_GROUP_LOCATION: eastus
  ... (50+ environment variables configured)
✅ Environment variables configured

[Step 6/9] Provisioning Azure Resources

📋 Deployment Preview:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Environment:       edify-dev
Subscription:      76511550-ea91-445e-925f-e3c4ff04c0b0
Primary Location:  eastus
Scenario:          Standard

Services to Deploy:
  🤖 OpenAI                    → swedencentral (oai-edifydevea123)
  ⚙️  AI Search                 → eastus (search-edifydevea123)
  ⚙️  Storage Account           → eastus (stedifydevea123)
  ⚙️  User Storage Account      → eastus (stuseredifydevea123)
  ⚙️  Cosmos DB                 → eastus (cosmos-edifydevea123)
  🤖 Document Intelligence     → eastus (di-edifydevea123)

Estimated Cost: ~$50-100/month
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proceed with provisioning? (y/N): y

Provisioning Azure resources (this may take 10-15 minutes)...
  [Azure provisioning output...]
✅ Azure resources provisioned successfully

[Step 7/9] Exporting Configuration
  ✓ Retrieved connection strings and keys
  ✓ Generated .env file
  ✓ Loaded session environment variables
✅ Configuration exported

[Step 8/9] Validating Connectivity
  ✓ Azure OpenAI: https://oai-edifydevea123.openai.azure.com/
  ✓ AI Search: https://search-edifydevea123.search.windows.net/
  ✓ Storage: https://stedifydevea123.blob.core.windows.net/
✅ Connectivity validated

[Step 9/9] Deployment Summary

╔════════════════════════════════════════════════════════════════════════╗
║                      DEPLOYMENT COMPLETE                                ║
╚════════════════════════════════════════════════════════════════════════╝

Environment: edify-dev
Region Configuration:
  • Primary Location: eastus
  • OpenAI: swedencentral (optimized for GPT-4o)
  • Other Services: eastus

Next Steps:
  1. Start local app:
     cd app
     .\start-enhanced.ps1

  2. View environment:
     azd env get-values

  3. Deploy application:
     azd deploy

Documentation: YC EDIFY/documentation/deployment/
```

---

## Simple Example (No Customization)

If you just want to use one location for everything:

```powershell
PS> .\scripts\provision-azure-resources-v2.ps1

# ... (steps 1-3 same as above)

[Step 4/9] Configuring Service Locations

Select primary region (1-10 or custom, default: 1): 1
✅ Primary location: eastus

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌍 SERVICE LOCATION CUSTOMIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AI services have different regional availability. You can:
  • Use primary location (eastus) for all services (faster setup)
  • Customize per-service (recommended for AI services like OpenAI)

Customize locations for individual services? [y/N]: n
  → Using primary location (eastus) for all services

✅ Service locations configured

# ... (continues with provisioning)
```

**Result**: All services deployed to `eastus`, no per-service customization.

---

## Key Takeaways

1. **Just like `azd up`**: You choose a primary location first
2. **Enhanced for AI**: You can then customize locations for AI services (OpenAI, Document Intelligence, etc.)
3. **Visual guidance**: Script highlights AI services with 🤖 emoji and warns about model availability
4. **Optional**: You can skip customization and use primary location for all services
5. **Informed choices**: Each service shows recommended regions and availability notes

---

## Related Documentation

- **[AZURE_LOCATION_SELECTION_GUIDE.md](./AZURE_LOCATION_SELECTION_GUIDE.md)**: Comprehensive location selection guide
- **[AZURE_PROVISIONER_V2_QUICK_REFERENCE.md](./AZURE_PROVISIONER_V2_QUICK_REFERENCE.md)**: Command reference and usage patterns
- **[AZURE_PROVISIONER_V2_VALIDATION_GUIDE.md](./AZURE_PROVISIONER_V2_VALIDATION_GUIDE.md)**: Testing and validation scenarios
