output "waf_web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.api_protection.id
}

output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.api_protection.arn
}

output "webhook_lambda_function_name" {
  description = "Name of the webhook Lambda function"
  value       = aws_lambda_function.webhook_handler.function_name
}

output "webhook_lambda_function_arn" {
  description = "ARN of the webhook Lambda function"
  value       = aws_lambda_function.webhook_handler.arn
}

output "extract_lambda_function_name" {
  description = "Name of the extract text Lambda function"
  value       = aws_lambda_function.extract_text.function_name
}

output "extract_lambda_function_arn" {
  description = "ARN of the extract text Lambda function"
  value       = aws_lambda_function.extract_text.arn
}

output "lambda_layer_arn" {
  description = "ARN of the Lambda layer"
  value       = aws_lambda_layer_version.extract_layer.arn
}

output "webhook_lambda_role_arn" {
  description = "ARN of the webhook Lambda IAM role"
  value       = aws_iam_role.webhook_lambda_role.arn
}

output "extract_lambda_role_arn" {
  description = "ARN of the extract Lambda IAM role"
  value       = aws_iam_role.extract_lambda_role.arn
}

output "webhook_lambda_log_group" {
  description = "CloudWatch log group for webhook Lambda"
  value       = aws_cloudwatch_log_group.webhook_lambda_logs.name
}

output "extract_lambda_log_group" {
  description = "CloudWatch log group for extract Lambda"
  value       = aws_cloudwatch_log_group.extract_lambda_logs.name
}
