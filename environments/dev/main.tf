# Development Environment Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.0"
    }
  }
}

# Provider configurations
provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

provider "alicloud" {
  region = var.alicloud_region
}

# Call the main module with development-specific configuration
module "infrastructure" {
  source = "../../"

  # Cloud provider selection
  cloud_provider = var.cloud_provider
  environment    = var.environment
  project_name   = var.project_name
  location       = var.location

  # Azure configuration
  azure_subscription_id     = var.azure_subscription_id
  azure_tenant_id          = var.azure_tenant_id
  azure_client_id          = var.azure_client_id
  azure_client_secret      = var.azure_client_secret
  azure_resource_group_name = var.azure_resource_group_name

  # AWS configuration
  aws_region     = var.aws_region
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key

  # GCP configuration
  gcp_project_id  = var.gcp_project_id
  gcp_region      = var.gcp_region
  gcp_zone        = var.gcp_zone
  gcp_credentials = var.gcp_credentials

  # Alibaba Cloud configuration
  alicloud_region    = var.alicloud_region
  alicloud_access_key = var.alicloud_access_key
  alicloud_secret_key = var.alicloud_secret_key

  # Infrastructure configuration
  vpc_cidr           = var.vpc_cidr
  enable_monitoring  = var.enable_monitoring
  
  # Universal VM Configuration
  vm_config = var.vm_config
  
  tags               = var.tags
}
