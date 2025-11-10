# S3 Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

# Lambda Outputs
output "webhook_lambda_function_name" {
  description = "Name of the webhook Lambda function"
  value       = aws_lambda_function.webhook_handler.function_name
}

output "webhook_lambda_function_arn" {
  description = "ARN of the webhook Lambda function"
  value       = aws_lambda_function.webhook_handler.arn
}

output "document_processor_function_name" {
  description = "Name of the document processor Lambda function"
  value       = aws_lambda_function.document_processor.function_name
}

output "document_processor_function_arn" {
  description = "ARN of the document processor Lambda function"
  value       = aws_lambda_function.document_processor.arn
}

# Step Functions Outputs
output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.contract_analysis.name
}

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.contract_analysis.arn
}

# EventBridge Outputs
output "jira_connection_arn" {
  description = "ARN of the Jira EventBridge connection"
  value       = aws_cloudwatch_event_connection.jira_connection.arn
}

output "jira_connection_secret_arn" {
  description = "ARN of the Jira connection secret"
  value       = aws_cloudwatch_event_connection.jira_connection.secret_arn
}

# API Gateway Outputs
output "api_gateway_url" {
  description = "API Gateway webhook URL"
  value       = "${aws_api_gateway_stage.webhook_stage.invoke_url}/webhook"
}

output "api_gateway_id" {
  description = "API Gateway ID"
  value       = aws_api_gateway_rest_api.webhook_api.id
}

output "api_gateway_stage_name" {
  description = "API Gateway stage name"
  value       = aws_api_gateway_stage.webhook_stage.stage_name
}

output "api_endpoint" {
  description = "Full API endpoint URL"
  value       = "${aws_api_gateway_stage.webhook_stage.invoke_url}/webhook"
}

output "webhook_url" {
  description = "Webhook URL for Jira configuration"
  value       = "${aws_api_gateway_stage.webhook_stage.invoke_url}/webhook"
}

# WAF Outputs
output "waf_acl_id" {
  description = "WAF Web ACL ID"
  value       = aws_wafv2_web_acl.webhook_acl.id
}

output "waf_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.webhook_acl.arn
}

output "waf_acl_name" {
  description = "WAF Web ACL name"
  value       = aws_wafv2_web_acl.webhook_acl.name
}