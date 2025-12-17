# Migrating from v1 to v2 Azure Provisioner

**Purpose**: Guide for teams transitioning from `provision-azure-resources.ps1` to v2  
**Scope**: Migration steps, compatibility notes, side-by-side comparison  
**Audience**: DevOps teams, developers using the provisioning scripts

---

## Should You Migrate?

### Migrate Now If You Need:
- ✅ **Multi-region deployments** - Deploy services to different Azure regions
- ✅ **Scenario presets** - Quick deployment configurations without manual flag setting
- ✅ **Better user experience** - Color-coded output, progress indicators, comprehensive summaries
- ✅ **CI/CD improvements** - Better non-interactive mode with proper defaults
- ✅ **Enhanced validation** - Connection testing and configuration verification

### Stay on v1 If:
- ⏸️ You have a working setup and don't need new features
- ⏸️ Your team is unfamiliar with the new workflow
- ⏸️ You're in the middle of a critical deployment cycle

**Note**: Both scripts work with the same infrastructure templates and can coexist.

---

## Key Differences

### What's New in v2

| Feature | v1 | v2 |
|---------|----|----|
| **Location Selection** | Single location for all | Per-service location selection |
| **Deployment Presets** | Manual flag configuration | Full/Standard/Minimal/Custom scenarios |
| **Environment Reuse** | Overwrites settings | Preserves custom settings |
| **Interactive Flow** | Basic prompts | Guided workflow with recommendations |
| **Validation** | Basic connectivity | Comprehensive endpoint testing |
| **Documentation** | Inline comments | Full help system + guides |
| **CI/CD Mode** | Limited | Robust non-interactive mode |

### What's Unchanged

- ✅ Uses same Bicep templates (`infra/main.bicep`)
- ✅ Uses azd CLI for provisioning
- ✅ Generates `.env` file in same location
- ✅ Compatible with `start-enhanced.ps1`
- ✅ Same resource naming conventions
- ✅ Same environment variable structure

---

## Migration Strategies

### Strategy 1: Side-by-Side Testing (Recommended)

Test v2 with a new environment while keeping v1 environments intact.

```powershell
# Keep existing v1 environment
azd env list
# Shows: edify-dev (your current environment)

# Test v2 with new environment
.\scripts\provision-azure-resources-v2.ps1 -EnvironmentName "edify-dev-v2"

# Compare outputs
azd env select edify-dev
azd env get-values > v1-config.txt

azd env select edify-dev-v2
azd env get-values > v2-config.txt

# Review differences
Compare-Object (Get-Content v1-config.txt) (Get-Content v2-config.txt)
```

**Pros**: No risk to existing setup, easy comparison  
**Cons**: Temporarily doubles Azure costs

---

### Strategy 2: In-Place Upgrade

Run v2 on your existing v1 environment (safe due to preservation logic).

```powershell
# Backup current configuration
azd env get-values > backup-config.txt

# Run v2 on existing environment
.\scripts\provision-azure-resources-v2.ps1 -EnvironmentName "edify-dev"

# When prompted:
# - Continue with existing environment? Y
# - Scenario: Custom (preserves your settings)
# - Customize features? N (keeps current configuration)
# - Skip provisioning (if just testing configuration)
```

**Pros**: No new environments needed, preserves customizations  
**Cons**: Requires careful validation afterward

---

### Strategy 3: Clean Migration

Start fresh with v2, migrate data, then decommission v1.

```powershell
# 1. Document v1 configuration
azd env select edify-dev-old
azd env get-values > migration-config.txt

# 2. Provision new v2 environment
.\scripts\provision-azure-resources-v2.ps1 -EnvironmentName "edify-dev-new" -Scenario Standard

# 3. Migrate data (if needed)
# - Export from old storage account
# - Import to new storage account
# - Update Cosmos DB connection strings in app

# 4. Test new environment
cd app
.\start-enhanced.ps1

# 5. Deploy to new environment
azd deploy

# 6. Decommission old environment
azd env select edify-dev-old
azd down --purge
```

