#!/bin/bash

# Test Plan Script - Test OpenTofu plan without real credentials
# Usage: ./scripts/test-plan.sh [environment] [cloud_provider]

set -e

# Default values
ENVIRONMENT=${1:-dev}
CLOUD_PROVIDER=${2:-azure}

echo "🧪 Testing OpenTofu Plan"
echo "Environment: $ENVIRONMENT"
echo "Cloud Provider: $CLOUD_PROVIDER"
echo ""

# Check if environment directory exists
if [ ! -d "environments/$ENVIRONMENT" ]; then
    echo "❌ Error: Environment '$ENVIRONMENT' not found"
    echo "Available environments:"
    ls -1 environments/
    exit 1
fi

# Navigate to environment directory
cd "environments/$ENVIRONMENT"

# Check if test configuration exists
if [ ! -f "terraform.tfvars.test" ]; then
    echo "❌ Error: terraform.tfvars.test not found"
    exit 1
fi

echo "📁 Using test configuration from terraform.tfvars.test"
echo ""

# Copy test configuration
cp terraform.tfvars.test terraform.tfvars

# Initialize OpenTofu
echo "🔧 Initializing OpenTofu..."
tofu init

# Validate configuration
echo "✅ Validating configuration..."
tofu validate

# Plan with test configuration
echo "📋 Planning infrastructure..."
tofu plan

echo ""
echo "✅ Test plan completed successfully!"
echo "📝 Note: This was a test run with mock credentials"
echo "🔒 No real resources will be created"
echo ""
echo "To use real credentials:"
echo "1. Edit terraform.tfvars with your actual credentials"
echo "2. Run: tofu plan"
echo "3. Run: tofu apply" 