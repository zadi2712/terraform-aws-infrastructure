/**
 * Database Layer - Main Configuration
 * 
 * Deploys RDS database instances with encryption and backups.
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

# Data source for networking layer
data "terraform_remote_state" "networking" {
  backend = "s3"
  
  config = {
    bucket = "${var.project_name}-terraform-state-${var.environment}"
    key    = "layers/networking/terraform.tfstate"
    region = var.aws_region
  }
}

# Application Database
module "app_database" {
  source = "../../modules/rds"
  
  environment = var.environment
  identifier  = var.db_identifier
  
  vpc_id     = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
  
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_encrypted     = true
  
  database_name   = var.db_name
  master_username = var.db_username
  master_password = "" # Auto-generated
  
  multi_az                 = var.db_multi_az
  backup_retention_period  = var.backup_retention_period
  deletion_protection      = var.deletion_protection
  skip_final_snapshot      = var.skip_final_snapshot
  
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  store_password_in_secrets_manager     = true
  
  tags = local.common_tags
}
