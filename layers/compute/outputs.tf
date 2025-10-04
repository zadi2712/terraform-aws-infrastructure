/**
 * Compute Layer - Outputs
 */

output "web_server_ids" {
  description = "Web server instance IDs"
  value       = module.web_servers.instance_ids
}

output "web_server_private_ips" {
  description = "Web server private IPs"
  value       = module.web_servers.instance_private_ips
}

output "web_security_group_id" {
  description = "Web server security group ID"
  value       = module.web_servers.security_group_id
}
