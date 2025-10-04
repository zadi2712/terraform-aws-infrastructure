/**
 * Storage Layer - Main Configuration
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
  
  versioning_enabled  = var.app_bucket_versioning
  block_public_access = true
  
  lifecycle_rules = var.app_bucket_lifecycle_rules
  
  tags = local.common_tags
}

# Logs Bucket
module "logs_bucket" {
  source = "../../modules/s3"
  
  environment = var.environment
  bucket_name = "${var.project_name}-${var.environment}-logs"
  
  versioning_enabled  = false
  block_public_access = true
  
  lifecycle_rules = var.logs_bucket_lifecycle_rules
  
  tags = local.common_tags
}

# Backups Bucket
module "backups_bucket" {
  source = "../../modules/s3"
  
  environment = var.environment
  bucket_name = "${var.project_name}-${var.environment}-backups"
  
  versioning_enabled  = true
  block_public_access = true
  
  lifecycle_rules = var.backups_bucket_lifecycle_rules
  
  tags = merge(
    local.common_tags,
    {
      Critical = "true"
    }
  )
}
