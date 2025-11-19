# EventBridge - Beginner Example
# This creates a simple scheduled rule that triggers every 5 minutes

# Create an EventBridge rule that runs on a schedule
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name                = "${var.environment}-every-5-minutes-rule"
  description         = "Triggers every 5 minutes"
  schedule_expression = "rate(5 minutes)"

  tags = {
    Name        = "${var.environment}-scheduled-rule"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create a CloudWatch Log Group to capture events
resource "aws_cloudwatch_log_group" "eventbridge_logs" {
  name              = "/aws/events/${var.environment}-eventbridge-logs"
  retention_in_days = 7

  tags = {
    Name        = "${var.environment}-eventbridge-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create an EventBridge target to send events to CloudWatch Logs
resource "aws_cloudwatch_event_target" "log_target" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "SendToCloudWatchLogs"
  arn       = aws_cloudwatch_log_group.eventbridge_logs.arn
}

# Create a resource policy for CloudWatch Logs to allow EventBridge
resource "aws_cloudwatch_log_resource_policy" "eventbridge_log_policy" {
  policy_name = "${var.environment}-eventbridge-log-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.eventbridge_logs.arn}:*"
      }
    ]
  })
}
