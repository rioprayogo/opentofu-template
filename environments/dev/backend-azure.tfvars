# Azure Backend Configuration for Development Environment
# This file overrides the root backend configuration for dev environment

resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate123456789"
container_name       = "tfstate"
key                  = "dev/terraform.tfstate"  # Dev-specific key
encrypt              = true 