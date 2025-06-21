# Cloud Provider Selection
variable "cloud_provider" {
  description = "Cloud provider to use (azure, aws, gcp, alicloud)"
  type        = string
  default     = "azure"
  validation {
    condition     = contains(["azure", "aws", "gcp", "alicloud"], var.cloud_provider)
    error_message = "Cloud provider must be one of: azure, aws, gcp, alicloud."
  }
}

# Environment Configuration
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "env" {
  description = "Short environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "explore"
}

variable "location" {
  description = "Primary location/region for resources"
  type        = string
  default     = "eastus"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = ""
}

# Azure Variables
variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = ""
}

# AWS Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  default     = ""
  sensitive   = true
}

# GCP Variables
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "gcp_credentials" {
  description = "GCP service account credentials"
  type        = string
  default     = ""
  sensitive   = true
}

# Alibaba Cloud Variables
variable "alicloud_region" {
  description = "Alibaba Cloud region"
  type        = string
  default     = "cn-hangzhou"
}

variable "alicloud_access_key" {
  description = "Alibaba Cloud access key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "alicloud_secret_key" {
  description = "Alibaba Cloud secret key"
  type        = string
  default     = ""
  sensitive   = true
}

# Infrastructure Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC/Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "Instance type for compute resources"
  type        = string
  default     = "Standard_B1s"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "enable_monitoring" {
  description = "Enable monitoring and logging"
  type        = bool
  default     = true
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "explore"
  }
} 