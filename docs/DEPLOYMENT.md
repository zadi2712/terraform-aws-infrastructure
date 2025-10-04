 Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock-${ENVIRONMENT} \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ${REGION}
```

### 3. Configure Backend

Update the backend configuration in each layer's `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "myproject-terraform-state-dev"
    key            = "layers/networking/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-dev"
  }
}
```

## Deployment Order

Deploy infrastructure in the following order:

### Layer 1: Networking (Foundation)
```bash
cd layers/networking/dev

# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply changes
terraform apply

# Save outputs for other layers
terraform output -json > outputs.json
```

### Layer 2: Security
```bash
cd ../../security/dev

# Copy variables
cp terraform.tfvars.example terraform.tfvars

# Initialize and apply
terraform init
terraform plan
terraform apply
```

### Layer 3: Database
```bash
cd ../../database/dev

# Update terraform.tfvars with VPC outputs from networking layer
terraform init
terraform plan
terraform apply
```

### Layer 4: Storage
```bash
cd ../../storage/dev
terraform init
terraform plan
terraform apply
```

### Layer 5: Compute
```bash
cd ../../compute/dev
terraform init
terraform plan
terraform apply
```

### Layer 6: Monitoring
```bash
cd ../../monitoring/dev
terraform init
terraform plan
terraform apply
```

## Environment-Specific Deployment

### Development Environment
```bash
# Optimized for cost
cd layers/networking/dev
terraform apply -var="single_nat_gateway=true" -var="enable_flow_logs=false"
```

### Production Environment
```bash
# Optimized for reliability
cd layers/networking/prod
terraform apply -var="single_nat_gateway=false" -var="enable_flow_logs=true" -var="multi_az=true"
```

## Using Remote State Data Sources

When one layer needs outputs from another:

```hcl
# In compute layer, reference networking layer outputs
data "terraform_remote_state" "networking" {
  backend = "s3"
  
  config = {
    bucket = "myproject-terraform-state-dev"
    key    = "layers/networking/dev/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use the outputs
resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.app.id]
}
```

## Validation and Testing

### Pre-deployment Checks
```bash
# Format all files
terraform fmt -recursive

# Validate configuration
terraform validate

# Check for security issues (requires tfsec)
tfsec .

# Cost estimation (requires infracost)
infracost breakdown --path .
```

### Post-deployment Validation
```bash
# Verify resources were created
terraform show

# List all resources
terraform state list

# Test connectivity
aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev"
```

## Troubleshooting

### Common Issues

#### Issue: State Lock Error
```
Error: Error acquiring the state lock
```

**Solution:**
```bash
# Check DynamoDB for stuck locks
aws dynamodb scan --table-name terraform-state-lock-dev

# Force unlock (use cautiously)
terraform force-unlock <LOCK_ID>
```

#### Issue: Backend Not Initialized
```
Error: Backend initialization required
```

**Solution:**
```bash
# Remove local state
rm -rf .terraform .terraform.lock.hcl

# Reinitialize
terraform init
```

#### Issue: Resource Already Exists
```
Error: resource already exists
```

**Solution:**
```bash
# Import existing resource
terraform import aws_vpc.main vpc-xxxxx

# Or remove from state if intentional
terraform state rm aws_vpc.main
```

## Rollback Procedures

### Rollback Single Resource
```bash
# Taint resource for recreation
terraform taint aws_instance.app

# Apply to recreate
terraform apply
```

### Rollback Entire Layer
```bash
# Restore previous state
aws s3 cp s3://myproject-terraform-state-dev/layers/networking/dev/terraform.tfstate ./backup.tfstate

# Review changes
terraform plan

# If safe, apply
terraform apply
```

### Complete Teardown
```bash
# Destroy in reverse order
cd layers/monitoring/dev && terraform destroy
cd ../../compute/dev && terraform destroy
cd ../../storage/dev && terraform destroy
cd ../../database/dev && terraform destroy
cd ../../security/dev && terraform destroy
cd ../../networking/dev && terraform destroy
```

## Best Practices for Deployment

1. **Always Review Plans**
   ```bash
   terraform plan -out=tfplan
   terraform show tfplan  # Review carefully
   terraform apply tfplan
   ```

2. **Use Workspaces for Multiple Environments** (Alternative approach)
   ```bash
   terraform workspace new dev
   terraform workspace new prod
   terraform workspace select dev
   ```

3. **Tag Everything**
   - Enables cost tracking
   - Helps with resource management
   - Required for compliance

4. **Incremental Changes**
   - Deploy one layer at a time
   - Test thoroughly before next layer
   - Keep changes small and focused

5. **Document Changes**
   ```bash
   # Create a deployment log
   echo "$(date): Deployed networking layer v1.2.0" >> deployment.log
   ```

## Automation with CI/CD

### GitHub Actions Example
```yaml
name: Terraform Deploy

on:
  push:
    branches: [main]
    paths:
      - 'layers/**'

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Terraform Init
        run: terraform init
        working-directory: layers/networking/dev
      
      - name: Terraform Plan
        run: terraform plan -no-color
        working-directory: layers/networking/dev
      
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
        working-directory: layers/networking/dev
```

## Monitoring Deployments

### CloudWatch Logs
```bash
# View Terraform execution logs
aws logs tail /aws/terraform/deployments --follow
```

### SNS Notifications
Configure SNS topics for deployment notifications:
```hcl
resource "aws_sns_topic" "deployments" {
  name = "terraform-deployments"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.deployments.arn
  protocol  = "email"
  endpoint  = "devops@example.com"
}
```

## Emergency Procedures

### Quick Rollback
```bash
#!/bin/bash
# rollback.sh
LAYER=$1
ENV=$2

cd layers/${LAYER}/${ENV}
terraform init
terraform plan -destroy
terraform destroy -auto-approve
```

### State Recovery
```bash
# Pull current state
terraform state pull > current.tfstate

# List state versions
aws s3api list-object-versions \
  --bucket myproject-terraform-state-dev \
  --prefix layers/networking/dev/terraform.tfstate

# Restore previous version
aws s3api get-object \
  --bucket myproject-terraform-state-dev \
  --key layers/networking/dev/terraform.tfstate \
  --version-id <VERSION_ID> \
  restored.tfstate
```

## Next Steps

After successful deployment:

1. **Set up monitoring**: Configure CloudWatch dashboards
2. **Enable alerting**: Create CloudWatch alarms
3. **Document infrastructure**: Update architecture diagrams
4. **Schedule backups**: Configure automated snapshots
5. **Review costs**: Analyze AWS Cost Explorer
6. **Security audit**: Run AWS Security Hub scan
7. **Performance testing**: Load test applications
8. **Disaster recovery**: Test backup restore procedures

## Support and Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Internal Wiki: [Link to your wiki]
- Support Channel: #devops-support
