# AWS Backend Configuration for Staging Environment
# This file overrides the root backend configuration for staging environment

bucket         = "terraform-state-bucket"
key            = "staging/terraform.tfstate"  # Staging-specific key
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks" 