variable "environment" { type = string }
variable "aws_region" { type = string }
variable "project_name" { type = string }
variable "create_sns_topic" { type = bool; default = true }
variable "alarm_email_addresses" { type = list(string); default = [] }
variable "metric_alarms" { type = list(any); default = [] }
variable "log_groups" { type = list(any); default = [] }
