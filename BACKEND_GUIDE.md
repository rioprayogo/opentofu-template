# OpenTofu Backend Remote Configuration Guide

## Overview

This guide explains how to configure and use remote backends for state management in the OpenTofu multi-cloud infrastructure template. Remote backends provide several benefits:

- **Team Collaboration**: Multiple team members can work on the same infrastructure
- **State Security**: State files are stored securely in cloud storage
- **State Locking**: Prevents concurrent modifications that could corrupt state
- **Versioning**: Track changes to infrastructure state over time
- **Backup & Recovery**: Automatic backup and recovery capabilities

## Supported Backend Types

### 1. Azure Storage Backend
- **Storage**: Azure Blob Storage
- **Locking**: Azure Storage Account
- **Encryption**: Built-in encryption support
- **Authentication**: Azure AD, Service Principal, or Access Keys

### 2. AWS S3 Backend
- **Storage**: Amazon S3
- **Locking**: DynamoDB table
- **Encryption**: Server-side encryption (SSE)
- **Authentication**: IAM roles, access keys

### 3. Google Cloud Storage Backend
- **Storage**: Google Cloud Storage
- **Locking**: GCS built-in locking
- **Encryption**: Customer-managed keys
- **Authentication**: Service accounts, application default credentials

### 4. Alibaba Cloud OSS Backend
- **Storage**: Alibaba Cloud Object Storage Service (OSS)
- **Locking**: OSS built-in locking
- **Encryption**: Server-side encryption
- **Authentication**: RAM roles, access keys

## State File Organization

### Important: Environment-Specific Keys

Each environment uses a **different key/prefix** to prevent state conflicts:

```
Container/Bucket: terraform-state-bucket
├── dev/terraform.tfstate          # Development environment
├── staging/terraform.tfstate      # Staging environment  
└── prod/terraform.tfstate         # Production environment
```

**Why this matters:**
- ✅ **Safe**: Each environment has its own state file
- ✅ **Isolated**: Changes in one environment don't affect others
- ✅ **Parallel**: Multiple environments can be deployed simultaneously
- ❌ **Dangerous**: Using same key would cause state overwrites and data loss

## Quick Start

### Step 1: Setup Backend Infrastructure (Optional)

If you don't have existing storage infrastructure, run the automated setup script:

```bash
make backend-setup
```

This script will:
- Check for required CLI tools (az, aws, gcloud, aliyun)
- Create storage accounts/buckets
- Configure encryption and versioning
- Set up state locking (where applicable)

### Step 2: Configure Backend Settings

Update the environment-specific backend configuration files with your actual values:

**Environment-specific configurations:**
- `environments/dev/backend-*.tfvars` - Development environment
- `environments/staging/backend-*.tfvars` - Staging environment
- `environments/prod/backend-*.tfvars` - Production environment

### Step 3: Initialize with Remote Backend

Choose your cloud provider and environment:

```bash
# Development environment with Azure backend
make dev-init-azure

# Staging environment with AWS backend
make staging-init-aws

# Production environment with GCP backend
make prod-init-gcp
```

### Step 4: Deploy Infrastructure

```bash
# For development
make dev-plan
make dev-apply

# For staging
make staging-plan
make staging-apply

# For production
make prod-plan
make prod-apply
```

## Environment-Specific Backend Configuration

### Development Environment

```bash
# Initialize dev environment with different backends
make dev-init-azure      # Uses: dev/terraform.tfstate
make dev-init-aws        # Uses: dev/terraform.tfstate
make dev-init-gcp        # Uses: terraform/state/dev/
make dev-init-alicloud   # Uses: dev/terraform.tfstate
```

### Staging Environment

```bash
# Initialize staging environment with different backends
make staging-init-azure      # Uses: staging/terraform.tfstate
make staging-init-aws        # Uses: staging/terraform.tfstate
make staging-init-gcp        # Uses: terraform/state/staging/
make staging-init-alicloud   # Uses: staging/terraform.tfstate
```

### Production Environment

```bash
# Initialize production environment with different backends
make prod-init-azure         # Uses: prod/terraform.tfstate
make prod-init-aws           # Uses: prod/terraform.tfstate
make prod-init-gcp           # Uses: terraform/state/prod/
make prod-init-alicloud      # Uses: prod/terraform.tfstate
```

## Manual Backend Configuration

### Azure Storage Backend

1. **Create Storage Account** (if not exists):
```bash
az group create --name terraform-state-rg --location "East US"
az storage account create \
    --resource-group terraform-state-rg \
    --name tfstate123456789 \
    --sku Standard_LRS \
    --encryption-services blob
```

