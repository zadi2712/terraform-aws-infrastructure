/**
 * EC2 Module Outputs
 */

output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.main[*].id
}

output "instance_private_ips" {
  description = "List of private IP addresses"
  value       = aws_instance.main[*].private_ip
}

output "instance_public_ips" {
  description = "List of public IP addresses"
  value       = aws_instance.main[*].public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = var.create_iam_role ? aws_iam_role.ec2[0].arn : null
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = var.create_iam_role ? aws_iam_instance_profile.ec2[0].name : var.iam_instance_profile_name
}
