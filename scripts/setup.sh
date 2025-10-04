#!/bin/bash
# Setup script for Terraform AWS Infrastructure
# This script initializes the backend resources and configures the environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME=""
ENVIRONMENT=""
AWS_REGION="us-east-1"

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command_exists aws; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command_exists terraform; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &>/dev/null; then
        print_error "AWS credentials not configured. Run 'aws configure' first."
        exit 1
    fi
    
    print_info "All prerequisites met!"
}

# Get user input
get_input() {
    read -p "Enter project name: " PROJECT_NAME
    read -p "Enter environment (dev/qa/uat/prod): " ENVIRONMENT
    read -p "Enter AWS region [us-east-1]: " input_region
    AWS_REGION=${input_region:-us-east-1}
    
    print_info "Project: $PROJECT_NAME"
    print_info "Environment: $ENVIRONMENT"
    print_info "Region: $AWS_REGION"
    
    read -p "Continue? (y/n): " confirm
    if [[ $confirm != "y" ]]; then
        print_error "Setup cancelled"
        exit 0
    fi
}

# Create S3 bucket for state
create_state_bucket() {
    local bucket_name="${PROJECT_NAME}-terraform-state-${ENVIRONMENT}"
    
    print_info "Creating S3 bucket: $bucket_name"
    
    if aws s3 ls "s3://$bucket_name" 2>&1 | grep -q 'NoSuchBucket'; then
        aws s3 mb "s3://$bucket_name" --region "$AWS_REGION"
        print_info "Bucket created successfully"
    else
        print_warn "Bucket already exists"
    fi
    
    # Enable versioning
    print_info "Enabling versioning..."
    aws s3api put-bucket-versioning \
        --bucket "$bucket_name" \
        --versioning-configuration Status=Enabled
    
    # Enable encryption
    print_info "Enabling encryption..."
    aws s3api put-bucket-encryption \
        --bucket "$bucket_name" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                },
                "BucketKeyEnabled": true
            }]
        }'
    
    # Block public access
    print_info "Blocking public access..."
    aws s3api put-public-access-block \
        --bucket "$bucket_name" \
        --public-access-block-configuration \
            BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
    
    print_info "S3 bucket configured successfully"
}

# Create DynamoDB table for state locking
create_dynamodb_table() {
    local table_name="terraform-state-lock-${ENVIRONMENT}"
    
    print_info "Creating DynamoDB table: $table_name"
    
    if aws dynamodb describe-table --table-name "$table_name" --region "$AWS_REGION" &>/dev/null; then
        print_warn "Table already exists"
    else
        aws dynamodb create-table \
            --table-name "$table_name" \
            --attribute-definitions AttributeName=LockID,AttributeType=S \
            --key-schema AttributeName=LockID,KeyType=HASH \
            --billing-mode PAY_PER_REQUEST \
            --region "$AWS_REGION"
        
        print_info "Waiting for table to be active..."
        aws dynamodb wait table-exists --table-name "$table_name" --region "$AWS_REGION"
        print_info "DynamoDB table created successfully"
    fi
}

# Create backend configuration
create_backend_config() {
    local bucket_name="${PROJECT_NAME}-terraform-state-${ENVIRONMENT}"
    
    print_info "Creating backend configuration template..."
    
    cat > "backend-${ENVIRONMENT}.hcl" <<EOF
# Backend configuration for ${ENVIRONMENT} environment
# Use with: terraform init -backend-config=backend-${ENVIRONMENT}.hcl

bucket         = "${bucket_name}"
region         = "${AWS_REGION}"
encrypt        = true
dynamodb_table = "terraform-state-lock-${ENVIRONMENT}"
EOF
    
    print_info "Backend configuration saved to: backend-${ENVIRONMENT}.hcl"
}

# Main execution
main() {
    echo "========================================"
    echo "  Terraform AWS Infrastructure Setup"
    echo "========================================"
    echo ""
    
    check_prerequisites
    get_input
    
    echo ""
    print_info "Starting setup..."
    
    create_state_bucket
    create_dynamodb_table
    create_backend_config
    
    echo ""
    print_info "Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Navigate to your layer directory: cd layers/networking/${ENVIRONMENT}"
    echo "2. Update backend.tf with the bucket name: ${PROJECT_NAME}-terraform-state-${ENVIRONMENT}"
    echo "3. Copy terraform.tfvars.example to terraform.tfvars and customize"
    echo "4. Initialize Terraform: terraform init"
    echo "5. Review plan: terraform plan"
    echo "6. Apply: terraform apply"
    echo ""
}

# Run main function
main
