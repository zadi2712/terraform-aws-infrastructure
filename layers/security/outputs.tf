output "ec2_role_arn" { value = module.ec2_role.role_arn }
output "ec2_instance_profile_name" { value = module.ec2_role.instance_profile_name }
output "lambda_role_arn" { value = module.lambda_role.role_arn }
