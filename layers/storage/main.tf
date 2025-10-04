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
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = local.common_tags }
}

module "app_data_bucket" {
  source = "../../modules/s3"
  environment = var.environment
  bucket_name = "${var.project_name}-${var.environment}-app-data"
  versioning_enabled  = var.enable_versioning
  block_public_access = true
  lifecycle_rules = var.app_data_lifecycle_rules
  tags = local.common_tags
}

module "logs_bucket" {
  source = "../../modules/s3"
  environment = var.environment
  bucket_name = "${var.project_name}-${var.environment}-logs"
  versioning_enabled  = false
  block_public_access = true
  lifecycle_rules = var.logs_lifecycle_rules
  tags = local.common_tags
}

module "backups_bucket" {
  source = "../../modules/s3"
  environment = var.environment
  bucket_name = "${var.project_name}-${var.environment}-backups"
  versioning_enabled  = true
  block_public_access = true
  lifecycle_rules = var.backups_lifecycle_rules
  tags = merge(local.common_tags, { Critical = "true" })
}
