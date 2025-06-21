variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  description = "GCP machine type"
  type        = string
  default     = "e2-micro"
}

variable "instance_count" {
  description = "Number of GCP instances to create"
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
      vm.os_disk_size_gb > 0 && vm.os_disk_size_gb <= 65536
    ])
    error_message = "OS disk size must be between 1 and 65536 GB."
  }
  
  validation {
    condition = alltrue([
      for vm in var.vm_config : 
      alltrue([
        for disk in vm.additional_disks : 
        disk.size_gb > 0 && disk.size_gb <= 65536
      ])
    ])
    error_message = "Additional disk size must be between 1 and 65536 GB."
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