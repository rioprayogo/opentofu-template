# Cloud Provider Mapping Guide

This document provides detailed mappings for instance types, storage types, and configurations across all supported cloud providers.

## 📊 Instance Type Mappings

### Azure Instance Types
| Category | Instance Type | vCPU | RAM (GB) | Use Case |
|----------|---------------|------|----------|----------|
| **B-Series** | `Standard_B1s` | 1 | 1 | Development, testing |
| | `Standard_B2s` | 2 | 4 | Small workloads |
| | `Standard_B4ms` | 4 | 16 | Medium workloads |
| **D-Series** | `Standard_D2s_v3` | 2 | 8 | General purpose |
| | `Standard_D4s_v3` | 4 | 16 | Medium applications |
| | `Standard_D8s_v3` | 8 | 32 | Large applications |
| **F-Series** | `Standard_F2s_v2` | 2 | 4 | Compute optimized |
| | `Standard_F4s_v2` | 4 | 8 | High performance |

### AWS Instance Types
| Category | Instance Type | vCPU | RAM (GB) | Use Case |
|----------|---------------|------|----------|----------|
| **T-Series** | `t3.micro` | 2 | 1 | Development, testing |
| | `t3.small` | 2 | 2 | Small workloads |
| | `t3.medium` | 2 | 4 | Medium workloads |
| **M-Series** | `m5.large` | 2 | 8 | General purpose |
| | `m5.xlarge` | 4 | 16 | Medium applications |
| | `m5.2xlarge` | 8 | 32 | Large applications |
| **C-Series** | `c5.large` | 2 | 4 | Compute optimized |
| | `c5.xlarge` | 4 | 8 | High performance |

### GCP Instance Types
| Category | Instance Type | vCPU | RAM (GB) | Use Case |
|----------|---------------|------|----------|----------|
| **E2-Series** | `e2-micro` | 2 | 1 | Development, testing |
| | `e2-small` | 2 | 2 | Small workloads |
| | `e2-medium` | 2 | 4 | Medium workloads |
| **N1-Series** | `n1-standard-1` | 1 | 3.75 | General purpose |
| | `n1-standard-2` | 2 | 7.5 | Medium applications |
| | `n1-standard-4` | 4 | 15 | Large applications |
| **C2-Series** | `c2-standard-4` | 4 | 16 | Compute optimized |
| | `c2-standard-8` | 8 | 32 | High performance |

### Alibaba Cloud Instance Types
| Category | Instance Type | vCPU | RAM (GB) | Use Case |
|----------|---------------|------|----------|----------|
| **T5-Series** | `ecs.t5-lc1m1.small` | 1 | 1 | Development, testing |
| | `ecs.t5-lc1m2.small` | 1 | 2 | Small workloads |
| **G6-Series** | `ecs.g6.large` | 2 | 8 | General purpose |
| | `ecs.g6.xlarge` | 4 | 16 | Medium applications |
| | `ecs.g6.2xlarge` | 8 | 32 | Large applications |
| **C6-Series** | `ecs.c6.large` | 2 | 4 | Compute optimized |
| | `ecs.c6.xlarge` | 4 | 8 | High performance |

## 💾 Storage Type Mappings

### Azure Storage Types
| Storage Type | Description | Use Case | Performance |
|--------------|-------------|----------|-------------|
| `Standard_LRS` | Locally redundant storage | Development, testing | Standard |
| `StandardSSD_LRS` | Standard SSD storage | General purpose | Better than HDD |
| `Premium_LRS` | Premium SSD storage | Production workloads | High performance |
| `Premium_ZRS` | Premium zone-redundant | High availability | High performance + redundancy |

### AWS Storage Types
| Storage Type | Description | Use Case | Performance |
|--------------|-------------|----------|-------------|
| `gp2` | General Purpose SSD | General purpose | Up to 16,000 IOPS |
| `gp3` | General Purpose SSD v3 | General purpose | Up to 16,000 IOPS |
| `io1` | Provisioned IOPS SSD | High performance | Up to 64,000 IOPS |
| `io2` | Provisioned IOPS SSD v2 | High performance | Up to 64,000 IOPS |

### GCP Storage Types
| Storage Type | Description | Use Case | Performance |
|--------------|-------------|----------|-------------|
| `pd-standard` | Standard persistent disk | Development, testing | Standard |
| `pd-balanced` | Balanced persistent disk | General purpose | Balanced performance |
| `pd-ssd` | SSD persistent disk | Production workloads | High performance |
| `pd-extreme` | Extreme persistent disk | High performance | Maximum performance |

### Alibaba Cloud Storage Types
| Storage Type | Description | Use Case | Performance |
|--------------|-------------|----------|-------------|
| `cloud_efficiency` | Efficiency cloud disk | Development, testing | Standard |
| `cloud_ssd` | SSD cloud disk | General purpose | Better performance |
| `cloud_essd` | Enhanced SSD | Production workloads | High performance |
| `cloud_essd_pl0` | Enhanced SSD PL0 | High performance | Maximum performance |

