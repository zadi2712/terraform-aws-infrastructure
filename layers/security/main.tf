/**
 * Security Layer - Main Configuration
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

# KMS Key for Encryption
resource "aws_kms_key" "main" {
  description             = "${var.environment} main encryption key"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-main-kms-key"
    }
  )
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.environment}-main"
  target_key_id = aws_kms_key.main.key_id
}

# EC2 Instance Role
module "ec2_role" {
  source = "../../modules/iam"
  
  environment   = var.environment
  role_name     = "ec2-instance-role"
  role_description = "IAM role for EC2 instances"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  
  create_instance_profile = true
  
  tags = local.common_tags
}

# Lambda Execution Role
module "lambda_role" {
  source = "../../modules/iam"
  
  environment   = var.environment
  role_name     = "lambda-execution-role"
  role_description = "IAM role for Lambda functions"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]
  
  tags = local.common_tags
}

# RDS Enhanced Monitoring Role
module "rds_monitoring_role" {
  source = "../../modules/iam"
  
  environment   = var.environment
  role_name     = "rds-monitoring-role"
  role_description = "IAM role for RDS enhanced monitoring"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  ]
  
  tags = local.common_tags
}