2. **Create Container** (if not exists):
```bash
az storage container create \
    --name tfstate \
    --account-name tfstate123456789
```

3. **Configure Backend** (environment-specific):
```hcl
# For dev environment
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate123456789"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}

# For staging environment
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate123456789"
    container_name       = "tfstate"
    key                  = "staging/terraform.tfstate"
  }
}

# For production environment
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate123456789"
    container_name       = "tfstate"
    key                  = "prod/terraform.tfstate"
  }
}
```

### AWS S3 Backend

1. **Create S3 Bucket** (if not exists):
```bash
aws s3 mb s3://terraform-state-bucket --region us-east-1
aws s3api put-bucket-versioning \
    --bucket terraform-state-bucket \
    --versioning-configuration Status=Enabled
```

2. **Create DynamoDB Table** (if not exists):
```bash
aws dynamodb create-table \
    --table-name terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-east-1
```

3. **Configure Backend** (environment-specific):
```hcl
# For dev environment
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# For staging environment
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# For production environment
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Google Cloud Storage Backend

1. **Create GCS Bucket** (if not exists):
```bash
gsutil mb -l us-central1 gs://terraform-state-bucket
gsutil versioning set on gs://terraform-state-bucket
```

2. **Configure Backend** (environment-specific):
```hcl
# For dev environment
terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket"
    prefix = "terraform/state/dev"
  }
}

# For staging environment
terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket"
    prefix = "terraform/state/staging"
  }
}

# For production environment
terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket"
    prefix = "terraform/state/prod"
  }
}
```

### Alibaba Cloud OSS Backend

1. **Create OSS Bucket** (if not exists):
```bash
aliyun oss mb oss://terraform-state-bucket --region cn-hangzhou
aliyun oss bucket-versioning put oss://terraform-state-bucket --status Enabled
```

2. **Configure Backend** (environment-specific):
```hcl
# For dev environment
terraform {
  backend "oss" {
    bucket = "terraform-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "cn-hangzhou"
  }
}

# For staging environment
terraform {
  backend "oss" {
    bucket = "terraform-state-bucket"
    key    = "staging/terraform.tfstate"
    region = "cn-hangzhou"
  }
}

# For production environment
terraform {
  backend "oss" {
    bucket = "terraform-state-bucket"
    key    = "prod/terraform.tfstate"
    region = "cn-hangzhou"
  }
}
```

## Security Best Practices

### 1. Access Control
- Use IAM roles and service principals instead of access keys
- Implement least privilege access
- Regularly rotate credentials

### 2. Encryption
- Enable server-side encryption for all backends
- Use customer-managed keys when possible
- Encrypt data in transit (HTTPS/TLS)

### 3. Network Security
- Configure VPC endpoints for cloud storage
- Use private subnets for backend access
- Implement network security groups/firewalls

### 4. Monitoring & Logging
- Enable access logging on storage buckets
- Monitor for unusual access patterns
- Set up alerts for failed authentication attempts

## Troubleshooting

### Common Issues

1. **Authentication Errors**:
   - Verify credentials are properly configured
   - Check if credentials have expired
   - Ensure proper permissions are assigned

2. **State Locking Issues**:
   - Check if another process is holding the lock
   - Verify DynamoDB table exists (AWS)
   - Check network connectivity to backend

3. **State Conflicts**:
   - Ensure each environment uses different keys
   - Check for concurrent deployments
   - Verify backend configuration is correct

### Debug Commands

```bash
# Check backend configuration
terraform show

# Force unlock state (use with caution)
terraform force-unlock <lock-id>

# Migrate state
terraform init -migrate-state

# Reconfigure backend
terraform init -reconfigure
```

## Migration from Local to Remote Backend

### Step 1: Backup Local State
```bash
cp terraform.tfstate terraform.tfstate.backup
```

### Step 2: Configure Remote Backend
Update the backend configuration in your Terraform files.

### Step 3: Initialize with Migration
```bash
terraform init -migrate-state
```

### Step 4: Verify Migration
```bash
terraform show
```

## Environment Variables

### Azure
```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

### AWS
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Google Cloud
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
export GOOGLE_PROJECT="your-project-id"
```

### Alibaba Cloud
```bash
export ALICLOUD_ACCESS_KEY="your-access-key"
export ALICLOUD_SECRET_KEY="your-secret-key"
export ALICLOUD_REGION="cn-hangzhou"
```

## Conclusion

Remote backends provide essential features for production infrastructure management. The key is to use **environment-specific keys** to prevent state conflicts. Choose the backend that best fits your cloud strategy and security requirements. Always test backend configurations in a development environment before deploying to production. 