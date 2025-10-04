/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  enable_nat_gateway   = true
  single_nat_gateway   = false  # Use one NAT per AZ for HA
  enable_flow_logs     = true
  flow_logs_retention_days = 30
  
  tags = {
    Project     = "MyProject"
    ManagedBy   = "Terraform"
    CostCenter  = "Engineering"
  }
}
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                            VPC (10.0.0.0/16)                    │
│                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │   AZ-1 (us-e-1a) │  │   AZ-2 (us-e-1b) │  │  AZ-3 (...) │ │
│  │                  │  │                  │  │              │ │
│  │ ┌──────────────┐ │  │ ┌──────────────┐ │  │ ┌──────────┐ │ │
│  │ │ Public       │ │  │ │ Public       │ │  │ │ Public   │ │ │
│  │ │ 10.0.0.0/24  │ │  │ │ 10.0.1.0/24  │ │  │ │ 10.0.2...│ │ │
│  │ └──────┬───────┘ │  │ └──────┬───────┘ │  │ └────┬─────┘ │ │
│  │        │         │  │        │         │  │      │       │ │
│  │   ┌────▼────┐    │  │   ┌────▼────┐    │  │  ┌───▼───┐  │ │
│  │   │  NAT GW │    │  │   │  NAT GW │    │  │  │ NAT GW│  │ │
│  │   └────┬────┘    │  │   └────┬────┘    │  │  └───┬───┘  │ │
│  │        │         │  │        │         │  │      │       │ │
│  │ ┌──────▼───────┐ │  │ ┌──────▼───────┐ │  │ ┌────▼─────┐ │ │
│  │ │ Private      │ │  │ │ Private      │ │  │ │ Private  │ │ │
│  │ │ 10.0.3.0/24  │ │  │ │ 10.0.4.0/24  │ │  │ │ 10.0.5...│ │ │
│  │ └──────────────┘ │  │ └──────────────┘ │  │ └──────────┘ │ │
│  └──────────────────┘  └──────────────────┘  └──────────────┘ │
│                                                                 │
│                     Internet Gateway                            │
└─────────────────────────────────────────────────────────────────┘
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | n/a | yes |
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| availability_zones | List of AZs | `list(string)` | n/a | yes |
| enable_dns_hostnames | Enable DNS hostnames | `bool` | `true` | no |
| enable_dns_support | Enable DNS support | `bool` | `true` | no |
| enable_nat_gateway | Enable NAT Gateway | `bool` | `true` | no |
| single_nat_gateway | Use single NAT Gateway | `bool` | `false` | no |
| enable_flow_logs | Enable VPC Flow Logs | `bool` | `true` | no |
| flow_logs_retention_days | Flow logs retention | `number` | `30` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr | The CIDR block of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| nat_gateway_ids | List of NAT Gateway IDs |
| internet_gateway_id | ID of the Internet Gateway |

## Cost Optimization

### Single NAT Gateway
For non-production environments, consider using a single NAT Gateway:

```hcl
single_nat_gateway = true  # Reduces NAT Gateway costs by 66% for 3 AZs
```

**Trade-off**: Loss of high availability for NAT Gateway.

## Best Practices

1. **Production**: Use multiple NAT Gateways (one per AZ) for high availability
2. **Development**: Use single NAT Gateway to reduce costs
3. **CIDR Planning**: Plan your CIDR blocks to avoid overlaps
4. **Flow Logs**: Enable for security and troubleshooting
5. **Tagging**: Use consistent tagging strategy

## Examples

### Minimal Configuration (Dev)
```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  environment         = "dev"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  single_nat_gateway = true  # Cost optimization
  enable_flow_logs   = false # Cost optimization
}
```

### Full Configuration (Prod)
```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  environment         = "prod"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  enable_nat_gateway       = true
  single_nat_gateway       = false
  enable_flow_logs         = true
  flow_logs_retention_days = 90
  
  tags = {
    Project    = "Production"
    ManagedBy  = "Terraform"
    Compliance = "SOC2"
  }
}
```

## Requirements

- Terraform >= 1.5.0
- AWS Provider >= 5.0
