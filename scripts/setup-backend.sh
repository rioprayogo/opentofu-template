#!/bin/bash

# Setup Backend Infrastructure Script
# This script helps create the necessary infrastructure for remote state storage

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to setup Azure backend
setup_azure_backend() {
    print_status "Setting up Azure backend infrastructure..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Get configuration from backend-azure.tfvars
    source <(grep -E '^[^#]' backend-azure.tfvars | sed 's/=/="/;s/$/"/')
    
    print_status "Creating resource group: $resource_group_name"
    az group create --name "$resource_group_name" --location "East US" --output none
    
    print_status "Creating storage account: $storage_account_name"
    az storage account create \
        --resource-group "$resource_group_name" \
        --name "$storage_account_name" \
        --sku Standard_LRS \
        --encryption-services blob \
        --output none
    
    print_status "Creating blob container: $container_name"
    az storage container create \
        --name "$container_name" \
        --account-name "$storage_account_name" \
        --output none
    
    print_status "Enabling versioning on container"
    az storage container set-permission \
        --name "$container_name" \
        --account-name "$storage_account_name" \
        --public-access off \
        --output none
    
    print_success "Azure backend infrastructure created successfully!"
    print_warning "Remember to update backend-azure.tfvars with your actual values"
}

# Function to setup AWS backend
setup_aws_backend() {
    print_status "Setting up AWS backend infrastructure..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Get configuration from backend-aws.tfvars
    source <(grep -E '^[^#]' backend-aws.tfvars | sed 's/=/="/;s/$/"/')
    
    print_status "Creating S3 bucket: $bucket"
    aws s3 mb "s3://$bucket" --region "$region"
    
    print_status "Enabling versioning on S3 bucket"
    aws s3api put-bucket-versioning \
        --bucket "$bucket" \
        --versioning-configuration Status=Enabled
    
    print_status "Enabling encryption on S3 bucket"
    aws s3api put-bucket-encryption \
        --bucket "$bucket" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'
    
    print_status "Creating DynamoDB table: $dynamodb_table"
    aws dynamodb create-table \
        --table-name "$dynamodb_table" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$region" \
        --output none
    
    print_success "AWS backend infrastructure created successfully!"
    print_warning "Remember to update backend-aws.tfvars with your actual values"
}

# Function to setup GCP backend
setup_gcp_backend() {
    print_status "Setting up GCP backend infrastructure..."
    
    # Check if gcloud CLI is installed
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if logged in to GCP
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "Not logged in to Google Cloud. Please run 'gcloud auth login' first."
        exit 1
    fi
    
    # Get configuration from backend-gcp.tfvars
    source <(grep -E '^[^#]' backend-gcp.tfvars | sed 's/=/="/;s/$/"/')
    
    print_status "Creating GCS bucket: $bucket"
    gsutil mb -l us-central1 "gs://$bucket"
    
    print_status "Enabling versioning on GCS bucket"
    gsutil versioning set on "gs://$bucket"
    
    print_success "GCP backend infrastructure created successfully!"
    print_warning "Remember to update backend-gcp.tfvars with your actual values"
}

# Function to setup Alibaba Cloud backend
setup_alicloud_backend() {
    print_status "Setting up Alibaba Cloud backend infrastructure..."
    
    # Check if Alibaba Cloud CLI is installed
    if ! command -v aliyun &> /dev/null; then
        print_error "Alibaba Cloud CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Get configuration from backend-alicloud.tfvars
    source <(grep -E '^[^#]' backend-alicloud.tfvars | sed 's/=/="/;s/$/"/')
    
    print_status "Creating OSS bucket: $bucket"
    aliyun oss mb "oss://$bucket" --region "$region"
    
    print_status "Enabling versioning on OSS bucket"
    aliyun oss bucket-versioning put "oss://$bucket" --status Enabled
    
    print_success "Alibaba Cloud backend infrastructure created successfully!"
    print_warning "Remember to update backend-alicloud.tfvars with your actual values"
}

# Main script
main() {
    echo "OpenTofu Backend Setup Script"
    echo "============================="
    echo ""
    echo "This script will help you create the necessary infrastructure for remote state storage."
    echo ""
    echo "Available options:"
    echo "1. Azure (Azure Storage)"
    echo "2. AWS (S3 + DynamoDB)"
    echo "3. GCP (Google Cloud Storage)"
    echo "4. Alibaba Cloud (OSS)"
    echo "5. All (Setup all backends)"
    echo ""
    
    read -p "Select your cloud provider (1-5): " choice
    
    case $choice in
        1)
            setup_azure_backend
            ;;
        2)
            setup_aws_backend
            ;;
        3)
            setup_gcp_backend
            ;;
        4)
            setup_alicloud_backend
            ;;
        5)
            setup_azure_backend
            setup_aws_backend
            setup_gcp_backend
            setup_alicloud_backend
            ;;
        *)
            print_error "Invalid choice. Please select 1-5."
            exit 1
            ;;
    esac
    
    echo ""
    print_success "Backend setup completed!"
    echo ""
    echo "Next steps:"
    echo "1. Update the backend configuration files with your actual values"
    echo "2. Run 'tofu init -backend-config=backend-[provider].tfvars' to initialize with remote backend"
    echo "3. Run 'tofu plan' and 'tofu apply' to deploy your infrastructure"
}

# Run main function
main "$@" 