/**
 * IAM Module Variables
 */

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = ""
}

variable "assume_role_policy" {
  description = "JSON assume role policy document"
  type        = string
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds"
  type        = number
  default     = 3600
  
  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Session duration must be between 1 hour (3600) and 12 hours (43200)."
  }
}

variable "managed_policy_arns" {
  description = "List of ARNs of AWS managed policies to attach"
  type        = list(string)
  default     = []
}

variable "create_custom_policy" {
  description = "Whether to create a custom policy"
  type        = bool
  default     = false
}

variable "custom_policy_json" {
  description = "JSON for custom IAM policy"
  type        = string
  default     = ""
}

variable "inline_policies" {
  description = "List of inline policies"
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "create_instance_profile" {
  description = "Create an instance profile for EC2"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
