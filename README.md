# AWS Terraform Infrastructure

This repository contains a well-structured, production-ready Terraform infrastructure for AWS following industry best practices.

## 📁 Folder Structure

```
terraform-aws-infrastructure/
├── modules/              # Reusable Terraform modules
│   ├── vpc/             # Virtual Private Cloud module
│   ├── ec2/             # EC2 instances module
│   ├── rds/             # RDS database module
│   ├── s3/              # S3 bucket module
│   ├── iam/             # IAM roles and policies module
│   ├── security-groups/ # Security groups module
│   ├── alb/             # Application Load Balancer module
│   ├── asg/             # Auto Scaling Group module
│   ├── eks/             # EKS cluster module
│   ├── lambda/          # Lambda function module
│   ├── cloudwatch/      # CloudWatch monitoring module
│   ├── route53/         # Route53 DNS module
│   └── acm/             # AWS Certificate Manager module
├── layers/              # Infrastructure layers (root modules)
│   ├── networking/      # Network infrastructure layer
│   ├── compute/         # Compute resources layer
│   ├── database/        # Database layer
│   ├── storage/         # Storage layer
│   ├── security/        # Security layer
│   ├── monitoring/      # Monitoring and logging layer
│   └── dns/             # DNS and certificate layer
│       └── Each layer contains:
│           ├── dev/     # Development environment
│           ├── qa/      # QA environment
│           ├── uat/     # UAT environment
│           └── prod/    # Production environment
├── docs/                # Documentation
├── scripts/             # Helper scripts
└── README.md           # This file
```

## 🎯 Design Principles

1. **Modularity**: Reusable modules in the `modules/` directory
2. **Environment Separation**: Clear separation between dev, qa, uat, and prod
3. **Layer Architecture**: Infrastructure organized by functional layers
4. **DRY Principle**: Don't Repeat Yourself - use modules extensively
5. **State Management**: Remote state with backend configuration
6. **Security**: Secrets management and least privilege access
7. **Documentation**: Comprehensive inline and external documentation

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd terraform-aws-infrastructure
   ```

2. **Configure backend** (S3 + DynamoDB for state locking)
   - Update backend configuration in each environment's `backend.tf`

3. **Initialize Terraform**
   ```bash
   cd layers/networking/dev
   terraform init
   ```

4. **Review and apply**
   ```bash
   terraform plan
   terraform apply
   ```

## 📋 Deployment Order

Infrastructure should be deployed in the following order:

1. **Networking Layer** (`layers/networking/`)
   - VPC, subnets, NAT gateways, route tables
   
2. **Security Layer** (`layers/security/`)
   - IAM roles, security groups, KMS keys
   
3. **DNS Layer** (`layers/dns/`)
   - Route53 zones, ACM certificates

4. **Database Layer** (`layers/database/`)
   - RDS instances, parameter groups
   
5. **Storage Layer** (`layers/storage/`)
   - S3 buckets, EFS file systems
   
6. **Compute Layer** (`layers/compute/`)
   - EC2 instances, ASG, EKS clusters, Lambda functions
   
7. **Monitoring Layer** (`layers/monitoring/`)
   - CloudWatch dashboards, alarms, log groups

## 🌍 Environment Management

Each environment (dev, qa, uat, prod) has its own:
- State file (stored remotely)
- Variable values (`terraform.tfvars`)
- Backend configuration (`backend.tf`)
- Environment-specific settings

### Environment Characteristics

| Environment | Purpose | Scaling | Availability |
|------------|---------|---------|--------------|
| **dev** | Development | Minimal | Single AZ |
| **qa** | Testing | Low | Single AZ |
| **uat** | User Acceptance | Medium | Multi AZ |
| **prod** | Production | High | Multi AZ + DR |

## 🔒 Security Best Practices

- Secrets stored in AWS Secrets Manager or SSM Parameter Store
- No hardcoded credentials
- Least privilege IAM policies
- Encryption at rest and in transit
- Private subnets for sensitive resources
- VPC flow logs enabled
- CloudTrail logging enabled

## 📝 Module Usage Example

```hcl
module "vpc" {
  source = "../../../modules/vpc"
  
  environment         = "prod"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  tags = local.common_tags
}
```

## 🛠️ Useful Commands

```bash
# Format all Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan with specific var file
terraform plan -var-file="terraform.tfvars"

# Apply with auto-approve (use cautiously)
terraform apply -auto-approve

# Destroy infrastructure
terraform destroy

# Show current state
terraform show

# List resources in state
terraform state list
```

## 📚 Additional Documentation

- [Module Documentation](docs/MODULES.md)
- [Best Practices](docs/BEST_PRACTICES.md)
- [State Management](docs/STATE_MANAGEMENT.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run `terraform fmt` and `terraform validate`
4. Submit a pull request

## 📄 License

MIT License

## 👥 Maintainers

- Infrastructure Team

---

**Note**: Always review the Terraform plan before applying changes to production environments.
