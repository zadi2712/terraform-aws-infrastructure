/**
 * DNS Layer - Main Configuration
 */
terraform {
  required_version = ">= 1.5.0"
  required_providers { aws = { source = "hashicorp/aws"; version = "~> 5.0" } }
  backend "s3" {}
}
provider "aws" { region = var.aws_region; default_tags { tags = local.common_tags } }

# Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0
  name = var.domain_name
  tags = merge(local.common_tags, { Name = var.domain_name })
}
