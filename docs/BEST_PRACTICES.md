# Terraform AWS Infrastructure Best Practices

This document outlines the best practices implemented in this infrastructure.

## 1. Code Organization

### Module Structure
```
modules/
├── vpc/              # Reusable VPC module
│   ├── main.tf      # Main resources
│   ├── variables.tf # Input variables
│   ├── outputs.tf   # Output values
│   └── README.md    # Module documentation
```

**Best Practices:**
- Keep modules focused on a single responsibility
- Document all variables and outputs
- Use semantic versioning for modules
- Include examples in README

### Layer Structure
```
layers/
├── networking/      # Network infrastructure
├── compute/         # Compute resources
├── database/        # Database layer
└── storage/         # Storage layer
    ├── dev/
    ├── qa/
    ├── uat/
    └── prod/
```

**Best Practices:**
- Separate infrastructure by functional layers
- Deploy in correct order (networking → security → compute)
- Use remote state with locking
- Keep environment configs separate

## 2. State Management

### Remote State with S3 Backend

```hcl
terraform {
  backend "s3" {
    bucket         = "myproject-terraform-state-prod"
    key            = "layers/networking/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-prod"
    kms_key_id     = "arn:aws:kms:us-east-1:ACCOUNT:key/KEY_ID"
  }
}
```

**Best Practices:**
- Always use remote state for collaboration
- Enable versioning on state bucket
- Use DynamoDB for state locking
- Encrypt state with KMS
- Use separate state files per environment
- Never commit state files to git

### State Bucket Setup
```bash
# Create bucket
aws s3 mb s3://myproject-terraform-state-prod

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket myproject-terraform-state-prod \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket myproject-terraform-state-prod \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms"
      }
    }]
  }'

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-state-lock-prod \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

## 3. Security Best Practices

### Secrets Management

**Never hardcode secrets:**
```hcl
# ❌ BAD
variable "db_password" {
  default = "MyPassword123!"
}

# ✅ GOOD - Use AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/master-password"
}

resource "aws_db_instance" "main" {
  password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}
```

### IAM Least Privilege
```hcl
# ✅ GOOD - Specific permissions
resource "aws_iam_role_policy" "specific" {
  policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = "arn:aws:s3:::my-bucket/path/*"
    }]
  })
}

# ❌ BAD - Too broad
resource "aws_iam_role_policy" "broad" {
  policy = jsonencode({
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:*"
      Resource = "*"
    }]
  })
}
```

### Encryption
- **At Rest**: Enable encryption for all data stores (RDS, S3, EBS)
- **In Transit**: Use TLS/SSL for all connections
- **KMS**: Use customer-managed keys for sensitive data

## 4. Tagging Strategy

### Standard Tags

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CostCenter  = "Engineering"
    Owner       = "DevOps Team"
    Compliance  = "SOC2"  # If applicable
  }
}

# Apply tags using default_tags
provider "aws" {
  default_tags {
    tags = local.common_tags
  }
}

# Or merge with resource-specific tags
resource "aws_instance" "example" {
  tags = merge(
    local.common_tags,
    {
      Name = "web-server-01"
      Role = "WebServer"
    }
  )
}
```

**Recommended Tags:**
- `Environment`: dev, qa, uat, prod
- `Project`: Project name
- `ManagedBy`: Terraform
- `CostCenter`: For cost allocation
- `Owner`: Team responsible
- `Name`: Resource name
- `Compliance`: Compliance requirements

## 5. Variable Validation

```hcl
variable "environment" {
  type = string
  
  validation {
    condition     = contains(["dev", "qa", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, qa, uat, or prod."
  }
}

variable "instance_type" {
  type = string
  
  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Only t3 instance types are allowed."
  }
}
```

## 6. Naming Conventions

### Resource Naming Pattern
```
{environment}-{project}-{resource-type}-{identifier}

Examples:
- prod-myapp-vpc
- dev-myapp-web-server-01
- qa-myapp-rds-primary
```

### Variable Naming
- Use lowercase with underscores: `vpc_cidr`
- Be descriptive: `enable_nat_gateway` not `nat`
- Use consistent prefixes: `enable_`, `create_`, `use_`

### File Naming
- `main.tf` - Primary resources
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `backend.tf` - Backend configuration
- `providers.tf` - Provider configuration (if complex)
- `locals.tf` - Local values (if many)
- `data.tf` - Data sources (if many)

## 7. Module Development

### Module Versioning
```hcl
module "vpc" {
  source = "git::https://github.com/org/terraform-aws-vpc.git?ref=v1.2.0"
  # Use specific version tags
}
```

### Module Outputs
```hcl
# ✅ GOOD - Output everything useful
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}
```

## 8. Environment-Specific Configurations

### Development
- Single AZ for cost savings
- Single NAT Gateway
- Smaller instance sizes
- Reduced backup retention
- Optional monitoring

### Production
- Multi-AZ for high availability
- Multiple NAT Gateways (one per AZ)
- Right-sized instances
- Extended backup retention
- Enhanced monitoring enabled
- Deletion protection

## 9. Testing and Validation

### Pre-commit Checks
```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Security scanning
tfsec .

# Cost estimation
infracost breakdown --path .
```

### Plan Review
```bash
# Always review plan before applying
terraform plan -out=tfplan

# Review the plan file
terraform show tfplan

# Apply only if plan looks good
terraform apply tfplan
```

## 10. Disaster Recovery

### State Backup
- S3 versioning enabled on state bucket
- Regular state file backups
- Cross-region replication for critical environments

### Resource Recreation
```bash
# Backup state before destructive operations
terraform state pull > backup.tfstate

# Taint resource for recreation
terraform taint aws_instance.web

# Import existing resources
terraform import aws_instance.web i-1234567890
```

## 11. Cost Optimization

### Development Environment
- Use spot instances where possible
- Schedule start/stop for non-24/7 resources
- Use single NAT Gateway
- Reduce backup retention
- Use smaller instance types

### General Tips
- Use S3 lifecycle policies
- Enable RDS storage autoscaling
- Use reserved instances for prod
- Monitor with AWS Cost Explorer
- Tag everything for cost allocation

## 12. Monitoring and Logging

### CloudWatch Integration
```hcl
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

### Logging Best Practices
- Enable VPC Flow Logs
- Enable CloudTrail
- Export RDS logs to CloudWatch
- Enable S3 access logging
- Use log retention policies

## 13. Documentation

### Module Documentation
Each module should include:
- Overview and purpose
- Usage examples
- Input variables table
- Output values table
- Requirements (Terraform version, providers)
- Architecture diagram (optional)

### Inline Comments
```hcl
# Creates the primary VPC for the production environment
# This VPC spans multiple AZs for high availability
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  
  # DNS settings required for Route53 private zones
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

## 14. CI/CD Integration

### GitHub Actions Example
```yaml
name: Terraform
on: [pull_request]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v1
      
      - name: Terraform Format
        run: terraform fmt -check -recursive
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Validate
        run: terraform validate
      
      - name: Terraform Plan
        run: terraform plan
```

## 15. Common Pitfalls to Avoid

1. **Hardcoding Values**: Use variables and data sources
2. **No State Locking**: Always use DynamoDB for locking
3. **Poor Module Organization**: Keep modules focused
4. **Missing Documentation**: Document everything
5. **No Validation**: Add variable validation rules
6. **Overly Broad IAM**: Follow least privilege
7. **No Encryption**: Encrypt everything by default
8. **Missing Tags**: Tag all resources
9. **No Backups**: Enable backups and versioning
10. **Ignoring Costs**: Use cost management tools

## Additional Resources

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