**Pros**: Clean slate, latest best practices  
**Cons**: Requires data migration, more time

---

## Step-by-Step Migration Guide

### Phase 1: Preparation (Day 1)

#### 1. Review Current Setup
```powershell
# List environments
azd env list

# Select your current environment
azd env select edify-dev

# Export current configuration
azd env get-values > current-config-backup.txt

# Document custom settings
Get-Content current-config-backup.txt | Select-String "USE_|ENABLE_"
```

#### 2. Review v2 Documentation
- [ ] Read: `AZURE_PROVISIONER_V2_QUICK_REFERENCE.md`
- [ ] Read: `AZURE_PROVISIONER_V2_IMPLEMENTATION_SUMMARY.md`
- [ ] Identify which scenario matches your needs (Full/Standard/Minimal)

#### 3. Plan Your Approach
- [ ] Decide: Side-by-side, In-place, or Clean migration
- [ ] Schedule: Choose low-traffic time window
- [ ] Communicate: Notify team of testing period

---

### Phase 2: Testing (Days 2-3)

#### 1. Test v2 Script Locally
```powershell
# Dry run with skip provisioning
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-test-v2" `
    -Scenario Standard `
    -SkipProvisioning

# Review generated configuration
azd env get-values
```

#### 2. Test Full Provisioning
```powershell
# Provision test environment
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-test-v2" `
    -Scenario Standard

# Validate resources created
az resource list --resource-group rg-edify-test-v2 --output table
```

#### 3. Test Integration with start-enhanced.ps1
```powershell
cd app
.\start-enhanced.ps1

# Verify:
# - App starts without errors
# - Azure services connect successfully
# - Chat functionality works
# - Document upload works (if enabled)
```

#### 4. Compare Configurations
```powershell
# Extract v2 configuration
azd env select edify-test-v2
azd env get-values > v2-test-config.txt

# Compare with v1
azd env select edify-dev
azd env get-values > v1-current-config.txt

# Review differences
code --diff v1-current-config.txt v2-test-config.txt
```

---

### Phase 3: Production Migration (Days 4-5)

#### Option A: If Using In-Place Upgrade

```powershell
# 1. Final backup
azd env select edify-dev
azd env get-values > pre-migration-backup-$(Get-Date -Format 'yyyyMMdd').txt

# 2. Run v2 on existing environment
.\scripts\provision-azure-resources-v2.ps1 -EnvironmentName "edify-dev"

# 3. Choose Custom scenario to preserve settings
# 4. Review and confirm configuration
# 5. Choose whether to re-provision or skip

# 6. Validate
cd app
.\start-enhanced.ps1
# Test all features
```

#### Option B: If Using Clean Migration

```powershell
# 1. Provision new environment
.\scripts\provision-azure-resources-v2.ps1 `
    -EnvironmentName "edify-prod-v2" `
    -Scenario Full

# 2. Migrate data (example for storage)
# Export from old storage
az storage blob download-batch \
    --account-name $oldStorageAccount \
    --source general \
    --destination ./migration-data

# Import to new storage
az storage blob upload-batch \
    --account-name $newStorageAccount \
    --destination general \
    --source ./migration-data

# 3. Update application configuration
# If app has hardcoded resource names, update them

# 4. Deploy to new environment
azd env select edify-prod-v2
azd deploy

# 5. Validate production deployment
# - Test all features
# - Monitor logs: azd logs --follow
# - Check metrics: azd monitor

# 6. Switch DNS/traffic (if applicable)

