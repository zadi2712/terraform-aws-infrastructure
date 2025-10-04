variable "environment" { type = string }
variable "aws_region" { type = string }
variable "project_name" { type = string }
variable "create_hosted_zone" { type = bool; default = false }
variable "domain_name" { type = string; default = "" }
