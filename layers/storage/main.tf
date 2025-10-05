/**
 * Storage Layer - Main Configuration
 * 
 * Deploys S3 buckets and other storage resources with lifecycle policies.
 */

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # Configuration loaded from environments/{env}/backend.conf
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# Application Data Bucket
module "app_data_bucket" {
  source = "../../modules/s3"
  
  environment = var.environment
  bucket_name = "${var.project_name}-${var.environment}-app-data"
  
  versioning_enabled  = var.enable_versioning
  block_public_access = true
  
  lifecycle_rules = var.app_data_lifecycle_rules
  
  tags = local.common_tags
}

# Logs Bucket
module "logs_bucket" {
  source = "../../modules/s3"
  
  environment = var.environment
  bucket_name = "${var.project_name}-${var.environment}-logs"
  
  versioning_enabled  = false
  block_public_access = true
  
  lifecycle_rules = var.logs_lifecycle_rules
  
  tags = local.common_tags
}

# Backups Bucket
module "backups_bucket" {
  count = var.create_backups_bucket ? 1 : 0
  
  source = "../../modules/s3"
  
  environment = var.environment
  bucket_name = "${var.project_name}-${var.environment}-backups"
  
  versioning_enabled  = true
  block_public_access = true
  
  lifecycle_rules = var.backups_lifecycle_rules
  
  tags = merge(
    local.common_tags,
    {
      Critical = "true"
    }
  )
}
