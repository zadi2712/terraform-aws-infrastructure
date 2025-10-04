/**
 * Security Layer - Outputs
 */

output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.main.id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.main.arn
}

output "ec2_role_arn" {
  description = "EC2 instance role ARN"
  value       = module.ec2_role.role_arn
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = module.ec2_role.instance_profile_name
}

output "lambda_role_arn" {
  description = "Lambda execution role ARN"
  value       = module.lambda_role.role_arn
}

output "rds_monitoring_role_arn" {
  description = "RDS monitoring role ARN"
  value       = module.rds_monitoring_role.role_arn
}
