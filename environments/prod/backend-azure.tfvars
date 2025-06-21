# Azure Backend Configuration for Production Environment
# This file overrides the root backend configuration for production environment

resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate123456789"
container_name       = "tfstate"
key                  = "prod/terraform.tfstate"  # Production-specific key
encrypt              = true 