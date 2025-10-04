/**
 * IAM Module
 * 
 * Creates IAM roles, policies, and groups following least privilege principles.
 * 
 * Features:
 * - IAM roles with trust relationships
 * - Custom and managed policies
 * - Policy attachments
 * - Assume role policies
 * - Service-linked roles
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

# IAM Role
resource "aws_iam_role" "main" {
  name               = "${var.environment}-${var.role_name}"
  assume_role_policy = var.assume_role_policy
  description        = var.role_description
  max_session_duration = var.max_session_duration
  
  dynamic "inline_policy" {
    for_each = var.inline_policies
    
    content {
      name   = inline_policy.value.name
      policy = inline_policy.value.policy
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.role_name}"
      Environment = var.environment
    }
  )
}

# Attach AWS Managed Policies
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)
  
  role       = aws_iam_role.main.name
  policy_arn = each.value
}

# Custom IAM Policy
resource "aws_iam_policy" "custom" {
  count = var.create_custom_policy ? 1 : 0
  
  name        = "${var.environment}-${var.role_name}-policy"
  description = "Custom policy for ${var.role_name}"
  policy      = var.custom_policy_json
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.role_name}-policy"
      Environment = var.environment
    }
  )
}

# Attach Custom Policy
resource "aws_iam_role_policy_attachment" "custom" {
  count = var.create_custom_policy ? 1 : 0
  
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.custom[0].arn
}

# IAM Instance Profile (for EC2)
resource "aws_iam_instance_profile" "main" {
  count = var.create_instance_profile ? 1 : 0
  
  name = "${var.environment}-${var.role_name}-profile"
  role = aws_iam_role.main.name
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.role_name}-profile"
      Environment = var.environment
    }
  )
}
