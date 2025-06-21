terraform {
  required_version = ">= 1.0"
  required_providers {
    # Azure Provider (Priority)
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    
    # AWS Provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    # Google Cloud Provider
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    
    # Alibaba Cloud Provider
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.0"
    }
  }
}

# Azure Provider Configuration
provider "azurerm" {
  features {}
  # Configuration will be provided via environment variables or terraform.tfvars
  # subscription_id = var.azure_subscription_id
  # tenant_id       = var.azure_tenant_id
  # client_id       = var.azure_client_id
  # client_secret   = var.azure_client_secret
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
  # Configuration will be provided via environment variables or terraform.tfvars
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}

# Google Cloud Provider Configuration
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
  # Configuration will be provided via environment variables or terraform.tfvars
  # credentials = var.gcp_credentials
}

# Alibaba Cloud Provider Configuration
provider "alicloud" {
  region = var.alicloud_region
  # Configuration will be provided via environment variables or terraform.tfvars
  # access_key = var.alicloud_access_key
  # secret_key = var.alicloud_secret_key
}
