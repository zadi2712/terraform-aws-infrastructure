/**
 * ALB Module Outputs
 */

output "alb_id" {
  description = "ID of the load balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.main.id
}

output "security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "http_listener_arn" {
  description = "ARN of HTTP listener"
  value       = var.enable_http ? aws_lb_listener.http[0].arn : null
}

output "https_listener_arn" {
  description = "ARN of HTTPS listener"
  value       = var.enable_https ? aws_lb_listener.https[0].arn : null
}