## 🔄 Caching Options

### Azure Caching
| Option | Description | Use Case |
|--------|-------------|----------|
| `None` | No caching | Write-heavy workloads |
| `ReadOnly` | Read-only caching | Read-heavy workloads |
| `ReadWrite` | Read-write caching | General purpose |

### AWS Caching
| Option | Description | Use Case |
|--------|-------------|----------|
| `none` | No caching | Write-heavy workloads |
| `readonly` | Read-only caching | Read-heavy workloads |
| `readwrite` | Read-write caching | General purpose |

### GCP Caching
| Option | Description | Use Case |
|--------|-------------|----------|
| `NONE` | No caching | Write-heavy workloads |
| `READ_ONLY` | Read-only caching | Read-heavy workloads |
| `READ_WRITE` | Read-write caching | General purpose |

### Alibaba Cloud Caching
| Option | Description | Use Case |
|--------|-------------|----------|
| `none` | No caching | Write-heavy workloads |
| `readonly` | Read-only caching | Read-heavy workloads |
| `readwrite` | Read-write caching | General purpose |

## 🌐 Network Configuration

### Azure Network
```hcl
vm_config = [
  {
    instance_name = "web-server-1"
    os_disk_size_gb = 50
    instance_type = "Standard_B2s"        # Azure
    # instance_type = "t3.small"          # AWS
    # instance_type = "e2-small"          # GCP
    # instance_type = "ecs.t5-lc1m2.small" # Alibaba
    
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
        size_gb = 100
        storage_type = "StandardSSD_LRS"  # Azure
        # storage_type = "gp3"             # AWS
        # storage_type = "pd-balanced"     # GCP
        # storage_type = "cloud_ssd"       # Alibaba
        caching = "ReadWrite"
      }
    ]
  }
]
```

### AWS Network
```hcl
vm_config = [
  {
    instance_name = "web-server-1"
    os_disk_size_gb = 50
    instance_type = "Standard_B2s"        # Azure
    # instance_type = "t3.small"          # AWS
    # instance_type = "e2-small"          # GCP
    # instance_type = "ecs.t5-lc1m2.small" # Alibaba
    
    enable_public_ip = true
    enable_monitoring = true
    location = "eastus"
    
    network = {
      use_existing_vpc = false
      new_vpc = {
        vpc_name = "my-vpc"
        subnet_cidr = "10.0.1.0/24"
      }
    }
    
    additional_disks = [
      {
        size_gb = 100
        storage_type = "StandardSSD_LRS"  # Azure
        # storage_type = "gp3"             # AWS
        # storage_type = "pd-balanced"     # GCP
        # storage_type = "cloud_ssd"       # Alibaba
        caching = "ReadWrite"
      }
    ]
  }
]
```

### GCP Network
```hcl
vm_config = [
  {
    instance_name = "web-server-1"
    os_disk_size_gb = 50
    instance_type = "Standard_B2s"        # Azure
    # instance_type = "t3.small"          # AWS
    # instance_type = "e2-small"          # GCP
    # instance_type = "ecs.t5-lc1m2.small" # Alibaba
    
    enable_public_ip = true
    enable_monitoring = true
    location = "eastus"
    
    network = {
      use_existing_vpc = false
      new_vpc = {
        vpc_name = "my-vpc"
        subnet_cidr = "10.0.1.0/24"
      }
    }
    
    additional_disks = [
      {
        size_gb = 100
        storage_type = "StandardSSD_LRS"  # Azure
        # storage_type = "gp3"             # AWS
        # storage_type = "pd-balanced"     # GCP
        # storage_type = "cloud_ssd"       # Alibaba
        caching = "ReadWrite"
      }
    ]
  }
]
```

### Alibaba Cloud Network
```hcl
vm_config = [
  {
    instance_name = "web-server-1"
    os_disk_size_gb = 50
    instance_type = "Standard_B2s"        # Azure
    # instance_type = "t3.small"          # AWS
    # instance_type = "e2-small"          # GCP
    # instance_type = "ecs.t5-lc1m2.small" # Alibaba
    
    enable_public_ip = true
    enable_monitoring = true
    location = "eastus"
    
    network = {
      use_existing_vpc = false
      new_vpc = {
        vpc_name = "my-vpc"
        subnet_cidr = "10.0.1.0/24"
      }
    }
    
    additional_disks = [
      {
        size_gb = 100
        storage_type = "StandardSSD_LRS"  # Azure
        # storage_type = "gp3"             # AWS
        # storage_type = "pd-balanced"     # GCP
        # storage_type = "cloud_ssd"       # Alibaba
        caching = "ReadWrite"
      }
    ]
  }
]
```

