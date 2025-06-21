# Backend Remote Usage Examples

## Scenario: Multi-Environment Deployment with Azure Backend

### Step 1: Setup Backend Infrastructure (Optional)

If you don't have existing Azure Storage infrastructure:

```bash
# Run the automated setup script
make backend-setup

# Choose option 1 (Azure) when prompted
# This will create:
# - Resource Group: terraform-state-rg
# - Storage Account: tfstate123456789
# - Container: tfstate
```

### Step 2: Update Backend Configuration

Edit `environments/dev/backend-azure.tfvars`:
```hcl
resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate123456789"  # Your actual storage account name
container_name       = "tfstate"
key                  = "dev/terraform.tfstate"
encrypt              = true
```

Edit `environments/staging/backend-azure.tfvars`:
```hcl
resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate123456789"  # Same storage account
container_name       = "tfstate"
key                  = "staging/terraform.tfstate"  # Different key!
encrypt              = true
```

Edit `environments/prod/backend-azure.tfvars`:
```hcl
resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate123456789"  # Same storage account
container_name       = "tfstate"
key                  = "prod/terraform.tfstate"  # Different key!
encrypt              = true
```

### Step 3: Initialize Environments

```bash
# Initialize development environment
make dev-init-azure

# Initialize staging environment  
make staging-init-azure

# Initialize production environment
make prod-init-azure
```

### Step 4: Deploy Infrastructure

```bash
# Deploy development environment
make dev-plan
make dev-apply

# Deploy staging environment
make staging-plan
make staging-apply

# Deploy production environment
make prod-plan
make prod-apply
```

## What Happens in Azure Storage

After deployment, your Azure Storage container will contain:

```
Container: tfstate
├── dev/terraform.tfstate          # Development state
├── staging/terraform.tfstate      # Staging state
└── prod/terraform.tfstate         # Production state
```

## Verification

### Check State Files

```bash
# List files in Azure Storage container
az storage blob list \
    --container-name tfstate \
    --account-name tfstate123456789 \
    --output table
```

### Check State Content

```bash
# Check development state
cd environments/dev
tofu show

# Check staging state
cd environments/staging  
tofu show

# Check production state
cd environments/prod
tofu show
```

## Common Workflows

### 1. Development Workflow

```bash
# Make changes to dev environment
cd environments/dev
tofu plan
tofu apply

# State is automatically saved to: dev/terraform.tfstate
```

### 2. Staging Deployment

```bash
# Deploy to staging after dev testing
cd environments/staging
tofu plan
tofu apply

# State is automatically saved to: staging/terraform.tfstate
```

### 3. Production Deployment

```bash
# Deploy to production after staging approval
cd environments/prod
tofu plan
tofu apply

# State is automatically saved to: prod/terraform.tfstate
```

## Team Collaboration

### Multiple Developers

```bash
# Developer A working on dev environment
cd environments/dev
tofu plan
# State is locked in Azure Storage
tofu apply
# State is unlocked after apply

# Developer B working on staging environment (simultaneously)
cd environments/staging
tofu plan
# Different state file, no conflicts!
tofu apply
```

### State Locking

If someone is already running `tofu apply`:
```bash
Error: Error acquiring the state lock
Error message: resource already locked

# Wait for the other process to complete, or force unlock if needed
tofu force-unlock <lock-id>
```

## Migration from Local to Remote

### Step 1: Backup Current State

```bash
# If you have existing local state
cp environments/dev/terraform.tfstate environments/dev/terraform.tfstate.backup
```

### Step 2: Initialize with Migration

```bash
cd environments/dev
tofu init -backend-config=backend-azure.tfvars -migrate-state
```

### Step 3: Verify Migration

```bash
tofu show
# Should show the same resources as before
```

## Troubleshooting Examples

### 1. Authentication Error

```bash
Error: Failed to get existing workspaces: storage.NewClient() failed: 
autorest/azure: error response has status code 401

# Solution: Set Azure credentials
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

### 2. State Lock Error

```bash
Error: Error acquiring the state lock
Error message: resource already locked

# Solution: Check who has the lock
az storage blob show \
    --container-name tfstate \
    --name dev/terraform.tfstate \
    --account-name tfstate123456789

# Or force unlock (use with caution)
tofu force-unlock <lock-id>
```

### 3. Wrong Backend Configuration

```bash
Error: Backend configuration changed

# Solution: Reconfigure backend
tofu init -reconfigure -backend-config=backend-azure.tfvars
```

## Security Best Practices

### 1. Use Service Principals

```bash
# Create service principal for Terraform
az ad sp create-for-rbac --name "terraform-backend" --role contributor

# Set environment variables
export ARM_CLIENT_ID="<app-id>"
export ARM_CLIENT_SECRET="<password>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

### 2. Enable Storage Account Firewall

```bash
# Restrict access to specific IP ranges
az storage account update \
    --name tfstate123456789 \
    --resource-group terraform-state-rg \
    --default-action Deny \
    --bypass AzureServices
```

### 3. Enable Soft Delete

```bash
# Enable soft delete for state files
az storage blob service-properties update \
    --account-name tfstate123456789 \
    --delete-retention-days 7
```

## Cost Optimization

### 1. Use Standard Storage

```bash
# Standard storage is sufficient for state files
az storage account create \
    --name tfstate123456789 \
    --resource-group terraform-state-rg \
    --sku Standard_LRS
```

### 2. Enable Lifecycle Management

```bash
# Move old state versions to cool storage
az storage account management-policy create \
    --account-name tfstate123456789 \
    --resource-group terraform-state-rg \
    --policy @lifecycle-policy.json
```

## Monitoring

### 1. Enable Storage Analytics

```bash
# Enable logging for state access
az storage logging update \
    --account-name tfstate123456789 \
    --services blob \
    --log rwd \
    --retention 7
```

### 2. Set Up Alerts

```bash
# Alert on unusual access patterns
az monitor metrics alert create \
    --name "terraform-state-access" \
    --resource-group terraform-state-rg \
    --scopes /subscriptions/<sub-id>/resourceGroups/terraform-state-rg/providers/Microsoft.Storage/storageAccounts/tfstate123456789 \
    --condition "total transactions > 1000"
``` 