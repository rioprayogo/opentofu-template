# Test Configuration - Mock Credentials for Plan Testing
# This file is for testing tofu plan without real credentials

# Cloud provider selection
cloud_provider = "azure"
environment    = "dev"
project_name   = "test-project"
location       = "eastus"

# Mock Azure credentials (for testing only)
azure_subscription_id = "00000000-0000-0000-0000-000000000000"
azure_tenant_id       = "00000000-0000-0000-0000-000000000000"
azure_client_id       = "00000000-0000-0000-0000-000000000000"
azure_client_secret   = "mock-secret-for-testing"
azure_resource_group_name = "test-project-dev-rg"

# Mock AWS credentials (for testing only)
aws_region     = "us-east-1"
aws_access_key = "mock-access-key"
aws_secret_key = "mock-secret-key"

# Mock GCP credentials (for testing only)
gcp_project_id  = "mock-project-id"
gcp_region      = "us-central1"
gcp_zone        = "us-central1-a"
gcp_credentials = "mock-credentials-path"

# Mock Alibaba Cloud credentials (for testing only)
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
  Environment = "test"
  Project     = "test-project"
  Purpose     = "testing"
  Owner       = "tester"
} 