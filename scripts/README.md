# Helper Scripts

This directory contains helper scripts for managing the Terraform infrastructure.

## Available Scripts

### setup.sh
Initializes the backend resources (S3 bucket and DynamoDB table) for Terraform state management.

**Usage:**
```bash
./scripts/setup.sh
```

**What it does:**
1. Checks prerequisites (AWS CLI, Terraform, credentials)
2. Prompts for project name, environment, and region
3. Creates S3 bucket for state storage
4. Enables versioning and encryption on the bucket
5. Creates DynamoDB table for state locking
6. Generates backend configuration file

**Example:**
```bash
$ ./scripts/setup.sh
Enter project name: myapp
Enter environment (dev/qa/uat/prod): dev
Enter AWS region [us-east-1]: us-east-1
```

### deploy.sh
Deploys a specific infrastructure layer to an environment.

**Usage:**
```bash
./scripts/deploy.sh <layer> <environment>
```

**Parameters:**
- `layer`: networking, security, database, storage, compute, monitoring, dns
- `environment`: dev, qa, uat, prod

**What it does:**
1. Validates layer and environment
2. Initializes Terraform
3. Formats code
4. Validates configuration
5. Creates execution plan
6. Prompts for confirmation
7. Applies changes
8. Shows outputs

**Example:**
```bash
$ ./scripts/deploy.sh networking dev
```

## Additional Useful Commands

### Format All Terraform Files
```bash
find . -name "*.tf" -exec terraform fmt {} \;
```

### Validate All Layers
```bash
for layer in layers/*/dev; do
    echo "Validating $layer"
    cd $layer && terraform validate && cd -
done
```

### Check for Security Issues (requires tfsec)
```bash
tfsec .
```

### Estimate Costs (requires infracost)
```bash
infracost breakdown --path layers/networking/prod
```

### Generate Documentation (requires terraform-docs)
```bash
terraform-docs markdown table modules/vpc > modules/vpc/README.md
```

## Creating Your Own Scripts

### Template for Terraform Script
```bash
#!/bin/bash
set -e

# Your script logic here
cd layers/networking/dev
terraform init
terraform plan
```

### Make Script Executable
```bash
chmod +x scripts/your-script.sh
```

## Best Practices

1. **Always use `set -e`**: Exit on any error
2. **Add color output**: Helps identify errors quickly
3. **Validate inputs**: Check arguments and prerequisites
4. **Provide feedback**: Use echo statements liberally
5. **Clean up**: Remove temporary files
6. **Document**: Add usage instructions

## Troubleshooting

### Permission Denied
```bash
chmod +x scripts/*.sh
```

### AWS Credentials Not Found
```bash
aws configure
# or
export AWS_PROFILE=your-profile
```

### Command Not Found
Ensure all required tools are installed:
- AWS CLI: `brew install awscli` (macOS) or download from AWS
- Terraform: `brew install terraform` (macOS) or download from HashiCorp
