#!/bin/bash

# Test All Environments Script
# Tests tofu plan for all environments using mock credentials

set -e

echo "🧪 Testing All Environments with Mock Credentials"
echo "=================================================="
echo ""

# List of environments to test
ENVIRONMENTS=("dev" "staging" "prod")

# Create test configurations for all environments
for env in "${ENVIRONMENTS[@]}"; do
    echo "📁 Setting up test configuration for $env environment..."
    
    # Create test configuration if it doesn't exist
    if [ ! -f "environments/$env/terraform.tfvars.test" ]; then
        echo "Creating terraform.tfvars.test for $env..."
        cat > "environments/$env/terraform.tfvars.test" << EOF
# Test Configuration for $env Environment
cloud_provider = "azure"
environment    = "$env"
project_name   = "test-project"
location       = "eastus"

# Mock Azure credentials
azure_subscription_id = "00000000-0000-0000-0000-000000000000"
azure_tenant_id       = "00000000-0000-0000-0000-000000000000"
azure_client_id       = "00000000-0000-0000-0000-000000000000"
azure_client_secret   = "mock-secret-for-testing"
azure_resource_group_name = "test-project-$env-rg"

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

# Test VM Configuration
vm_config = [
  {
    instance_name = "test-web-1"
    os_disk_size_gb = 64
    instance_type = "Standard_B2s"
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
        storage_type = "StandardSSD_LRS"
        caching = "ReadWrite"
      }
    ]
  }
]

# Tags
tags = {
  Environment = "$env"
  Project     = "test-project"
  Purpose     = "testing"
  Owner       = "tester"
}
EOF
    fi
done

echo ""
echo "✅ Test configurations created for all environments"
echo ""

# Test each environment
for env in "${ENVIRONMENTS[@]}"; do
    echo "🧪 Testing $env environment..."
    echo "----------------------------------------"
    
    # Run test plan for this environment
    if ./scripts/test-plan.sh "$env"; then
        echo "✅ $env environment test PASSED"
    else
        echo "❌ $env environment test FAILED"
        exit 1
    fi
    
    echo ""
done

echo "🎉 All environment tests completed successfully!"
echo ""
echo "📝 Summary:"
echo "- All environments can be planned without real credentials"
echo "- Configuration syntax is valid"
echo "- No real resources will be created"
echo ""
echo "🔒 To use with real credentials:"
echo "1. Edit terraform.tfvars in each environment"
echo "2. Add your actual cloud provider credentials"
echo "3. Run: tofu plan && tofu apply" 