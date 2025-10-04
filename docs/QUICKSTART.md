# Quick Start Guide

Get your Terraform AWS infrastructure up and running in 15 minutes.

## 🚀 Prerequisites (5 minutes)

### Install Required Tools

**macOS:**
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install AWS CLI
brew install awscli

# Install Terraform
brew install terraform
```

**Linux:**
```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Windows:**
```powershell
# Using Chocolatey
choco install awscli
choco install terraform
```

### Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

## 📦 Setup (5 minutes)

### 1. Clone or Download
```bash
# If using git
git clone <your-repo-url>
cd terraform-aws-infrastructure

# Or create from scratch (already done for you)
```

### 2. Initialize Backend
```bash
# Run the setup script
./scripts/setup.sh

# You'll be prompted for:
# - Project name: myapp
# - Environment: dev
# - AWS region: us-east-1
```

This creates:
- S3 bucket for state storage
- DynamoDB table for state locking
- Backend configuration file

## 🏗️ Deploy Infrastructure (5 minutes)

### Option A: Using Deploy Script (Recommended)

```bash
# Deploy networking layer
./scripts/deploy.sh networking dev

# Deploy other layers as needed
./scripts/deploy.sh security dev
./scripts/deploy.sh database dev
```

### Option B: Manual Deployment

```bash
# Navigate to the layer
cd layers/networking/dev

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edit with your values

# Deploy
terraform init
terraform plan
terraform apply
```

## 🎯 Deploy Your First VPC

### Step-by-Step Example

1. **Configure Variables**
```bash
cd layers/networking/dev
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region         = "us-east-1"
project_name       = "myapp"
vpc_cidr          = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Cost optimizations for dev
single_nat_gateway = true
enable_flow_logs   = false
```

2. **Initialize Terraform**
```bash
terraform init
```

Expected output:
```
Initializing the backend...
Successfully configured the backend "s3"!
Terraform has been successfully initialized!
```

3. **Review Plan**
```bash
terraform plan
```

This shows what will be created:
- 1 VPC
- 2 Public subnets
- 2 Private subnets
- 1 Internet Gateway
- 1 NAT Gateway (dev mode)
- Route tables

4. **Apply Changes**
```bash
terraform apply
```

Type `yes` when prompted.

Wait 2-3 minutes for resources to be created.

5. **Verify Deployment**
```bash
# Show outputs
terraform output

# Expected outputs:
# vpc_id = "vpc-xxxxx"
# public_subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]
# private_subnet_ids = ["subnet-zzzzz", "subnet-aaaaa"]
```

## 📊 What Gets Created

### Development Environment
```
VPC (10.0.0.0/16)
├── Public Subnets (2)
│   ├── 10.0.0.0/24 (us-east-1a)
│   └── 10.0.1.0/24 (us-east-1b)
├── Private Subnets (2)
│   ├── 10.0.2.0/24 (us-east-1a)
│   └── 10.0.3.0/24 (us-east-1b)
├── Internet Gateway
├── NAT Gateway (1 - cost optimized)
└── Route Tables
```

**Monthly Cost Estimate (Dev):**
- VPC: Free
- NAT Gateway: ~$32/month
- Data transfer: Variable

## ✅ Verification

### AWS Console
1. Go to AWS Console → VPC
2. You should see your new VPC: `dev-myapp-vpc`
3. Check subnets, route tables, NAT gateway

### AWS CLI
```bash
# List VPCs
aws ec2 describe-vpcs --filters "Name=tag:Environment,Values=dev"

# List subnets
aws ec2 describe-subnets --filters "Name=tag:Environment,Values=dev"
```

## 🔄 Next Steps

### Deploy Additional Layers

1. **Security Layer** (IAM roles, security groups)
```bash
./scripts/deploy.sh security dev
```

2. **Database Layer** (RDS)
```bash
./scripts/deploy.sh database dev
```

3. **Storage Layer** (S3 buckets)
```bash
./scripts/deploy.sh storage dev
```

4. **Compute Layer** (EC2, ASG)
```bash
./scripts/deploy.sh compute dev
```

## 🎨 Customize Your Infrastructure

### Example: Add an EC2 Instance

1. Create a compute layer configuration:
```bash
cd layers/compute/dev
```

2. Edit `main.tf`:
```hcl
module "web_server" {
  source = "../../../modules/ec2"
  
  environment    = "dev"
  name_prefix    = "web"
  instance_count = 1
  instance_type  = "t3.micro"
  
  vpc_id     = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
  
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "myapp-terraform-state-dev"
    key    = "layers/networking/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
```

3. Deploy:
```bash
terraform init
terraform apply
```

## 🧹 Cleanup

### Destroy Resources
```bash
# Destroy in reverse order
cd layers/compute/dev && terraform destroy
cd ../../storage/dev && terraform destroy
cd ../../database/dev && terraform destroy
cd ../../security/dev && terraform destroy
cd ../../networking/dev && terraform destroy
```

### Remove Backend Resources
```bash
# Delete S3 bucket (only when completely done)
aws s3 rb s3://myapp-terraform-state-dev --force

# Delete DynamoDB table
aws dynamodb delete-table --table-name terraform-state-lock-dev
```

## 🆘 Troubleshooting

### Issue: "Backend initialization required"
```bash
cd layers/networking/dev
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Issue: "Error locking state"
```bash
# Find the lock ID in the error message
terraform force-unlock <LOCK_ID>
```

### Issue: "Access Denied"
```bash
# Check AWS credentials
aws sts get-caller-identity

# Configure if needed
aws configure
```

### Issue: "Module not found"
```bash
# Ensure you're in the correct directory
pwd  # Should show: .../layers/networking/dev

# Reinitialize
terraform init -upgrade
```

## 📚 Learn More

- **Full Documentation**: See `docs/` directory
- **Best Practices**: `docs/BEST_PRACTICES.md`
- **Module Reference**: `docs/MODULES.md`
- **Deployment Guide**: `docs/DEPLOYMENT.md`

## 💡 Tips

1. **Start Small**: Deploy networking layer first
2. **Use Dev Environment**: Test everything in dev before prod
3. **Review Plans**: Always review `terraform plan` output
4. **Tag Everything**: Helps with cost tracking
5. **Document Changes**: Keep deployment logs
6. **Backup State**: S3 versioning is enabled

## 🎉 Success!

You now have:
- ✅ A production-ready Terraform structure
- ✅ Remote state management
- ✅ A deployed VPC infrastructure
- ✅ Reusable modules
- ✅ Multi-environment support

**Next:** Explore the modules and deploy additional infrastructure layers!

---

**Questions?** Check the documentation in the `docs/` folder or review the inline comments in the code.
