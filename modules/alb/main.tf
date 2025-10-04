/**
 * Application Load Balancer Module
 * 
 * Creates ALB with target groups, listeners, and health checks.
 * 
 * Features:
 * - Application Load Balancer
 * - Target groups with health checks
 * - HTTP/HTTPS listeners
 * - SSL certificate support
 * - Access logs to S3
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

# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "${var.environment}-${var.name}-alb-sg"
  description = "Security group for ${var.name} ALB"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name}-alb-sg"
      Environment = var.environment
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Allow HTTP ingress
resource "aws_security_group_rule" "alb_http_ingress" {
  count = var.enable_http ? 1 : 0
  
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP traffic"
}

# Allow HTTPS ingress
resource "aws_security_group_rule" "alb_https_ingress" {
  count = var.enable_https ? 1 : 0
  
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS traffic"
}

# Allow all egress
resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound traffic"
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.environment}-${var.name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids
  
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = var.enable_http2
  enable_cross_zone_load_balancing = true
  
  idle_timeout = var.idle_timeout
  
  dynamic "access_logs" {
    for_each = var.access_logs_bucket != null ? [1] : []
    
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name}-alb"
      Environment = var.environment
    }
  )
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "${var.environment}-${var.name}-tg"
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id
  
  target_type = var.target_type
  
  deregistration_delay = var.deregistration_delay
  
  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher
  }
  
  stickiness {
    type            = "lb_cookie"
    enabled         = var.enable_stickiness
    cookie_duration = var.stickiness_duration
  }
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name}-tg"
      Environment = var.environment
    }
  )
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  count = var.enable_http ? 1 : 0
  
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type = var.redirect_http_to_https ? "redirect" : "forward"
    
    dynamic "redirect" {
      for_each = var.redirect_http_to_https ? [1] : []
      
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    
    target_group_arn = var.redirect_http_to_https ? null : aws_lb_target_group.main.arn
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0
  
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Additional SSL certificates
resource "aws_lb_listener_certificate" "additional" {
  for_each = toset(var.additional_certificate_arns)
  
  listener_arn    = aws_lb_listener.https[0].arn
  certificate_arn = each.value
}
