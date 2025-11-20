# REST API Gateway
resource "aws_api_gateway_rest_api" "webhook_api" {
  name        = var.api_name
  description = "API Gateway for webhook handler"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  binary_media_types = ["*/*"]

  tags = var.tags
}

# IAM Role for API Gateway CloudWatch Logging
resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  count = var.enable_cloudwatch_logging ? 1 : 0
  name  = "${var.api_name}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_policy" {
  count      = var.enable_cloudwatch_logging ? 1 : 0
  role       = aws_iam_role.api_gateway_cloudwatch_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Set CloudWatch Logs role in API Gateway account settings
resource "aws_api_gateway_account" "api_gateway_account" {
  count               = var.enable_cloudwatch_logging ? 1 : 0
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role[0].arn

  depends_on = [aws_iam_role_policy_attachment.api_gateway_cloudwatch_policy]
}

# API Gateway Resource (webhook path)
resource "aws_api_gateway_resource" "webhook_resource" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  parent_id   = aws_api_gateway_rest_api.webhook_api.root_resource_id
  path_part   = var.resource_path
}

# CORS Configuration for OPTIONS method
resource "aws_api_gateway_method" "webhook_options" {
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  resource_id   = aws_api_gateway_resource.webhook_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "webhook_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  resource_id = aws_api_gateway_resource.webhook_resource.id
  http_method = aws_api_gateway_method.webhook_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "webhook_options_response" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  resource_id = aws_api_gateway_resource.webhook_resource.id
  http_method = aws_api_gateway_method.webhook_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "webhook_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  resource_id = aws_api_gateway_resource.webhook_resource.id
  http_method = aws_api_gateway_method.webhook_options.http_method
  status_code = aws_api_gateway_method_response.webhook_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# POST Method for webhook
resource "aws_api_gateway_method" "webhook_post" {
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  resource_id   = aws_api_gateway_resource.webhook_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda Integration with Proxy
resource "aws_api_gateway_integration" "webhook_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.webhook_api.id
  resource_id             = aws_api_gateway_resource.webhook_resource.id
  http_method             = aws_api_gateway_method.webhook_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.webhook_api.execution_arn}/*/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "webhook_deployment" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.webhook_resource.id,
      aws_api_gateway_method.webhook_post.id,
      aws_api_gateway_integration.webhook_lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.webhook_lambda_integration,
    aws_api_gateway_integration.webhook_options_integration
  ]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "webhook_stage" {
  deployment_id = aws_api_gateway_deployment.webhook_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  stage_name    = var.stage_name

  tags = var.tags
}

# Stage Throttling Settings
resource "aws_api_gateway_method_settings" "webhook_settings" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  stage_name  = aws_api_gateway_stage.webhook_stage.stage_name
  method_path = "*/*"

  settings {
    throttling_rate_limit  = var.throttle_rate_limit
    throttling_burst_limit = var.throttle_burst_limit
    logging_level          = var.enable_cloudwatch_logging ? "INFO" : "OFF"
    data_trace_enabled     = var.enable_cloudwatch_logging
    metrics_enabled        = true
  }
}

# WAF Association with API Gateway
resource "aws_wafv2_web_acl_association" "api_gateway_waf" {
  count = var.enable_waf_association ? 1 : 0

  resource_arn = aws_api_gateway_stage.webhook_stage.arn
  web_acl_arn  = var.waf_web_acl_arn
}
