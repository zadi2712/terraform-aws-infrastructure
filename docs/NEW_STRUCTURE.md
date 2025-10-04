ated)

layers/networking/prod/
  ├── main.tf (duplicated)
  ├── variables.tf (duplicated)
  ├── outputs.tf (duplicated)
  └── backend.tf (duplicated)
```

**Problems:**
- Code duplication
- Difficult to maintain consistency
- Changes need to be applied to all environments
- More files to manage

### After (Environment Configuration Approach)
```
layers/networking/
  ├── main.tf (single source of truth)
  ├── variables.tf (single source)
  ├── outputs.tf (single source)
  ├── locals.tf (single source)
  ├── backend.tf (partial config)
  └── environments/
      ├── dev/
      │   ├── terraform.tfvars (values only)
      │   └── backend.conf (config only)
      └── prod/
          ├── terraform.tfvars (values only)
          └── backend.conf (config only)
```

**Benefits:**
- ✅ Single source of truth for logic
- ✅ Easy to maintain
- ✅ Changes propagate to all environments
- ✅ Only configuration varies per environment
- ✅ Less code to review
- ✅ Easier to understand

## 🔄 Migration from Old Structure

If you have the old structure, migrate like this:

```bash
# 1. Move all .tf files to layer root
cd layers/networking
mv dev/*.tf .
rm -rf dev/ qa/ uat/ prod/

# 2. Create environments structure
mkdir -p environments/{dev,qa,uat,prod}

# 3. Create .tfvars for each environment
# (Extract values from old files)

# 4. Create backend.conf for each environment
# (Extract backend config from old files)

# 5. Update backend.tf to use partial config

# 6. Test with dev first
terraform init -backend-config=environments/dev/backend.conf
terraform plan -var-file=environments/dev/terraform.tfvars
```

## 🎯 Complete Example

### Layer Structure
```
layers/networking/
├── main.tf
├── variables.tf
├── outputs.tf
├── locals.tf
├── backend.tf
└── environments/
    ├── dev/
    │   ├── terraform.tfvars
    │   └── backend.conf
    ├── qa/
    │   ├── terraform.tfvars
    │   └── backend.conf
    ├── uat/
    │   ├── terraform.tfvars
    │   └── backend.conf
    └── prod/
        ├── terraform.tfvars
        └── backend.conf
```

### Deployment Commands

```bash
# Deploy networking to all environments
for env in dev qa uat prod; do
  cd layers/networking
  terraform init -reconfigure -backend-config=environments/$env/backend.conf
  terraform apply -var-file=environments/$env/terraform.tfvars -auto-approve
  cd ../..
done

# Or use the deploy script
./scripts/deploy.sh networking dev
./scripts/deploy.sh networking qa
./scripts/deploy.sh networking uat
./scripts/deploy.sh networking prod
```

## 💡 Pro Tips

### 1. Use Terraform Workspaces (Alternative)
```bash
# Instead of separate backends, you could use workspaces
terraform workspace new dev
terraform workspace new prod
terraform workspace select dev
terraform apply -var-file=environments/dev/terraform.tfvars
```

### 2. Use Terragrunt (Advanced)
Terragrunt can further simplify this structure:
```hcl
# environments/dev/terragrunt.hcl
include {
  path = find_in_parent_folders()
}

inputs = {
  environment = "dev"
  vpc_cidr = "10.0.0.0/16"
}
```

### 3. Use Remote tfvars
Store tfvars in S3 for centralized management:
```bash
terraform apply -var-file="s3://config-bucket/networking/dev.tfvars"
```

### 4. Use .auto.tfvars
Create a local override file that won't be committed:
```bash
# local.auto.tfvars (in .gitignore)
# Automatically loaded by Terraform
```

## 🎓 Understanding the Flow

```
┌─────────────────┐
│  Environment    │
│  Selection      │
│  (dev/qa/prod)  │
└────────┬────────┘
         │
         ├─────────────────────────┬────────────────────────┐
         ▼                         ▼                        ▼
┌─────────────────┐      ┌─────────────────┐    ┌─────────────────┐
│  backend.conf   │      │terraform.tfvars │    │  Common Code    │
│  (backend cfg)  │      │  (variables)    │    │  (main.tf, etc) │
└────────┬────────┘      └────────┬────────┘    └────────┬────────┘
         │                         │                      │
         └─────────────────────────┴──────────────────────┘
                                   │
                                   ▼
                        ┌─────────────────────┐
                        │  Terraform Apply    │
                        │  Creates Resources  │
                        └─────────────────────┘
```

## 🔍 Troubleshooting

### Backend Already Initialized Error
```bash
# Solution: Reinitialize
terraform init -reconfigure -backend-config=environments/prod/backend.conf
```

### Wrong Environment Applied
```bash
# Check current backend
terraform state pull | head

# Verify you're using correct var file
terraform plan -var-file=environments/prod/terraform.tfvars
```

### State Lock Issues
```bash
# Check DynamoDB for locks
aws dynamodb scan --table-name terraform-state-lock-dev

# Force unlock if needed
terraform force-unlock <LOCK_ID>
```

## 📋 Checklist for New Layer

When creating a new layer:

- [ ] Create layer directory
- [ ] Create main.tf with resources
- [ ] Create variables.tf with all variables
- [ ] Create outputs.tf with outputs
- [ ] Create locals.tf with common values
- [ ] Create backend.tf with partial config
- [ ] Create environments/ directory
- [ ] Create dev/terraform.tfvars
- [ ] Create dev/backend.conf
- [ ] Repeat for qa, uat, prod
- [ ] Test deployment to dev
- [ ] Document any special requirements
- [ ] Update deployment guide

## 🎉 Success!

You now have a **clean, maintainable structure** where:

✅ Code is in one place (layer root)
✅ Configuration is separate (environments/)
✅ Each environment has its own state
✅ Easy to add new environments
✅ Simple to maintain and update
✅ Follows infrastructure-as-code best practices

---

**Next Steps:**
1. Review the structure
2. Deploy to dev environment
3. Test thoroughly
4. Deploy to production
5. Document any customizations
