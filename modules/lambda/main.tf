/**
 * Lambda Function Module
 * 
 * Creates Lambda functions with IAM roles, environment variables, and triggers.
 * 
 * Features:
 * - Lambda function deployment
 * - IAM execution role
 * - VPC configuration support
 * - Environment variables
 * - CloudWatch Logs
 * - Dead letter queue support
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

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "${var.environment}-${var.function_name}-role"
  
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
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.function_name}-role"
      Environment = var.environment
    }
  )
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach VPC execution policy if VPC is configured
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = var.vpc_config != null ? 1 : 0
  
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Attach additional policies
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_policy_arns)
  
  role       = aws_iam_role.lambda.name
  policy_arn = each.value
}

# Custom policy
resource "aws_iam_role_policy" "custom" {
  count = var.custom_policy_json != null ? 1 : 0
  
  name   = "${var.environment}-${var.function_name}-custom-policy"
  role   = aws_iam_role.lambda.id
  policy = var.custom_policy_json
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.environment}-${var.function_name}"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.function_name}-logs"
      Environment = var.environment
    }
  )
}

# Lambda Function
resource "aws_lambda_function" "main" {
  function_name = "${var.environment}-${var.function_name}"
  description   = var.function_description
  
  filename         = var.filename
  source_code_hash = var.filename != null ? filebase64sha256(var.filename) : null
  
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version
  
  handler = var.handler
  runtime = var.runtime
  
  role    = aws_iam_role.lambda.arn
  timeout = var.timeout
  memory_size = var.memory_size
  
  reserved_concurrent_executions = var.reserved_concurrent_executions
  
  environment {
    variables = var.environment_variables
  }
  
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }
  
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    
    content {
      target_arn = var.dead_letter_target_arn
    }
  }
  
  dynamic "tracing_config" {
    for_each = var.enable_xray_tracing ? [1] : []
    
    content {
      mode = "Active"
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.function_name}"
      Environment = var.environment
    }
  )
  
  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_basic
  ]
}

# Lambda Permission for triggers
resource "aws_lambda_permission" "triggers" {
  for_each = { for idx, trigger in var.triggers : idx => trigger }
  
  statement_id  = "Allow${each.value.type}Invoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = each.value.principal
  source_arn    = each.value.source_arn
}

# Lambda Function URL (optional)
resource "aws_lambda_function_url" "main" {
  count = var.enable_function_url ? 1 : 0
  
  function_name      = aws_lambda_function.main.function_name
  authorization_type = var.function_url_auth_type
  
  dynamic "cors" {
    for_each = var.function_url_cors != null ? [var.function_url_cors] : []
    
    content {
      allow_origins     = cors.value.allow_origins
      allow_methods     = cors.value.allow_methods
      allow_headers     = cors.value.allow_headers
      expose_headers    = cors.value.expose_headers
      max_age           = cors.value.max_age
      allow_credentials = cors.value.allow_credentials
    }
  }
}