# 7. Decommission old environment (after validation period)
azd env select edify-dev
azd down --purge
azd env delete edify-dev
```

---

### Phase 4: Validation and Cleanup (Days 6-7)

#### 1. Comprehensive Validation

Use the validation guide:
```powershell
# Run through all scenarios in:
# documentation/deployment/AZURE_PROVISIONER_V2_VALIDATION_GUIDE.md
```

#### 2. Update Team Documentation

- [ ] Update internal wiki/docs with v2 script path
- [ ] Update onboarding guides with new commands
- [ ] Update runbooks with new scenarios
- [ ] Train team on new features (especially location selection)

#### 3. Clean Up Test Environments

```powershell
# Remove test environments
azd env select edify-test-v2
azd down --purge
azd env delete edify-test-v2

# Remove backup files (after confirming migration success)
Remove-Item *-backup-*.txt
```

---

## Command Translation Guide

### Common v1 Commands → v2 Equivalents

#### Basic Provisioning
```powershell
# v1
.\scripts\provision-azure-resources.ps1

# v2
.\scripts\provision-azure-resources-v2.ps1
# More interactive with scenario selection
```

#### With Environment Name
```powershell
# v1
.\scripts\provision-azure-resources.ps1 -EnvironmentName "edify-prod"

# v2 (same)
.\scripts\provision-azure-resources-v2.ps1 -EnvironmentName "edify-prod"
```

#### With Custom Location
```powershell
# v1
.\scripts\provision-azure-resources.ps1 -Location "westus2"

# v2 (enhanced)
.\scripts\provision-azure-resources-v2.ps1
# Prompts for primary location + per-service locations
```

#### Skip Provisioning
```powershell
# v1
.\scripts\provision-azure-resources.ps1 -SkipProvisioning

# v2 (same)
.\scripts\provision-azure-resources-v2.ps1 -SkipProvisioning
```

#### Non-Interactive (NEW in v2)
```powershell
# v1 (not available)

# v2
.\scripts\provision-azure-resources-v2.ps1 -NonInteractive -Scenario Standard
```

---

## Feature Flag Migration

### v1 Approach (Manual)
```powershell
# Set each flag individually
azd env set USE_VECTORS true
azd env set USE_GPT4V true
azd env set USE_SPEECH_OUTPUT_AZURE true
azd env set USE_CHAT_HISTORY_COSMOS true
# ... 10+ more flags ...
azd provision
```

### v2 Approach (Scenario-Based)
```powershell
# Select a preset scenario
.\scripts\provision-azure-resources-v2.ps1 -Scenario Full
# All relevant flags set automatically based on scenario
```

**Migration Tip**: Use Custom scenario to preserve your existing flags:
```powershell
.\scripts\provision-azure-resources-v2.ps1 -Scenario Custom
# Choose 'n' when asked to customize (keeps existing)
```

---

## Troubleshooting Migration Issues

### Issue: v2 Script Doesn't Detect My Existing Environment

**Symptom**: Script creates new environment instead of using existing

**Solution**:
```powershell
# Ensure environment is selected first
azd env list
azd env select your-environment-name

# Then specify exact name in script
.\scripts\provision-azure-resources-v2.ps1 -EnvironmentName "your-environment-name"
```

---

### Issue: Different Configuration After Migration

**Symptom**: Some settings changed unexpectedly

**Solution**:
```powershell
# Restore from backup
azd env get-values > current-state.txt
code --diff pre-migration-backup.txt current-state.txt

# Manually restore specific values
azd env set SETTING_NAME "original-value"

# Or restore all from backup
Get-Content pre-migration-backup.txt | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        azd env set $matches[1] ($matches[2] -replace '^"|"$')
    }
}
```

---

### Issue: Resources Provisioned in Wrong Region

**Symptom**: Services created in unexpected locations

**Solution**:
```powershell
# Check current configuration
azd env get-values | Select-String "LOCATION"

# Delete resources in wrong region
az resource delete --ids /subscriptions/.../resourceGroups/rg-name/providers/.../resource-name

# Set correct locations
azd env set AZURE_OPENAI_RESOURCE_GROUP_LOCATION "correct-region"
azd env set AZURE_SEARCH_SERVICE_LOCATION "correct-region"

