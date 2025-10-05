/**
 * Storage Layer - Outputs
 */

output "app_data_bucket_id" {
  description = "App data bucket name"
  value       = module.app_data_bucket.bucket_id
}

output "app_data_bucket_arn" {
  description = "App data bucket ARN"
  value       = module.app_data_bucket.bucket_arn
}

output "logs_bucket_id" {
  description = "Logs bucket name"
  value       = module.logs_bucket.bucket_id
}

output "logs_bucket_arn" {
  description = "Logs bucket ARN"
  value       = module.logs_bucket.bucket_arn
}

output "backups_bucket_id" {
  description = "Backups bucket name"
  value       = var.create_backups_bucket ? module.backups_bucket[0].bucket_id : null
}

output "backups_bucket_arn" {
  description = "Backups bucket ARN"
  value       = var.create_backups_bucket ? module.backups_bucket[0].bucket_arn : null
}
