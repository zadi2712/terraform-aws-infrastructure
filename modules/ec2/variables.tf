/**
 * EC2 Module Variables
 */

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EC2 instances will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EC2 instances"
  type        = list(string)
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use (leave empty for latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Replace instance when user data changes"
  type        = bool
  default     = false
}

variable "ingress_rules" {
  description = "List of ingress rules for security group"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
    description              = optional(string)
  }))
  default = []
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach"
  type        = list(string)
  default     = []
}

variable "create_iam_role" {
  description = "Whether to create IAM role for EC2"
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile name (used if create_iam_role is false)"
  type        = string
  default     = null
}

variable "iam_managed_policies" {
  description = "List of IAM managed policy ARNs to attach"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
}

variable "iam_custom_policy" {
  description = "Custom IAM policy JSON"
  type        = string
  default     = ""
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = true
}

variable "disable_api_termination" {
  description = "Enable termination protection"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of root volume (gp3, gp2, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Encrypt root volume"
  type        = bool
  default     = true
}

variable "root_volume_delete_on_termination" {
  description = "Delete root volume on instance termination"
  type        = bool
  default     = true
}

variable "ebs_block_devices" {
  description = "Additional EBS block devices"
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string)
    encrypted             = optional(bool)
    delete_on_termination = optional(bool)
    iops                  = optional(number)
    throughput            = optional(number)
  }))
  default = []
}

variable "require_imdsv2" {
  description = "Require IMDSv2 for instance metadata"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
