#!/bin/bash

# Test All Cloud Providers Script
# Tests tofu plan for all cloud providers using mock credentials

set -e

echo "🧪 Testing All Cloud Providers with Mock Credentials"
echo "===================================================="
echo ""

# List of cloud providers to test
PROVIDERS=("azure" "aws" "gcp" "alicloud")
ENVIRONMENT="dev"

# Test each cloud provider
for provider in "${PROVIDERS[@]}"; do
    echo "☁️  Testing $provider provider..."
    echo "----------------------------------------"
    
    # Create provider-specific test configuration
    cat > "environments/$ENVIRONMENT/terraform.tfvars.test" << EOF
# Test Configuration for $provider Provider
cloud_provider = "$provider"
environment    = "$ENVIRONMENT"
project_name   = "test-project"
location       = "eastus"

# Mock Azure credentials
azure_subscription_id = "00000000-0000-0000-0000-000000000000"
azure_tenant_id       = "00000000-0000-0000-0000-000000000000"
azure_client_id       = "00000000-0000-0000-0000-000000000000"
azure_client_secret   = "mock-secret-for-testing"
azure_resource_group_name = "test-project-$ENVIRONMENT-rg"

# Mock AWS credentials
aws_region     = "us-east-1"
aws_access_key = "mock-access-key"
aws_secret_key = "mock-secret-key"

# Mock GCP credentials
gcp_project_id  = "mock-project-id"
gcp_region      = "us-central1"
gcp_zone        = "us-central1-a"
gcp_credentials = "mock-credentials-path"

# Mock Alibaba Cloud credentials
alicloud_region    = "cn-hangzhou"
alicloud_access_key = "mock-access-key"
alicloud_secret_key = "mock-secret-key"

# Infrastructure configuration
vpc_cidr          = "10.0.0.0/16"
enable_monitoring = true

# Test VM Configuration for $provider
vm_config = [
  {
    instance_name = "test-web-1"
    os_disk_size_gb = 64
    instance_type = "$(case $provider in
      "azure") echo "Standard_B2s" ;;
      "aws") echo "t3.micro" ;;
      "gcp") echo "e2-micro" ;;
      "alicloud") echo "ecs.t5-lc1m1.small" ;;
    esac)"
    enable_public_ip = true
    enable_monitoring = true
    location = "eastus"
    
    network = {
      use_existing_vpc = false
      new_vpc = {
        vpc_name = "test-vnet"
        subnet_cidr = "10.0.1.0/24"
      }
    }
    
    additional_disks = [
      {
        size_gb = 128
        storage_type = "$(case $provider in
          "azure") echo "StandardSSD_LRS" ;;
          "aws") echo "gp3" ;;
          "gcp") echo "pd-ssd" ;;
          "alicloud") echo "cloud_ssd" ;;
        esac)"
        caching = "$(case $provider in
          "azure") echo "ReadWrite" ;;
          "aws") echo "readwrite" ;;
          "gcp") echo "READ_WRITE" ;;
          "alicloud") echo "readwrite" ;;
        esac)"
      }
    ]
  }
]

# Tags
tags = {
  Environment = "$ENVIRONMENT"
  Project     = "test-project"
  Purpose     = "testing"
  Owner       = "tester"
  Provider    = "$provider"
}
EOF

    # Run test plan for this provider
    if ./scripts/test-plan.sh "$ENVIRONMENT" "$provider"; then
        echo "✅ $provider provider test PASSED"
    else
        echo "❌ $provider provider test FAILED"
        exit 1
    fi
    
    echo ""
done

echo "🎉 All cloud provider tests completed successfully!"
echo ""
echo "📝 Summary:"
echo "- All cloud providers can be planned without real credentials"
echo "- Configuration syntax is valid for all providers"
echo "- No real resources will be created"
echo ""
echo "🔒 To use with real credentials:"
echo "1. Edit terraform.tfvars in environments/$ENVIRONMENT"
echo "2. Add your actual cloud provider credentials"
echo "3. Set cloud_provider to your preferred provider"
echo "4. Run: tofu plan && tofu apply" 