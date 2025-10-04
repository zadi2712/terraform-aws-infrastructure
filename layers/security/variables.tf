/**
 * Security Layer - Variables
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

variable "kms_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
}
