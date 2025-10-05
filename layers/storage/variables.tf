/**
 * Storage Layer - Variables
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

variable "enable_versioning" {
  description = "Enable S3 versioning for app data bucket"
  type        = bool
  default     = true
}

variable "create_backups_bucket" {
  description = "Create backups bucket"
  type        = bool
  default     = true
}

variable "app_data_lifecycle_rules" {
  description = "Lifecycle rules for app data bucket"
  type = list(object({
    id                                 = string
    enabled                            = bool
    prefix                             = optional(string)
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = []
}

variable "logs_lifecycle_rules" {
  description = "Lifecycle rules for logs bucket"
  type = list(object({
    id                                 = string
    enabled                            = bool
    prefix                             = optional(string)
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = []
}

variable "backups_lifecycle_rules" {
  description = "Lifecycle rules for backups bucket"
  type = list(object({
    id                                 = string
    enabled                            = bool
    prefix                             = optional(string)
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = []
}
