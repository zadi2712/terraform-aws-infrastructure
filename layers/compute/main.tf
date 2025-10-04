/**
 * Compute Layer - Main Configuration
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

# Web Servers
module "web_servers" {
  source = "../../modules/ec2"
  
  environment    = var.environment
  name_prefix    = "web"
  instance_count = var.web_server_count
  instance_type  = var.web_instance_type
  
  vpc_id     = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
  
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr]
      description = "HTTP from VPC"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr]
      description = "HTTPS from VPC"
    }
  ]
  
  root_volume_size = var.root_volume_size
  ebs_optimized    = var.ebs_optimized
  
  tags = local.common_tags
}
