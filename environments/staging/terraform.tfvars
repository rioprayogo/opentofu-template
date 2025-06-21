# Staging Environment Configuration
cloud_provider = "azure"
project_name = "explore"
environment  = "staging"
location     = "eastus"
enable_monitoring = true

# Azure Configuration
# Uncomment and fill in your Azure credentials
# azure_subscription_id = "your-subscription-id"
# azure_tenant_id       = "your-tenant-id"
# azure_client_id       = "your-client-id"
# azure_client_secret   = "your-client-secret"
# azure_resource_group_name = "my-custom-staging-project-rg"

# AWS Configuration
# Uncomment and fill in your AWS credentials
# aws_region     = "us-east-1"
# aws_access_key = "your-access-key"
# aws_secret_key = "your-secret-key"

# GCP Configuration
# Uncomment and fill in your GCP credentials
# gcp_project_id  = "your-staging-project-id"
# gcp_region      = "us-central1"
# gcp_zone        = "us-central1-a"
# gcp_credentials = "path/to/service-account-key.json"

# Alibaba Cloud Configuration
# Uncomment and fill in your Alibaba Cloud credentials
# alicloud_region    = "cn-hangzhou"
# alicloud_access_key = "your-access-key"
# alicloud_secret_key = "your-secret-key"

# Infrastructure Configuration
vpc_cidr       = "10.0.0.0/16"

# Universal VM Configuration per VM
vm_config = [
  {
    instance_name = "${project_name}-web-1-${environment}"
    os_disk_size_gb = 80
    instance_type = "Standard_B2s"
    enable_public_ip = true
    enable_monitoring = true
    location = "eastus"
    
    network = {
      # Jika use_existing_vpc = true
      existing_vpc = {
        vpc_name = "prod-vnet"
        existing_nsg_name = "prod-nsg"
        subnet_cidr = "10.0.10.0/24"
      }
      # Jika use_existing_vpc = false  
      new_vpc = {
        vpc_name = "${project_name}-vnet-${environment}"
        subnet_cidr = "10.0.1.0/24"
      }
      use_existing_vpc = false  # Buat VPC baru
    }
    
    additional_disks = [
      {
        size_gb      = 200
        storage_type = "StandardSSD_LRS"
        caching      = "ReadWrite"
      }
    ]
  },
  {
    instance_name = "${project_name}-web-2-${environment}"
    os_disk_size_gb = 80
    instance_type = "Standard_B2s"
    enable_public_ip = false
    enable_monitoring = true
    location = "eastus"
    
    network = {
      # Jika use_existing_vpc = true
      existing_vpc = {
        vpc_name = "prod-vnet"
        existing_nsg_name = "prod-nsg"
        subnet_cidr = "10.0.10.0/24"
      }
      # Jika use_existing_vpc = false  
      new_vpc = {
        vpc_name = "${project_name}-vnet-${environment}"
        subnet_cidr = "10.0.2.0/24"
      }
      use_existing_vpc = false  # Buat VPC baru
    }
    
    additional_disks = [
      {
        size_gb      = 300
        storage_type = "Premium_LRS"
        caching      = "ReadOnly"
      }
    ]
  },
  {
    instance_name = "${project_name}-db-1-${environment}"
    os_disk_size_gb = 120
    instance_type = "Standard_D4s_v3"
    enable_public_ip = false
    enable_monitoring = true
    location = "eastus"
    
    network = {
      # Jika use_existing_vpc = true
      existing_vpc = {
        vpc_name = "prod-vnet"
        existing_nsg_name = "prod-nsg"
        subnet_cidr = "10.0.10.0/24"
      }
      # Jika use_existing_vpc = false  
      new_vpc = {
        vpc_name = "${project_name}-vnet-${environment}"
        subnet_cidr = "10.0.3.0/24"
      }
      use_existing_vpc = true  # JOIN ke VPC existing
    }
    
    additional_disks = [
      {
        size_gb      = 1000
        storage_type = "Premium_LRS"
        caching      = "ReadWrite"
      },
      {
        size_gb      = 2000
        storage_type = "Premium_LRS"
        caching      = "ReadOnly"
      }
    ]
  }
]

tags = {
  Environment = environment
  Project     = project_name
}
