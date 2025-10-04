/**
 * CloudWatch Module Variables
 */

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "create_sns_topic" {
  description = "Create SNS topic for alarms"
  type        = bool
  default     = true
}

variable "alarm_email_addresses" {
  description = "Email addresses for alarm notifications"
  type        = list(string)
  default     = []
}

variable "metric_alarms" {
  description = "List of metric alarms to create"
  type = list(object({
    alarm_name          = string
    alarm_description   = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    dimensions          = optional(map(string))
    alarm_actions       = optional(list(string))
    ok_actions          = optional(list(string))
    treat_missing_data  = optional(string)
    insufficient_data_actions = optional(list(string))
  }))
  default = []
}

variable "log_groups" {
  description = "List of log groups to create"
  type = list(object({
    name           = string
    retention_days = optional(number)
  }))
  default = []
}

variable "dashboard_body" {
  description = "Dashboard body JSON"
  type        = string
  default     = null
}

variable "metric_filters" {
  description = "List of metric filters"
  type = list(object({
    name             = string
    log_group_name   = string
    pattern          = string
    metric_name      = string
    metric_namespace = string
    metric_value     = string
  }))
  default = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
