/**
 * Database Layer - Outputs
 */

output "db_endpoint" {
  description = "Database endpoint"
  value       = module.app_database.db_instance_endpoint
  sensitive   = true
}

output "db_address" {
  description = "Database address"
  value       = module.app_database.db_instance_address
}

output "db_port" {
  description = "Database port"
  value       = module.app_database.db_instance_port
}

output "db_name" {
  description = "Database name"
  value       = module.app_database.db_instance_name
}

output "db_secret_arn" {
  description = "Secrets Manager ARN"
  value       = module.app_database.secret_arn
  sensitive   = true
}

output "db_security_group_id" {
  description = "Database security group ID"
  value       = module.app_database.db_security_group_id
}
