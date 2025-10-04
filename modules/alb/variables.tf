/**
 * ALB Module Variables
 */

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name" {
  description = "Name for the ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
}

variable "internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "S3 bucket prefix for access logs"
  type        = string
  default     = ""
}

variable "enable_http" {
  description = "Enable HTTP listener"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "redirect_http_to_https" {
  description = "Redirect HTTP to HTTPS"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of SSL certificate"
  type        = string
  default     = null
}

variable "additional_certificate_arns" {
  description = "Additional certificate ARNs"
  type        = list(string)
  default     = []
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "target_group_port" {
  description = "Port for target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for target group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Type of target (instance, ip, lambda)"
  type        = string
  default     = "instance"
}

variable "deregistration_delay" {
  description = "Time for deregistration delay"
  type        = number
  default     = 300
}

variable "health_check_enabled" {
  description = "Enable health check"
  type        = bool
  default     = true
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold"
  type        = number
  default     = 3
}

variable "health_check_timeout" {
  description = "Health check timeout"
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Health check interval"
  type        = number
  default     = 30
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_protocol" {
  description = "Health check protocol"
  type        = string
  default     = "HTTP"
}

variable "health_check_matcher" {
  description = "Health check success codes"
  type        = string
  default     = "200"
}

variable "enable_stickiness" {
  description = "Enable session stickiness"
  type        = bool
  default     = false
}

variable "stickiness_duration" {
  description = "Stickiness duration in seconds"
  type        = number
  default     = 86400
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
