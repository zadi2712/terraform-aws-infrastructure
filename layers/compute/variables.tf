/**
 * Compute Layer - Variables
 */

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "web_server_count" {
  description = "Number of web servers"
  type        = number
}

variable "web_instance_type" {
  description = "Instance type for web servers"
  type        = string
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = true
}
