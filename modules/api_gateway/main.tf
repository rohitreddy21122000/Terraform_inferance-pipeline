variable "env" { type = string }
variable "step_function_arn" { type = string }
variable "region" { type = string }

resource "aws_apigatewayv2_api" "http_api" {
  name          = "tech-api-${var.env}"
  protocol_type = "HTTP"
}

# IAM role for API Gateway to invoke Step Functions
resource "aws_iam_role" "api_gw_step_function_role" {
  name = "apigw-stepfunction-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "api_gw_step_function_policy" {
  name = "apigw-stepfunction-policy-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "states:StartExecution"
      ]
      Resource = var.step_function_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "api_gw_step_function_attach" {
  role       = aws_iam_role.api_gw_step_function_role.name
  policy_arn = aws_iam_policy.api_gw_step_function_policy.arn
}

# Integration with Step Functions
resource "aws_apigatewayv2_integration" "step_function_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_subtype    = "StepFunctions-StartExecution"
  credentials_arn        = aws_iam_role.api_gw_step_function_role.arn
  
  request_parameters = {
    StateMachineArn = var.step_function_arn
    Input          = "$request.body"
  }
}

resource "aws_apigatewayv2_route" "ingest" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /ingest"
  target    = "integrations/${aws_apigatewayv2_integration.step_function_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 500
    throttling_rate_limit  = 1000
  }
}

# Note: No Lambda permissions needed as API Gateway now calls Step Functions directly
