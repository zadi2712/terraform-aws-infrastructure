/**
 * Networking Layer - Main Configuration
 * 
 * This is the root module for networking infrastructure.
 * Environment-specific values are loaded from environments/{env}/*.tfvars
 */

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  
  enable_flow_logs         = var.enable_flow_logs
  flow_logs_retention_days = var.flow_logs_retention_days
  
  tags = local.common_tags
}
