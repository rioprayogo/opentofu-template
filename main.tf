# Local values for common naming
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "opentofu"
  })
}

# Azure Infrastructure (Priority)
module "azure_infrastructure" {
  count  = var.cloud_provider == "azure" ? 1 : 0
  source = "./modules/azure"

  project_name           = var.project_name
  environment           = var.environment
  location              = var.location
  resource_group_name   = var.azure_resource_group_name != "" ? var.azure_resource_group_name : "${local.name_prefix}-rg"
  vnet_cidr             = var.vpc_cidr
  enable_monitoring     = var.enable_monitoring
  
  # Universal VM Configuration
  vm_config             = var.vm_config
  
  tags                  = local.common_tags
}

# AWS Infrastructure
module "aws_infrastructure" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "./modules/aws"

  project_name       = var.project_name
  environment       = var.environment
  region            = var.aws_region
  vpc_cidr          = var.vpc_cidr
  enable_monitoring = var.enable_monitoring
  
  # Universal VM Configuration
  vm_config         = var.vm_config
  
  tags              = local.common_tags
}

# GCP Infrastructure
module "gcp_infrastructure" {
  count  = var.cloud_provider == "gcp" ? 1 : 0
  source = "./modules/gcp"

  project_name       = var.project_name
  environment       = var.environment
  region            = var.gcp_region
  zone              = var.gcp_zone
  vpc_cidr          = var.vpc_cidr
  enable_monitoring = var.enable_monitoring
  
  # Universal VM Configuration
  vm_config         = var.vm_config
  
  tags              = local.common_tags
}

# Alibaba Cloud Infrastructure
module "alicloud_infrastructure" {
  count  = var.cloud_provider == "alicloud" ? 1 : 0
  source = "./modules/alicloud"

  project_name       = var.project_name
  environment       = var.environment
  region            = var.alicloud_region
  vpc_cidr          = var.vpc_cidr
  enable_monitoring = var.enable_monitoring
  
  # Universal VM Configuration
  vm_config         = var.vm_config
  
  tags              = local.common_tags
}
