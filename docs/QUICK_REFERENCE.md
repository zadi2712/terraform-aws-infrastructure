# Quick Reference - New Structure

## 📁 Directory Layout

```
terraform-aws-infrastructure/
├── modules/                       # Reusable modules (no changes)
│   ├── vpc/
│   ├── ec2/
│   ├── rds/
│   └── ...
│
└── layers/                        # Infrastructure layers (NEW STRUCTURE)
    ├── networking/
    │   ├── main.tf               ⭐ All logic here
    │   ├── variables.tf          ⭐ Variable definitions
    │   ├── outputs.tf            ⭐ Outputs
    │   ├── locals.tf             ⭐ Local values
    │   ├── backend.tf            ⭐ Partial backend config
    │   └── environments/         ⭐ NEW: Environment configs
    │       ├── dev/
    │       │   ├── terraform.tfvars     # Dev values
    │       │   └── backend.conf         # Dev backend
    │       ├── qa/
    │       │   ├── terraform.tfvars     # QA values
    │       │   └── backend.conf         # QA backend
    │       ├── uat/
    │       │   ├── terraform.tfvars     # UAT values
    │       │   └── backend.conf         # UAT backend
    │       └── prod/
    │           ├── terraform.tfvars     # Prod values
    │           └── backend.conf         # Prod backend
    │
    ├── compute/                   # Same structure as networking
    ├── database/                  # Same structure
    ├── storage/                   # Same structure
    └── ...
```

## 🚀 Common Commands

### Deploy to Dev
```bash
cd layers/networking
terraform init -backend-config=environments/dev/backend.conf
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Deploy to Prod
```bash
cd layers/networking
terraform init -reconfigure -backend-config=environments/prod/backend.conf
terraform plan -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars
```

### Using Deploy Script
```bash
# From project root
./scripts/deploy.sh networking dev
./scripts/deploy.sh compute prod
./scripts/deploy.sh database qa
```

## 📝 File Purposes

| File | Location | Purpose |
|------|----------|---------|
| `main.tf` | Layer root | Resources, modules, providers |
| `variables.tf` | Layer root | Variable definitions (no values) |
| `outputs.tf` | Layer root | Output definitions |
| `locals.tf` | Layer root | Local calculations, tags |
| `backend.tf` | Layer root | Partial backend config |
| `terraform.tfvars` | environments/{env}/ | **Environment-specific VALUES** |
| `backend.conf` | environments/{env}/ | **Environment-specific backend** |

## 🎯 Key Differences

### ❌ Old Way (Duplicated Code)
```
layers/networking/dev/main.tf       # Duplicated
layers/networking/prod/main.tf      # Duplicated
```

### ✅ New Way (Single Source of Truth)
```
layers/networking/main.tf                      # Single copy
layers/networking/environments/dev/*.tfvars    # Only values
layers/networking/environments/prod/*.tfvars   # Only values
```

## 🔄 Workflow

```
1. Edit code in layer root (main.tf, variables.tf, etc.)
   ↓
2. Edit values in environments/{env}/terraform.tfvars
   ↓
3. Run: terraform init -backend-config=environments/{env}/backend.conf
   ↓
4. Run: terraform apply -var-file=environments/{env}/terraform.tfvars
```

## 📊 Example Values

### environments/dev/terraform.tfvars
```hcl
environment  = "dev"
aws_region   = "us-east-1"
project_name = "myproject"
vpc_cidr     = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
single_nat_gateway = true   # Cost optimization
```

### environments/prod/terraform.tfvars
```hcl
environment  = "prod"
aws_region   = "us-east-1"
project_name = "myproject"
vpc_cidr     = "10.10.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
single_nat_gateway = false  # High availability
```

## 🎨 Adding New Environment

```bash
# 1. Create directory
mkdir -p layers/networking/environments/staging

# 2. Create terraform.tfvars
cat > layers/networking/environments/staging/terraform.tfvars <<EOF
environment = "staging"
aws_region  = "us-east-1"
project_name = "myproject"
# ... other values
EOF

# 3. Create backend.conf
cat > layers/networking/environments/staging/backend.conf <<EOF
bucket         = "myproject-terraform-state-staging"
key            = "layers/networking/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-state-lock-staging"
EOF

# 4. Create backend resources (S3 + DynamoDB)
./scripts/setup.sh

# 5. Deploy
./scripts/deploy.sh networking staging
```

## 🔍 Finding Files

```bash
# Where is the VPC code?
layers/networking/main.tf

# Where are dev values?
layers/networking/environments/dev/terraform.tfvars

# Where is prod backend config?
layers/networking/environments/prod/backend.conf

# Where are compute resources?
layers/compute/main.tf
```

## 💡 Pro Tips

### 1. Always Specify Environment
```bash
# ✅ Good
terraform apply -var-file=environments/prod/terraform.tfvars

# ❌ Bad (might use wrong environment)
terraform apply
```

### 2. Check Current Backend
```bash
terraform state pull | head -20
```

### 3. Switch Environments Safely
```bash
# From dev to prod
terraform init -reconfigure -backend-config=environments/prod/backend.conf
```

### 4. Preview Changes
```bash
terraform plan -var-file=environments/prod/terraform.tfvars | less
```

## 📋 Deployment Order

1. **Networking** - VPC, subnets
2. **Security** - IAM, security groups
3. **Database** - RDS instances
4. **Storage** - S3 buckets
5. **Compute** - EC2, Lambda
6. **Monitoring** - CloudWatch
7. **DNS** - Route53

## 🎓 Remember

✅ **Code** goes in layer root (main.tf, variables.tf, etc.)
✅ **Values** go in environments/{env}/terraform.tfvars
✅ **Backend** config in environments/{env}/backend.conf
✅ Use deploy script: `./scripts/deploy.sh <layer> <environment>`
✅ Always review plan before applying
✅ Keep environments separate (different state files)

---

**Quick Deploy:**
```bash
./scripts/deploy.sh networking dev
```

**Full Documentation:** See `docs/NEW_STRUCTURE.md`
