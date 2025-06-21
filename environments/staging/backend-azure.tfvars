# Azure Backend Configuration for Staging Environment
# This file overrides the root backend configuration for staging environment

resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate123456789"
container_name       = "tfstate"
key                  = "staging/terraform.tfstate"  # Staging-specific key
encrypt              = true 