# Re-provision
azd provision
```

---

### Issue: Missing Connection Strings

**Symptom**: `.env` file missing storage connection strings

**Solution**:
```powershell
# Re-run script with skip provisioning
.\scripts\provision-azure-resources-v2.ps1 -SkipProvisioning

# Or manually retrieve
$storageAccount = azd env get-values | Select-String "AZURE_STORAGE_ACCOUNT="
az storage account show-connection-string --name $storageAccount --output tsv
```

---

## Rollback Procedure

If you need to roll back to v1:

```powershell
# 1. Restore v1 environment (if you kept it)
azd env select edify-dev-old
azd env get-values

# 2. Or restore from backup
azd env new edify-dev-restored
Get-Content pre-migration-backup.txt | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        azd env set $matches[1] ($matches[2] -replace '^"|"$')
    }
}

# 3. Use v1 script
.\scripts\provision-azure-resources.ps1 -SkipProvisioning

# 4. Validate
cd app
.\start-enhanced.ps1
```

---

## Success Criteria

You've successfully migrated when:

- ✅ v2 script runs without errors
- ✅ All required Azure services provisioned
- ✅ `.env` file generated correctly
- ✅ `start-enhanced.ps1` starts app successfully
- ✅ All application features work as before
- ✅ Team comfortable with new workflow
- ✅ Documentation updated
- ✅ v1 environments decommissioned (optional)

---

## Post-Migration Best Practices

### 1. Document Your Scenario Choice
```powershell
# Add to team wiki:
# "We use Standard scenario for dev, Full for prod"
```

### 2. Standardize Location Choices
```powershell
# Document per-service locations:
# - OpenAI: swedencentral (for GPT-4o)
# - Search: eastus (lowest latency)
# - Storage: eastus (cost-optimized)
# - Cosmos: westus2 (geo-distribution)
```

### 3. Update CI/CD Pipelines
```yaml
# GitHub Actions example
- name: Provision Azure Resources
  run: |
    ./scripts/provision-azure-resources-v2.ps1 `
      -EnvironmentName "edify-${{ github.ref_name }}" `
      -Scenario Standard `
      -NonInteractive
```

### 4. Schedule Regular Reviews
- Monthly: Review Azure costs per scenario
- Quarterly: Evaluate if scenario still matches needs
- Annually: Review location choices for new regional availability

---

## Getting Help

### Resources
- **Quick Reference**: `AZURE_PROVISIONER_V2_QUICK_REFERENCE.md`
- **Validation Guide**: `AZURE_PROVISIONER_V2_VALIDATION_GUIDE.md`
- **Implementation Summary**: `AZURE_PROVISIONER_V2_IMPLEMENTATION_SUMMARY.md`

### Support Channels
- Create GitHub issue for bugs
- Ask in team chat for usage questions
- Consult DevOps team for production migrations

---

## Migration Checklist

### Pre-Migration
- [ ] Backup current environment configuration
- [ ] Document custom settings
- [ ] Review v2 documentation
- [ ] Choose migration strategy
- [ ] Schedule migration window
- [ ] Notify team

### Testing
- [ ] Test v2 with new environment
- [ ] Validate all features work
- [ ] Compare configurations
- [ ] Document any differences
- [ ] Get team approval

### Migration
- [ ] Execute migration strategy
- [ ] Provision new/updated environment
- [ ] Migrate data (if needed)
- [ ] Update application configs
- [ ] Deploy and validate
- [ ] Monitor for issues

### Post-Migration
- [ ] Comprehensive validation
- [ ] Update documentation
- [ ] Train team on v2 features
- [ ] Clean up test environments
- [ ] Decommission v1 environments (optional)
- [ ] Monitor costs and performance

---

**Migration Guide Version**: 1.0  
**Last Updated**: October 14, 2025  
**For**: provision-azure-resources-v2.ps1
