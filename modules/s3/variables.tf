/**
 * S3 Module Variables
 */

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if not empty"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable versioning"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (uses AES256 if not provided)"
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "Block all public access"
  type        = bool
  default     = true
}

variable "logging_bucket" {
  description = "Target bucket for access logs"
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
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

variable "bucket_policy" {
  description = "JSON bucket policy"
  type        = string
  default     = null
}

variable "cors_rules" {
  description = "CORS rules"
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
