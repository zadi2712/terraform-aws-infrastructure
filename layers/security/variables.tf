variable "environment" { type = string }
variable "aws_region" { type = string }
variable "project_name" { type = string }
variable "ec2_managed_policies" { type = list(string); default = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"] }
variable "lambda_managed_policies" { type = list(string); default = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"] }
