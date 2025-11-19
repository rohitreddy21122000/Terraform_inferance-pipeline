# S3 Bucket Outputs
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.my_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.my_bucket.arn
}

output "bucket_region" {
  description = "The region where the S3 bucket is created"
  value       = aws_s3_bucket.my_bucket.region
}

# EventBridge Outputs
output "eventbridge_rule_name" {
  description = "The name of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.every_five_minutes.name
}

output "eventbridge_rule_arn" {
  description = "The ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.every_five_minutes.arn
}

output "eventbridge_log_group" {
  description = "The CloudWatch Log Group for EventBridge events"
  value       = aws_cloudwatch_log_group.eventbridge_logs.name
}

# Step Functions Outputs
output "step_function_arn" {
  description = "The ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.simple_workflow.arn
}

output "step_function_name" {
  description = "The name of the Step Functions state machine"
  value       = aws_sfn_state_machine.simple_workflow.name
}

output "step_function_log_group" {
  description = "The CloudWatch Log Group for Step Functions"
  value       = aws_cloudwatch_log_group.step_functions_logs.name
}
