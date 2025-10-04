/**
 * EC2 Module
 * 
 * Creates EC2 instances with security groups, IAM roles, and optional features
 * like monitoring, detailed logging, and EBS optimization.
 * 
 * Features:
 * - Multiple instance support
 * - Custom security groups
 * - IAM instance profiles
 * - User data support
 * - EBS optimization
 * - Detailed monitoring
 * - Root volume encryption
 * 
 * Usage:
 * module "web_servers" {
 *   source = "../../modules/ec2"
 *   
 *   environment      = "prod"
 *   name_prefix      = "web"
 *   instance_count   = 2
 *   instance_type    = "t3.medium"
 *   ami_id           = "ami-xxxxx"
 *   subnet_ids       = module.vpc.private_subnet_ids
 *   vpc_id           = module.vpc.vpc_id
 * }
 */

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for EC2 instances
resource "aws_security_group" "ec2" {
  name_prefix = "${var.environment}-${var.name_prefix}-sg"
  description = "Security group for ${var.name_prefix} EC2 instances"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name_prefix}-sg"
      Environment = var.environment
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Security Group Rules
resource "aws_security_group_rule" "ingress_rules" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }
  
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  description       = lookup(each.value, "description", "")
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.ec2.id
}

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.environment}-${var.name_prefix}-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name_prefix}-role"
      Environment = var.environment
    }
  )
}

# Attach managed policies to IAM role
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = var.create_iam_role ? toset(var.iam_managed_policies) : []
  
  role       = aws_iam_role.ec2[0].name
  policy_arn = each.value
}

# Custom IAM policy for EC2 instances
resource "aws_iam_role_policy" "custom" {
  count = var.create_iam_role && var.iam_custom_policy != "" ? 1 : 0
  
  name   = "${var.environment}-${var.name_prefix}-custom-policy"
  role   = aws_iam_role.ec2[0].id
  policy = var.iam_custom_policy
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.environment}-${var.name_prefix}-profile"
  role  = aws_iam_role.ec2[0].name
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name_prefix}-profile"
      Environment = var.environment
    }
  )
}

# EC2 Instances
resource "aws_instance" "main" {
  count = var.instance_count
  
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2[0].id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = concat([aws_security_group.ec2.id], var.additional_security_group_ids)
  iam_instance_profile   = var.create_iam_role ? aws_iam_instance_profile.ec2[0].name : var.iam_instance_profile_name
  
  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change
  
  monitoring              = var.enable_detailed_monitoring
  ebs_optimized          = var.ebs_optimized
  disable_api_termination = var.disable_api_termination
  
  key_name = var.key_name
  
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = var.root_volume_delete_on_termination
    
    tags = merge(
      var.tags,
      {
        Name        = "${var.environment}-${var.name_prefix}-root-${count.index + 1}"
        Environment = var.environment
      }
    )
  }
  
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
    }
  }
  
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.require_imdsv2 ? "required" : "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name_prefix}-${count.index + 1}"
      Environment = var.environment
    }
  )
  
  volume_tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name_prefix}-volume-${count.index + 1}"
      Environment = var.environment
    }
  )
  
  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}
