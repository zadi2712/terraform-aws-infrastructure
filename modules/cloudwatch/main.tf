/**
 * CloudWatch Module
 * 
 * Creates CloudWatch alarms, dashboards, and log groups.
 * 
 * Features:
 * - Metric alarms with SNS notifications
 * - Custom dashboards
 * - Log groups with retention
 * - Metric filters
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

# SNS Topic for Alarms
resource "aws_sns_topic" "alarms" {
  count = var.create_sns_topic ? 1 : 0
  
  name = "${var.environment}-${var.name}-alarms"
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name}-alarms"
      Environment = var.environment
    }
  )
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "alarms" {
  for_each = var.create_sns_topic ? toset(var.alarm_email_addresses) : []
  
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = each.value
}

# CloudWatch Metric Alarms
resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = { for idx, alarm in var.metric_alarms : alarm.alarm_name => alarm }
  
  alarm_name          = "${var.environment}-${each.value.alarm_name}"
  alarm_description   = each.value.alarm_description
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  
  alarm_actions = concat(
    var.create_sns_topic ? [aws_sns_topic.alarms[0].arn] : [],
    lookup(each.value, "alarm_actions", [])
  )
  
  ok_actions = lookup(each.value, "ok_actions", [])
  
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", [])
  
  treat_missing_data = lookup(each.value, "treat_missing_data", "missing")
  
  dimensions = lookup(each.value, "dimensions", {})
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${each.value.alarm_name}"
      Environment = var.environment
    }
  )
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "logs" {
  for_each = { for idx, lg in var.log_groups : lg.name => lg }
  
  name              = "${var.environment}-${each.value.name}"
  retention_in_days = lookup(each.value, "retention_days", 7)
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${each.value.name}"
      Environment = var.environment
    }
  )
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  count = var.dashboard_body != null ? 1 : 0
  
  dashboard_name = "${var.environment}-${var.name}-dashboard"
  dashboard_body = var.dashboard_body
}

# Metric Filters
resource "aws_cloudwatch_log_metric_filter" "filters" {
  for_each = { for idx, filter in var.metric_filters : filter.name => filter }
  
  name           = "${var.environment}-${each.value.name}"
  log_group_name = aws_cloudwatch_log_group.logs[each.value.log_group_name].name
  pattern        = each.value.pattern
  
  metric_transformation {
    name      = each.value.metric_name
    namespace = each.value.metric_namespace
    value     = each.value.metric_value
  }
}
