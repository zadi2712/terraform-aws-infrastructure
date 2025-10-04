/**
 * Security Layer - Main Configuration
 */
terraform {
  required_version = ">= 1.5.0"
  required_providers { aws = { source = "hashicorp/aws"; version = "~> 5.0" } }
  backend "s3" {}
}
provider "aws" { region = var.aws_region; default_tags { tags = local.common_tags } }

# IAM Role for EC2 Instances
module "ec2_role" {
  source = "../../modules/iam"
  environment = var.environment
  role_name = "ec2-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole"; Effect = "Allow"; Principal = { Service = "ec2.amazonaws.com" } }]
  })
  managed_policy_arns = var.ec2_managed_policies
  create_instance_profile = true
  tags = local.common_tags
}

# IAM Role for Lambda Functions
module "lambda_role" {
  source = "../../modules/iam"
  environment = var.environment
  role_name = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole"; Effect = "Allow"; Principal = { Service = "lambda.amazonaws.com" } }]
  })
  managed_policy_arns = var.lambda_managed_policies
  tags = local.common_tags
}
