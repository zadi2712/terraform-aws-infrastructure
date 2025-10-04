variable "environment" { type = string }
variable "aws_region" { type = string }
variable "project_name" { type = string }
variable "enable_versioning" { type = bool; default = true }
variable "app_data_lifecycle_rules" { type = list(any); default = [] }
variable "logs_lifecycle_rules" { type = list(any); default = [] }
variable "backups_lifecycle_rules" { type = list(any); default = [] }
