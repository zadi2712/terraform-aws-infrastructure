#!/bin/bash
# Deployment script for Terraform layers
# Updated for new structure with environments/ subdirectory
# Usage: ./deploy.sh <layer> <environment>

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${BLUE}[====]${NC} $1"; }

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <layer> <environment>"
    echo ""
    echo "Layers: networking, security, database, storage, compute, monitoring, dns"
    echo "Environments: dev, qa, uat, prod"
    echo ""
    echo "Example: $0 networking dev"
    exit 1
fi

LAYER=$1
ENVIRONMENT=$2
LAYER_PATH="layers/${LAYER}"
ENV_PATH="${LAYER_PATH}/environments/${ENVIRONMENT}"

# Validate layer exists
if [ ! -d "$LAYER_PATH" ]; then
    print_error "Layer not found: $LAYER_PATH"
    exit 1
fi

# Validate environment config exists
if [ ! -d "$ENV_PATH" ]; then
    print_error "Environment config not found: $ENV_PATH"
    print_info "Available environments:"
    ls -1 "${LAYER_PATH}/environments/" 2>/dev/null || echo "  No environments configured"
    exit 1
fi

# Check for required files
if [ ! -f "${ENV_PATH}/terraform.tfvars" ]; then
    print_error "terraform.tfvars not found in ${ENV_PATH}"
    exit 1
fi

if [ ! -f "${ENV_PATH}/backend.conf" ]; then
    print_error "backend.conf not found in ${ENV_PATH}"
    exit 1
fi

# Function to run terraform command with error handling
run_terraform() {
    local command=$1
    print_info "Running: terraform $command"
    
    if terraform $command; then
        print_info "Command successful"
        return 0
    else
        print_error "Command failed"
        return 1
    fi
}

# Main deployment function
deploy() {
    print_header "Deploying ${LAYER} layer to ${ENVIRONMENT} environment"
    print_info "Layer path: ${LAYER_PATH}"
    print_info "Environment config: ${ENV_PATH}"
    
    cd "$LAYER_PATH"
    
    # Initialize with environment-specific backend
    print_header "Step 1: Initialize Backend"
    if ! run_terraform "init -reconfigure -backend-config=environments/${ENVIRONMENT}/backend.conf"; then
        exit 1
    fi
    
    # Format
    print_header "Step 2: Format"
    terraform fmt
    
    # Validate
    print_header "Step 3: Validate"
    if ! run_terraform "validate"; then
        exit 1
    fi
    
    # Plan with environment-specific variables
    print_header "Step 4: Plan"
    if ! run_terraform "plan -var-file=environments/${ENVIRONMENT}/terraform.tfvars -out=tfplan"; then
        exit 1
    fi
    
    # Review plan
    print_warn "Please review the plan above"
    echo ""
    echo "Environment: ${ENVIRONMENT}"
    echo "Layer: ${LAYER}"
    echo "Backend: $(grep 'bucket' environments/${ENVIRONMENT}/backend.conf | cut -d'=' -f2 | tr -d ' ')"
    echo ""
    read -p "Do you want to apply this plan? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_info "Deployment cancelled"
        rm -f tfplan
        exit 0
    fi
    
    # Apply
    print_header "Step 5: Apply"
    if ! run_terraform "apply tfplan"; then
        print_error "Apply failed"
        exit 1
    fi
    
    # Cleanup
    rm -f tfplan
    
    # Output
    print_header "Step 6: Outputs"
    terraform output
    
    echo ""
    print_info "✅ Deployment completed successfully!"
    echo ""
    print_info "State file: s3://$(grep 'bucket' environments/${ENVIRONMENT}/backend.conf | cut -d'=' -f2 | tr -d ' ')/$(grep 'key' environments/${ENVIRONMENT}/backend.conf | cut -d'=' -f2 | tr -d ' ')"
}

# Execute deployment
deploy
