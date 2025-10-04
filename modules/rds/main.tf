/**
 * RDS Module
 * 
 * Creates RDS database instances with best practices including:
 * - Multi-AZ deployment option
 * - Automated backups
 * - Encryption at rest
 * - Enhanced monitoring
 * - Parameter groups
 * - Subnet groups
 * 
 * Supports: MySQL, PostgreSQL, MariaDB, Oracle, SQL Server
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

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.identifier}-subnet-group"
      Environment = var.environment
    }
  )
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-${var.identifier}-rds-sg"
  description = "Security group for ${var.identifier} RDS instance"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.identifier}-rds-sg"
      Environment = var.environment
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Allow ingress from specified security groups or CIDR blocks
resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, sg_id in var.allowed_security_group_ids : idx => sg_id }
  
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.rds.id
  description              = "Allow access from security group ${each.value}"
}

resource "aws_security_group_rule" "ingress_cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.rds.id
  description       = "Allow access from CIDR blocks"
}

# RDS DB Parameter Group
resource "aws_db_parameter_group" "main" {
  count  = var.create_parameter_group ? 1 : 0
  name   = "${var.environment}-${var.identifier}-params"
  family = var.parameter_group_family
  
  dynamic "parameter" {
    for_each = var.parameters
    
    content {
      name  = parameter.value.name
      value = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.identifier}-params"
      Environment = var.environment
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Generate random password if not provided
resource "random_password" "master" {
  count   = var.master_password == "" ? 1 : 0
  length  = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
.store_password_in_secrets_manager ? 1 : 0
  secret_id     = aws_secretsmanager_secret.db_password[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = var.master_password != "" ? var.master_password : random_password.master[0].result
    engine   = var.engine
    host     = aws_db_instance.main.address
    port     = var.port
    dbname   = var.database_name
  })
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.environment}-${var.identifier}"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id           = var.kms_key_id
  iops                 = var.iops
  
  db_name  = var.database_name
  username = var.master_username
  password = var.master_password != "" ? var.master_password : random_password.master[0].result
  port     = var.port
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = var.create_parameter_group ? aws_db_parameter_group.main[0].name : var.parameter_group_name
  
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone
  publicly_accessible    = var.publicly_accessible
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval            = var.monitoring_interval
  monitoring_role_arn           = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null
  
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period
  
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately          = var.apply_immediately
  
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.environment}-${var.identifier}-final-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  copy_tags_to_snapshot = true
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.identifier}"
      Environment = var.environment
    }
  )
  
  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      password,
    ]
  }
}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.environment}-${var.identifier}-rds-monitoring"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.identifier}-rds-monitoring"
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
