output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_id" {
  value = aws_apigatewayv2_api.http_api.id
}

output "stage" {
  value = aws_apigatewayv2_stage.default.name
}

output "api_gateway_arn" {
  value = aws_apigatewayv2_api.http_api.arn
}
