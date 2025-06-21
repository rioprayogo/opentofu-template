variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block for virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "instance_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}

variable "enable_monitoring" {
  description = "Enable monitoring and logging"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Disk Management Variables
variable "disk_size_gb" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 30
}

variable "additional_disks_count" {
  description = "Number of additional data disks per VM"
  type        = number
  default     = 0
}

variable "data_disk_size_gb" {
  description = "Size of each data disk in GB"
  type        = number
  default     = 100
}

variable "data_disk_storage_type" {
  description = "Storage type for data disks (Standard_LRS, Premium_LRS, StandardSSD_LRS)"
  type        = string
  default     = "Standard_LRS"
}

# Universal VM Configuration
variable "vm_config" {
  description = "Configuration for each VM. Each VM can have different config (name, type, disk, network, etc)"
  type = list(object({
    instance_name        = string
    os_disk_size_gb     = number
    instance_type       = string
    enable_public_ip    = bool
    enable_monitoring   = bool
    location            = string
    
    network = object({
      use_existing_vpc = bool
      existing_vpc = optional(object({
        vpc_name = string
        existing_nsg_name = string
        subnet_cidr = string
      }))
      new_vpc = optional(object({
        vpc_name = string
        subnet_cidr = string
      }))
    })
    
    additional_disks = list(object({
      size_gb        = number
      storage_type   = string
      caching        = string
    }))
  }))
  default = []
  
  validation {
    condition = alltrue([
      for vm in var.vm_config : 
      vm.os_disk_size_gb > 0 && vm.os_disk_size_gb <= 4095
    ])
    error_message = "OS disk size must be between 1 and 4095 GB."
  }
  
  validation {
    condition = alltrue([
      for vm in var.vm_config : 
      alltrue([
        for disk in vm.additional_disks : 
        disk.size_gb > 0 && disk.size_gb <= 32767
      ])
    ])
    error_message = "Additional disk size must be between 1 and 32767 GB."
  }
  
  validation {
    condition = alltrue([
      for vm in var.vm_config : 
      vm.network.use_existing_vpc == false || (vm.network.use_existing_vpc == true && vm.network.existing_vpc != null)
    ])
    error_message = "When use_existing_vpc is true, existing_vpc configuration must be provided."
  }
  
  validation {
    condition = alltrue([
      for vm in var.vm_config : 
      vm.network.use_existing_vpc == true || (vm.network.use_existing_vpc == false && vm.network.new_vpc != null)
    ])
    error_message = "When use_existing_vpc is false, new_vpc configuration must be provided."
  }
}

# Network Peering Variables
variable "enable_network_peering" {
  description = "Enable VNet peering"
  type        = bool
  default     = false
}

variable "peer_vnet_id" {
  description = "ID of the VNet to peer with"
  type        = string
  default     = ""
}

variable "peer_vnet_name" {
  description = "Name of the VNet to peer with"
  type        = string
  default     = ""
}

variable "peer_resource_group_name" {
  description = "Resource group name of the peer VNet"
  type        = string
  default     = ""
}

variable "peer_vnet_cidr" {
  description = "CIDR block of the peer VNet"
  type        = string
  default     = ""
}

variable "allow_gateway_transit" {
  description = "Allow gateway transit for peering"
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Use remote gateways for peering"
  type        = bool
  default     = false
} 