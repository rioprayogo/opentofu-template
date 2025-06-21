# AWS Backend Configuration for Production Environment
# This file overrides the root backend configuration for production environment

bucket         = "terraform-state-bucket"
key            = "prod/terraform.tfstate"  # Production-specific key
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks" 