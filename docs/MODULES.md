# Module Documentation

This document provides detailed information about each reusable module.

## Available Modules

| Module | Description | Status |
|--------|-------------|--------|
| [vpc](#vpc-module) | Virtual Private Cloud with subnets, NAT, IGW | ✅ Complete |
| [ec2](#ec2-module) | EC2 instances with security groups, IAM | ✅ Complete |
| [rds](#rds-module) | RDS databases with encryption, backups | ✅ Complete |
| [s3](#s3-module) | S3 buckets with encryption, lifecycle | ✅ Complete |
| [iam](#iam-module) | IAM roles and policies | 📋 Planned |
| [security-groups](#security-groups-module) | Reusable security groups | 📋 Planned |
| [alb](#alb-module) | Application Load Balancer | 📋 Planned |
| [asg](#asg-module) | Auto Scaling Groups | 📋 Planned |
| [eks](#eks-module) | EKS Kubernetes clusters | 📋 Planned |
| [lambda](#lambda-module) | Lambda functions | 📋 Planned |
| [cloudwatch](#cloudwatch-module) | Monitoring and alarms | 📋 Planned |
| [route53](#route53-module) | DNS management | 📋 Planned |
| [acm](#acm-module) | SSL/TLS certificates | 📋 Planned |

---

## VPC Module

### Overview
Creates a production-ready VPC with public and private subnets across multiple availability zones.

### Features
- Multi-AZ deployment
- Public and private subnets
- NAT Gateways for private subnet internet access
- Internet Gateway for public access
- VPC Flow Logs
- Configurable CIDR blocks

### Usage
```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  environment        = "prod"
  vpc_cidr          = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  enable_nat_gateway = true
  single_nat_gateway = false
  enable_flow_logs   = true
  
  tags = {
    Project = "MyApp"
  }
}
```

### Inputs
| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| environment | string | - | yes | Environment name |
| vpc_cidr | string | 10.0.0.0/16 | no | VPC CIDR block |
| availability_zones | list(string) | - | yes | List of AZs |
| enable_nat_gateway | bool | true | no | Enable NAT Gateway |
| single_nat_gateway | bool | false | no | Use single NAT |

### Outputs
| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| public_subnet_ids | Public subnet IDs |
| private_subnet_ids | Private subnet IDs |
| nat_gateway_ips | NAT Gateway IPs |

---

## EC2 Module

### Overview
Creates EC2 instances with security groups, IAM roles, and monitoring.

### Features
- Custom security groups
- IAM instance profiles
- User data support
- EBS optimization
- IMDSv2 support
- Root volume encryption

### Usage
```hcl
module "web_servers" {
  source = "../../modules/ec2"
  
  environment    = "prod"
  name_prefix    = "web"
  instance_count = 3
  instance_type  = "t3.medium"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "HTTP from VPC"
    }
  ]
  
  tags = {
    Role = "WebServer"
  }
}
```

### Inputs
| Name | Type | Default | Required |
|------|------|---------|----------|
| environment | string | - | yes |
| name_prefix | string | - | yes |
| vpc_id | string | - | yes |
| subnet_ids | list(string) | - | yes |
| instance_type | string | t3.micro | no |

### Outputs
| Name | Description |
|------|-------------|
| instance_ids | EC2 instance IDs |
| instance_private_ips | Private IP addresses |
| security_group_id | Security group ID |

---

## RDS Module

### Overview
Creates RDS database instances with encryption, backups, and monitoring.

### Features
- Multi-AZ support
- Automated backups
- Encryption at rest
- Enhanced monitoring
- Performance Insights
- Secrets Manager integration

### Usage
```hcl
module "database" {
  source = "../../modules/rds"
  
  environment = "prod"
  identifier  = "myapp"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"
  
  allocated_storage = 100
  storage_encrypted = true
  multi_az          = true
  
  backup_retention_period = 30
  
  allowed_security_group_ids = [module.app_servers.security_group_id]
  
  tags = {
    Critical = "true"
  }
}
```

### Inputs
| Name | Type | Default | Required |
|------|------|---------|----------|
| environment | string | - | yes |
| identifier | string | - | yes |
| vpc_id | string | - | yes |
| subnet_ids | list(string) | - | yes |
| engine | string | postgres | no |
| instance_class | string | db.t3.micro | no |
| multi_az | bool | false | no |

### Outputs
| Name | Description |
|------|-------------|
| db_instance_endpoint | Connection endpoint |
| db_instance_address | Database hostname |
| db_security_group_id | Security group ID |
| secret_arn | Secrets Manager ARN |

---

## S3 Module

### Overview
Creates S3 buckets with security best practices.

### Features
- Server-side encryption
- Versioning
- Lifecycle policies
- Access logging
- Block public access
- CORS configuration

### Usage
```hcl
module "app_bucket" {
  source = "../../modules/s3"
  
  environment = "prod"
  bucket_name = "myapp-prod-data"
  
  versioning_enabled  = true
  block_public_access = true
  
  lifecycle_rules = [
    {
      id      = "archive-old-versions"
      enabled = true
      noncurrent_version_expiration_days = 90
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]
  
  tags = {
    DataClass = "Sensitive"
  }
}
```

### Inputs
| Name | Type | Default | Required |
|------|------|---------|----------|
| environment | string | - | yes |
| bucket_name | string | - | yes |
| versioning_enabled | bool | true | no |
| block_public_access | bool | true | no |
| lifecycle_rules | list(object) | [] | no |

### Outputs
| Name | Description |
|------|-------------|
| bucket_id | Bucket name |
| bucket_arn | Bucket ARN |
| bucket_domain_name | Bucket domain name |

---

## Module Development Guidelines

### Creating a New Module

1. **Create module directory**
   ```bash
   mkdir -p modules/new-module
   cd modules/new-module
   ```

2. **Create required files**
   ```bash
   touch main.tf variables.tf outputs.tf README.md
   ```

3. **Define resources in main.tf**
4. **Document variables in variables.tf**
5. **Export useful values in outputs.tf**
6. **Write comprehensive README.md**

### Module Testing

```bash
# Format
terraform fmt

# Validate
terraform validate

# Plan
terraform plan

# Test in dev environment first
cd layers/test-layer/dev
terraform init
terraform plan
```

### Module Versioning

Use semantic versioning:
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

Example: `v1.2.3`
