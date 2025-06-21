# OpenTofu Multi-Cloud Infrastructure Template Makefile

.PHONY: help init plan apply destroy dev-init dev-plan dev-apply dev-destroy staging-init staging-plan staging-apply staging-destroy prod-init prod-plan prod-apply prod-destroy clean backend-setup

# Default target
help:
	@echo "OpenTofu Multi-Cloud Infrastructure Template"
	@echo ""
	@echo "Available targets:"
	@echo "  help           - Show this help message"
	@echo "  init           - Initialize OpenTofu in root directory"
	@echo "  plan           - Plan infrastructure in root directory"
	@echo "  apply          - Apply infrastructure in root directory"
	@echo "  destroy        - Destroy infrastructure in root directory"
	@echo ""
	@echo "Backend Management:"
	@echo "  backend-setup  - Setup backend infrastructure for remote state"
	@echo ""
	@echo "Development Environment:"
	@echo "  dev-init       - Initialize OpenTofu for development"
	@echo "  dev-plan       - Plan development infrastructure"
	@echo "  dev-apply      - Apply development infrastructure"
	@echo "  dev-destroy    - Destroy development infrastructure"
	@echo ""
	@echo "Staging Environment:"
	@echo "  staging-init   - Initialize OpenTofu for staging"
	@echo "  staging-plan   - Plan staging infrastructure"
	@echo "  staging-apply  - Apply staging infrastructure"
	@echo "  staging-destroy- Destroy staging infrastructure"
	@echo ""
	@echo "Production Environment:"
	@echo "  prod-init      - Initialize OpenTofu for production"
	@echo "  prod-plan      - Plan production infrastructure"
	@echo "  prod-apply     - Apply production infrastructure"
	@echo "  prod-destroy   - Destroy production infrastructure"
	@echo ""
	@echo "Utility:"
	@echo "  clean          - Clean up temporary files"
	@echo "  validate       - Validate all OpenTofu configurations"

# Root directory targets
init:
	@echo "Initializing OpenTofu in root directory..."
	tofu init

plan:
	@echo "Planning infrastructure in root directory..."
	tofu plan

apply:
	@echo "Applying infrastructure in root directory..."
	tofu apply

destroy:
	@echo "Destroying infrastructure in root directory..."
	tofu destroy

# Backend management targets
backend-setup:
	@echo "Setting up backend infrastructure..."
	@chmod +x scripts/setup-backend.sh
	@./scripts/setup-backend.sh

# Development environment targets
dev-init:
	@echo "Initializing OpenTofu for development environment..."
	cd environments/dev && tofu init

dev-init-azure:
	@echo "Initializing development environment with Azure backend..."
	cd environments/dev && tofu init -backend-config=backend-azure.tfvars

dev-init-aws:
	@echo "Initializing development environment with AWS backend..."
	cd environments/dev && tofu init -backend-config=backend-aws.tfvars

dev-init-gcp:
	@echo "Initializing development environment with GCP backend..."
	cd environments/dev && tofu init -backend-config=backend-gcp.tfvars

dev-init-alicloud:
	@echo "Initializing development environment with Alibaba Cloud backend..."
	cd environments/dev && tofu init -backend-config=backend-alicloud.tfvars

dev-plan:
	@echo "Planning development infrastructure..."
	cd environments/dev && tofu plan

dev-apply:
	@echo "Applying development infrastructure..."
	cd environments/dev && tofu apply

dev-destroy:
	@echo "Destroying development infrastructure..."
	cd environments/dev && tofu destroy

# Staging environment targets
staging-init:
	@echo "Initializing OpenTofu for staging environment..."
	cd environments/staging && tofu init

staging-init-azure:
	@echo "Initializing staging environment with Azure backend..."
	cd environments/staging && tofu init -backend-config=backend-azure.tfvars

staging-init-aws:
	@echo "Initializing staging environment with AWS backend..."
	cd environments/staging && tofu init -backend-config=backend-aws.tfvars

staging-init-gcp:
	@echo "Initializing staging environment with GCP backend..."
	cd environments/staging && tofu init -backend-config=backend-gcp.tfvars

staging-init-alicloud:
	@echo "Initializing staging environment with Alibaba Cloud backend..."
	cd environments/staging && tofu init -backend-config=backend-alicloud.tfvars

staging-plan:
	@echo "Planning staging infrastructure..."
	cd environments/staging && tofu plan

staging-apply:
	@echo "Applying staging infrastructure..."
	cd environments/staging && tofu apply

staging-destroy:
	@echo "Destroying staging infrastructure..."
	cd environments/staging && tofu destroy

# Production environment targets
prod-init:
	@echo "Initializing OpenTofu for production environment..."
	cd environments/prod && tofu init

prod-init-azure:
	@echo "Initializing production environment with Azure backend..."
	cd environments/prod && tofu init -backend-config=backend-azure.tfvars

prod-init-aws:
	@echo "Initializing production environment with AWS backend..."
	cd environments/prod && tofu init -backend-config=backend-aws.tfvars

prod-init-gcp:
	@echo "Initializing production environment with GCP backend..."
	cd environments/prod && tofu init -backend-config=backend-gcp.tfvars

prod-init-alicloud:
	@echo "Initializing production environment with Alibaba Cloud backend..."
	cd environments/prod && tofu init -backend-config=backend-alicloud.tfvars

prod-plan:
	@echo "Planning production infrastructure..."
	cd environments/prod && tofu plan

prod-apply:
	@echo "Applying production infrastructure..."
	cd environments/prod && tofu apply

prod-destroy:
	@echo "Destroying production infrastructure..."
	cd environments/prod && tofu destroy

# Utility targets
clean:
	@echo "Cleaning up temporary files..."
	find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.tfstate" -delete 2>/dev/null || true
	find . -name "*.tfstate.*" -delete 2>/dev/null || true
	find . -name "*.tfplan" -delete 2>/dev/null || true
	find . -name "*.tfplan.json" -delete 2>/dev/null || true
	find . -name "crash.log" -delete 2>/dev/null || true
	find . -name "crash.*.log" -delete 2>/dev/null || true

validate:
	@echo "Validating OpenTofu configurations..."
	@echo "Validating root configuration..."
	tofu validate
	@echo "Validating development configuration..."
	cd environments/dev && tofu validate
	@echo "Validating staging configuration..."
	cd environments/staging && tofu validate
	@echo "Validating production configuration..."
	cd environments/prod && tofu validate
	@echo "All configurations are valid!"

# Format all OpenTofu files
fmt:
	@echo "Formatting OpenTofu files..."
	tofu fmt -recursive

# Show current status
status:
	@echo "Current OpenTofu status:"
	@echo "Root directory:"
	@tofu show 2>/dev/null || echo "  No state found"
	@echo ""
	@echo "Development environment:"
	@cd environments/dev && tofu show 2>/dev/null || echo "  No state found"
	@echo ""
	@echo "Staging environment:"
	@cd environments/staging && tofu show 2>/dev/null || echo "  No state found"
	@echo ""
	@echo "Production environment:"
	@cd environments/prod && tofu show 2>/dev/null || echo "  No state found" 