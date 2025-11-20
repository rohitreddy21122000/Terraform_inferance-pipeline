output "main_bucket_id" {
  description = "The ID of the main S3 bucket"
  value       = module.s3_buckets.main_bucket_id
}

output "main_bucket_arn" {
  description = "The ARN of the main S3 bucket"
  value       = module.s3_buckets.main_bucket_arn
}

output "main_bucket_name" {
  description = "The name of the main S3 bucket"
  value       = module.s3_buckets.main_bucket_name
}

output "log_bucket_id" {
  description = "The ID of the log S3 bucket"
  value       = module.s3_buckets.log_bucket_id
}

output "log_bucket_arn" {
  description = "The ARN of the log S3 bucket"
  value       = module.s3_buckets.log_bucket_arn
}

output "log_bucket_name" {
  description = "The name of the log S3 bucket"
  value       = module.s3_buckets.log_bucket_name
}

output "folder_key" {
  description = "The key of the created folder"
  value       = module.s3_buckets.folder_key
}

# API Gateway Outputs
output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = module.api_gateway.api_id
}

output "api_gateway_invoke_url" {
  description = "Full invoke URL for the webhook endpoint"
  value       = module.api_gateway.invoke_url
}

output "api_gateway_stage_name" {
  description = "Name of the API Gateway stage"
  value       = module.api_gateway.stage_name
}

# WAF Outputs
output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = module.waf.waf_web_acl_id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = module.waf.waf_web_acl_arn
}

# Lambda Outputs
output "webhook_lambda_function_name" {
  description = "Name of the webhook Lambda function"
  value       = module.waf.webhook_lambda_function_name
}

# EventBridge Outputs
output "eventbridge_connection_name" {
  description = "Name of the EventBridge connection"
  value       = module.eventbridge.connection_name
}

output "eventbridge_connection_arn" {
  description = "ARN of the EventBridge connection"
  value       = module.eventbridge.connection_arn
}
