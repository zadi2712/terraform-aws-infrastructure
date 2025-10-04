/**
 * Monitoring Layer - Main Configuration
 */
terraform {
  required_version = ">= 1.5.0"
  required_providers { aws = { source = "hashicorp/aws"; version = "~> 5.0" } }
  backend "s3" {}
}
provider "aws" { region = var.aws_region; default_tags { tags = local.common_tags } }

module "cloudwatch" {
  source = "../../modules/cloudwatch"
  environment = var.environment
  name = var.project_name
  create_sns_topic = var.create_sns_topic
  alarm_email_addresses = var.alarm_email_addresses
  metric_alarms = var.metric_alarms
  log_groups = var.log_groups
  tags = local.common_tags
}
