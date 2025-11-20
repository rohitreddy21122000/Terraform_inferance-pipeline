output "api_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.webhook_api.id
}

output "api_arn" {
  description = "ARN of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.webhook_api.arn
}

output "api_name" {
  description = "Name of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.webhook_api.name
}

output "api_endpoint" {
  description = "Base URL of the API Gateway"
  value       = aws_api_gateway_rest_api.webhook_api.execution_arn
}

output "invoke_url" {
  description = "Full invoke URL for the webhook endpoint"
  value       = "${aws_api_gateway_stage.webhook_stage.invoke_url}/${var.resource_path}"
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.webhook_stage.stage_name
}

output "stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_api_gateway_stage.webhook_stage.arn
}

output "deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = aws_api_gateway_deployment.webhook_deployment.id
}
