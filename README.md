# OpenTofu Multi-Cloud Infrastructure Template

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A comprehensive and dynamic OpenTofu template that supports multiple cloud providers (Azure, AWS, GCP, Alibaba Cloud) with a universal VM configuration system.

## 🌟 Features

- **Multi-Cloud Support**: Deploy to Azure, AWS, GCP, or Alibaba Cloud
- **Universal VM Configuration**: Flexible per-VM configuration across all cloud providers
- **Environment Management**: Separate configurations for dev, staging, and prod
- **Modular Design**: Clean separation of concerns with reusable modules
- **Network Flexibility**: Support for new VPC creation or existing VPC usage
- **Advanced Disk Management**: Per-VM disk configurations with different storage types
- **Monitoring Integration**: Built-in monitoring and logging support

## 🏗️ Architecture

```
opentofu/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/
│   ├── azure/
│   ├── aws/
│   ├── gcp/
│   └── alicloud/
├── main.tf
├── variables.tf
├── providers.tf
└── outputs.tf
```

## 🚀 Quick Start

### 1. Choose Your Environment

```bash
cd environments/dev    # or staging, prod
```

### 2. Configure Cloud Provider

Edit `terraform.tfvars` and uncomment your cloud provider credentials:

```hcl
# For Azure
azure_subscription_id = "your-subscription-id"
azure_tenant_id       = "your-tenant-id"
azure_client_id       = "your-client-id"
azure_client_secret   = "your-client-secret"

# For AWS
aws_region     = "us-east-1"
aws_access_key = "your-access-key"
aws_secret_key = "your-secret-key"

# For GCP
gcp_project_id  = "your-project-id"
gcp_region      = "us-central1"
gcp_zone        = "us-central1-a"
gcp_credentials = "path/to/service-account-key.json"

# For Alibaba Cloud
alicloud_region    = "cn-hangzhou"
alicloud_access_key = "your-access-key"
alicloud_secret_key = "your-secret-key"
```

### 3. Configure VM Infrastructure

Use the universal `vm_config` structure:

```hcl
vm_config = [
  {
    instance_name = "web-server-1"
    os_disk_size_gb = 100
    instance_type = "Standard_B2s"        # Azure
    # instance_type = "t3.micro"          # AWS
    # instance_type = "e2-micro"          # GCP
    # instance_type = "ecs.t5-lc1m1.small" # Alibaba
    
    enable_public_ip = true
    enable_monitoring = true
    location = "eastus"
    
    network = {
      use_existing_vpc = false
      new_vpc = {
        vpc_name = "my-vnet"
        subnet_cidr = "10.0.1.0/24"
      }
    }
    
    additional_disks = [
      {
        size_gb = 500
        storage_type = "Premium_LRS"      # Azure
        # storage_type = "gp3"             # AWS
        # storage_type = "pd-ssd"          # GCP
        # storage_type = "cloud_ssd"       # Alibaba
        caching = "ReadWrite"
      }
    ]
  }
]
```

### 4. Deploy

```bash
# Initialize
tofu init

# Plan
tofu plan

# Apply
tofu apply
```

## 📋 Universal VM Configuration

The `vm_config` variable provides a consistent way to configure VMs across all cloud providers:

### Structure

```hcl
vm_config = [
  {
    instance_name        = string    # Unique name for the VM
    os_disk_size_gb     = number    # OS disk size in GB
    instance_type       = string    # Cloud-specific instance type
    enable_public_ip    = bool      # Whether to assign public IP
    enable_monitoring   = bool      # Enable monitoring/logging
    location            = string    # Cloud region/zone
    
    network = {
      use_existing_vpc = bool       # Use existing VPC or create new
      existing_vpc = {              # Required if use_existing_vpc = true
        vpc_name = string
        existing_nsg_name = string
        subnet_cidr = string
      }
      new_vpc = {                   # Required if use_existing_vpc = false
        vpc_name = string
        subnet_cidr = string
      }
    }
    
    additional_disks = [
      {
        size_gb        = number     # Disk size in GB
        storage_type   = string     # Cloud-specific storage type
        caching        = string     # Caching policy
      }
    ]
  }
]
```

### Cloud Provider Mappings

#### Instance Types
| Cloud Provider | Example Instance Types |
|----------------|----------------------|
| Azure          | `Standard_B2s`, `Standard_D2s_v3`, `Standard_F4s_v2` |
| AWS            | `t3.micro`, `t3.small`, `m5.large`, `c5.xlarge` |
| GCP            | `e2-micro`, `e2-small`, `n1-standard-1`, `n1-standard-4` |
| Alibaba Cloud  | `ecs.t5-lc1m1.small`, `ecs.g6.large`, `ecs.c6.xlarge` |

