/**
 * CloudWatch Module Outputs
 */

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = var.create_sns_topic ? aws_sns_topic.alarms[0].arn : null
}

output "alarm_arns" {
  description = "ARNs of created alarms"
  value       = { for k, v in aws_cloudwatch_metric_alarm.alarms : k => v.arn }
}

output "log_group_arns" {
  description = "ARNs of created log groups"
  value       = { for k, v in aws_cloudwatch_log_group.logs : k => v.arn }
}

output "dashboard_arn" {
  description = "ARN of the dashboard"
  value       = var.dashboard_body != null ? aws_cloudwatch_dashboard.main[0].dashboard_arn : null
}
