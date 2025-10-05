/**
 * Database Layer - Variables
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

variable "db_identifier" {
  description = "Database identifier"
  type        = string
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Maximum storage for autoscaling"
  type        = number
}

variable "db_storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "dbadmin"
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
}

variable "db_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
}

variable "db_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
}

variable "db_enabled_cloudwatch_logs" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

variable "db_monitoring_interval" {
  description = "Enhanced monitoring interval"
  type        = number
  default     = 0
}
