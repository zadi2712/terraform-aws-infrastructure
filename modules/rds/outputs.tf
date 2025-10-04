/**
 * RDS Module Outputs
 */

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "Connection endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Database hostname"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.rds.id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "secret_arn" {
  description = "Secrets Manager secret ARN"
  value       = var.store_password_in_secrets_manager ? aws_secretsmanager_secret.db_password[0].arn : null
}
