/**
 * Lambda Module Outputs
 */

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.main.invoke_arn
}

output "function_qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = aws_lambda_function.main.qualified_arn
}

output "function_version" {
  description = "Latest published version"
  value       = aws_lambda_function.main.version
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.lambda.name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "function_url" {
  description = "Function URL"
  value       = var.enable_function_url ? aws_lambda_function_url.main[0].function_url : null
}
