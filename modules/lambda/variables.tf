 = "Custom IAM policy JSON"
  type        = string
  default     = null
}

variable "triggers" {
  description = "List of trigger configurations"
  type = list(object({
    type       = string
    principal  = string
    source_arn = string
  }))
  default = []
}

variable "enable_function_url" {
  description = "Enable Lambda function URL"
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "Authorization type for function URL (NONE or AWS_IAM)"
  type        = string
  default     = "AWS_IAM"
  
  validation {
    condition     = contains(["NONE", "AWS_IAM"], var.function_url_auth_type)
    error_message = "Auth type must be NONE or AWS_IAM."
  }
}

variable "function_url_cors" {
  description = "CORS configuration for function URL"
  type = object({
    allow_origins     = list(string)
    allow_methods     = list(string)
    allow_headers     = list(string)
    expose_headers    = list(string)
    max_age           = number
    allow_credentials = bool
  })
  default = null
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