#### Storage Types
| Cloud Provider | Storage Types |
|----------------|---------------|
| Azure          | `Standard_LRS`, `Premium_LRS`, `StandardSSD_LRS` |
| AWS            | `gp2`, `gp3`, `io1`, `io2` |
| GCP            | `pd-standard`, `pd-ssd`, `pd-balanced` |
| Alibaba Cloud  | `cloud_efficiency`, `cloud_ssd`, `cloud_essd` |

#### Caching Options
| Cloud Provider | Caching Options |
|----------------|-----------------|
| Azure          | `None`, `ReadOnly`, `ReadWrite` |
| AWS            | `none`, `readonly`, `readwrite` |
| GCP            | `NONE`, `READ_ONLY`, `READ_WRITE` |
| Alibaba Cloud  | `none`, `readonly`, `readwrite` |

## 🔧 Environment Examples

### Development Environment
```hcl
vm_config = [
  {
    instance_name = "dev-web-1"
    os_disk_size_gb = 50
    instance_type = "Standard_B2s"
    enable_public_ip = true
    enable_monitoring = true
    location = "eastus"
    
    network = {
      use_existing_vpc = false
      new_vpc = {
        vpc_name = "dev-vnet"
        subnet_cidr = "10.0.1.0/24"
      }
    }
    
    additional_disks = [
      {
        size_gb = 100
        storage_type = "StandardSSD_LRS"
        caching = "ReadWrite"
      }
    ]
  }
]
```

### Production Environment
```hcl
vm_config = [
  {
    instance_name = "prod-web-1"
    os_disk_size_gb = 100
    instance_type = "Standard_D2s_v3"
    enable_public_ip = true
    enable_monitoring = true
    location = "eastus"
    
    network = {
      use_existing_vpc = false
      new_vpc = {
        vpc_name = "prod-vnet"
        subnet_cidr = "10.0.1.0/24"
      }
    }
    
    additional_disks = [
      {
        size_gb = 500
        storage_type = "Premium_LRS"
        caching = "ReadWrite"
      },
      {
        size_gb = 1000
        storage_type = "Premium_LRS"
        caching = "ReadOnly"
      }
    ]
  }
]
```

## 🌐 Network Configuration

### New VPC Creation
```hcl
network = {
  use_existing_vpc = false
  new_vpc = {
    vpc_name = "my-vnet"
    subnet_cidr = "10.0.1.0/24"
  }
}
```

### Using Existing VPC
```hcl
network = {
  use_existing_vpc = true
  existing_vpc = {
    vpc_name = "existing-vnet"
    existing_nsg_name = "existing-nsg"
    subnet_cidr = "10.0.10.0/24"
  }
}
```

## 📊 Monitoring and Logging

All cloud providers support built-in monitoring:

- **Azure**: Azure Monitor, Log Analytics
- **AWS**: CloudWatch, CloudTrail
- **GCP**: Cloud Monitoring, Cloud Logging
- **Alibaba Cloud**: Cloud Monitor, Log Service

Enable monitoring per VM:
```hcl
enable_monitoring = true
```

## 🔒 Security Features

- Network Security Groups (Azure)
- Security Groups (AWS)
- Firewall Rules (GCP)
- Security Groups (Alibaba Cloud)
- SSH key authentication
- Private subnets for database servers

## 📝 Validation Rules

The template includes comprehensive validation:

- OS disk size limits per cloud provider
- Additional disk size limits
- Network configuration validation
- Required field validation

## 🛠️ Commands

```bash
# Initialize
tofu init

# Plan deployment
tofu plan

# Apply changes
tofu apply

# Destroy infrastructure
tofu destroy

# Show outputs
tofu output

# Format code
tofu fmt

# Validate configuration
tofu validate
```

## 📁 File Structure

```
environments/
├── dev/
│   ├── main.tf              # Dev-specific configuration
│   ├── variables.tf         # Dev variables
│   └── terraform.tfvars     # Dev values
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars

modules/
├── azure/                   # Azure-specific resources
├── aws/                     # AWS-specific resources
├── gcp/                     # GCP-specific resources
└── alicloud/               # Alibaba Cloud-specific resources
```

## 📚 Documentation

- [Backend Configuration Guide](BACKEND_GUIDE.md) - Complete guide for remote state management
- [Backend Usage Examples](BACKEND_EXAMPLE.md) - Practical examples and workflows
- [Cloud Provider Mapping](CLOUD_MAPPING.md) - Detailed cloud provider configurations

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## ⚠️ Security Notice

- **Never commit sensitive data** like API keys, passwords, or private keys
- Use environment variables or secure secret management systems
- Always review your `terraform.tfvars` files before committing
- Consider using backend remote storage for state management

## 🆘 Support

If you encounter any issues or have questions:
1. Check the documentation files
2. Review the examples in each environment
3. Ensure your cloud provider credentials are properly configured

## 🔄 Version History

- **v2.0**: Universal VM configuration system
- **v1.0**: Initial multi-cloud template 