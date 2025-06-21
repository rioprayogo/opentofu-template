# AWS Backend Configuration for Development Environment
# This file overrides the root backend configuration for dev environment

bucket         = "terraform-state-bucket"
key            = "dev/terraform.tfstate"  # Dev-specific key
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks" 