### Using Existing VPC (All Clouds)
```hcl
vm_config = [
  {
    instance_name = "web-server-1"
    os_disk_size_gb = 50
    instance_type = "Standard_B2s"        # Azure
    # instance_type = "t3.small"          # AWS
    # instance_type = "e2-small"          # GCP
    # instance_type = "ecs.t5-lc1m2.small" # Alibaba
    
    enable_public_ip = true
    enable_monitoring = true
    location = "eastus"
    
    network = {
      use_existing_vpc = true
      existing_vpc = {
        vpc_name = "existing-vnet"
        existing_nsg_name = "existing-nsg"
        subnet_cidr = "10.0.10.0/24"
      }
    }
    
    additional_disks = [
      {
        size_gb = 100
        storage_type = "StandardSSD_LRS"  # Azure
        # storage_type = "gp3"             # AWS
        # storage_type = "pd-balanced"     # GCP
        # storage_type = "cloud_ssd"       # Alibaba
        caching = "ReadWrite"
      }
    ]
  }
]
```

## 📏 Size Limits

### Azure Limits
- OS Disk: 1 GB - 4,095 GB
- Data Disk: 1 GB - 32,767 GB
- Total Disks per VM: 64

### AWS Limits
- OS Disk: 1 GB - 4,095 GB
- Data Disk: 1 GB - 16,384 GB
- Total Disks per VM: 26

### GCP Limits
- OS Disk: 1 GB - 65,536 GB
- Data Disk: 1 GB - 65,536 GB
- Total Disks per VM: 128

### Alibaba Cloud Limits
- OS Disk: 1 GB - 2,048 GB
- Data Disk: 1 GB - 32,768 GB
- Total Disks per VM: 16

## 🔧 Configuration Examples

### Development Environment (All Clouds)
```hcl
vm_config = [
  {
    instance_name = "dev-web-1"
    os_disk_size_gb = 50
    instance_type = "Standard_B2s"        # Azure
    # instance_type = "t3.small"          # AWS
    # instance_type = "e2-small"          # GCP
    # instance_type = "ecs.t5-lc1m2.small" # Alibaba
    
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
        storage_type = "StandardSSD_LRS"  # Azure
        # storage_type = "gp3"             # AWS
        # storage_type = "pd-balanced"     # GCP
        # storage_type = "cloud_ssd"       # Alibaba
        caching = "ReadWrite"
      }
    ]
  }
]
```

### Production Environment (All Clouds)
```hcl
vm_config = [
  {
    instance_name = "prod-web-1"
    os_disk_size_gb = 100
    instance_type = "Standard_D2s_v3"     # Azure
    # instance_type = "m5.large"          # AWS
    # instance_type = "n1-standard-2"     # GCP
    # instance_type = "ecs.g6.large"      # Alibaba
    
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
        storage_type = "Premium_LRS"      # Azure
        # storage_type = "io1"             # AWS
        # storage_type = "pd-ssd"          # GCP
        # storage_type = "cloud_essd"      # Alibaba
        caching = "ReadWrite"
      },
      {
        size_gb = 1000
        storage_type = "Premium_LRS"      # Azure
        # storage_type = "io1"             # AWS
        # storage_type = "pd-ssd"          # GCP
        # storage_type = "cloud_essd"      # Alibaba
        caching = "ReadOnly"
      }
    ]
  }
]
```

## 🎯 Best Practices

### Instance Type Selection
1. **Development**: Use burstable instances (B-series, T-series, E2-series)
2. **Staging**: Use general purpose instances (D-series, M-series, N1-series)
3. **Production**: Use compute optimized instances (F-series, C-series, C2-series)

### Storage Selection
1. **Development**: Use standard storage (Standard_LRS, gp2, pd-standard)
2. **Staging**: Use SSD storage (StandardSSD_LRS, gp3, pd-balanced)
3. **Production**: Use premium storage (Premium_LRS, io1, pd-ssd)

### Caching Strategy
1. **Write-heavy**: Use `None` caching
2. **Read-heavy**: Use `ReadOnly` caching
3. **General purpose**: Use `ReadWrite` caching

### Network Strategy
1. **Development**: Use new VPC with simple subnets
2. **Production**: Use existing VPC with complex network architecture
3. **Security**: Use private subnets for database servers

## 🔍 Troubleshooting

### Common Issues
1. **Instance type not available**: Check region availability
2. **Storage type not supported**: Verify instance type compatibility
3. **Disk size too large**: Check cloud provider limits
4. **Network conflicts**: Ensure CIDR ranges don't overlap

### Validation Errors
- OS disk size must be within provider limits
- Additional disk size must be within provider limits
- Network configuration must be complete
- Instance types must be valid for the region 