# Root Environment Configuration Example
cloud_provider = "azure"
project_name = "my-dynamic-infra"
environment  = "dev"
location     = "eastus"
enable_monitoring = true

# Universal VM Configuration per VM (contoh)
vm_config = [
  {
    instance_name = "${project_name}-web-1-${environment}"
    os_disk_size_gb = 64
    instance_type = "Standard_B1s"
    enable_public_ip = true
    enable_monitoring = true
    location = "eastus"
    
    network = {
      # Jika use_existing_vpc = true
      existing_vpc = {
        vpc_name = "shared-vnet"
        existing_nsg_name = "shared-nsg"
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
        size_gb      = 128
        storage_type = "Standard_LRS"
        caching      = "ReadWrite"
      }
    ]
  },
  {
    instance_name = "${project_name}-db-1-${environment}"
    os_disk_size_gb = 128
    instance_type = "Standard_B2s"
    enable_public_ip = false
    enable_monitoring = true
    location = "eastus"
    
    network = {
      # Jika use_existing_vpc = true
      existing_vpc = {
        vpc_name = "shared-vnet"
        existing_nsg_name = "shared-nsg"
        subnet_cidr = "10.0.10.0/24"
      }
      # Jika use_existing_vpc = false  
      new_vpc = {
        vpc_name = "${project_name}-vnet-${environment}"
        subnet_cidr = "10.0.2.0/24"
      }
      use_existing_vpc = true  # JOIN ke VPC existing
    }
    
    additional_disks = [
      {
        size_gb      = 256
        storage_type = "Premium_LRS"
        caching      = "ReadOnly"
      }
    ]
  }
]

tags = {
  Environment = environment
  Project     = project_name
  ManagedBy   = "opentofu"
  Owner       = "devops-team"
}
