output "connection_name" {
  description = "Name of the EventBridge connection"
  value       = aws_cloudwatch_event_connection.webhook_connection.name
}

output "connection_arn" {
  description = "ARN of the EventBridge connection"
  value       = aws_cloudwatch_event_connection.webhook_connection.arn
}

output "connection_secret_arn" {
  description = "ARN of the secret created for the connection"
  value       = aws_cloudwatch_event_connection.webhook_connection.secret_arn
}
