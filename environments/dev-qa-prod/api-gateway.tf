# API Gateway with WAF protection

# IPv4 IP Set for Jira IP ranges
resource "aws_wafv2_ip_set" "jira_ipv4" {
  name               = "jira-ipv4-ranges"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses = [
    "18.184.99.224/28",
    "18.234.32.224/28",
    "13.52.5.96/28",
    "52.215.192.224/28",
    "104.192.136.0/21",
    "13.200.41.128/25",
    "16.63.53.128/25",
    "13.236.8.224/28",
    "43.202.69.0/25",
    "185.166.140.0/22",
    "18.246.31.224/28",
    "18.136.214.96/28"
  ]

  tags = local.common_tags
}

# IPv6 IP Set for Jira IP ranges
resource "aws_wafv2_ip_set" "jira_ipv6" {
  name               = "jira-ipv6-ranges"
  scope              = "REGIONAL"
  ip_address_version = "IPV6"
  addresses = [
    "2a05:d014:0f99:dd04:0000:0000:0000:0000/63",
    "2a05:d018:034d:5804:0000:0000:0000:0000/63",
    "2600:1f14:0824:0306:0000:0000:0000:0000/64",
    "2406:da1c:01e0:a206:0000:0000:0000:0000/64",
    "2600:1f1c:0cc5:2304:0000:0000:0000:0000/63",
    "2600:1f18:2146:e306:0000:0000:0000:0000/64",
    "2406:da1c:01e0:a204:0000:0000:0000:0000/63",
    "2600:1f18:2146:e304:0000:0000:0000:0000/63",
    "2a05:d018:034d:5806:0000:0000:0000:0000/64",
    "2406:da18:0809:0e06:0000:0000:0000:0000/64",
    "2a05:d014:0f99:dd06:0000:0000:0000:0000/64",
    "2600:1f14:0824:0304:0000:0000:0000:0000/63",
    "2406:da18:0809:0e04:0000:0000:0000:0000/63",
    "2401:1d80:3000:0000:0000:0000:0000:0000/36"
  ]

  tags = local.common_tags
}

# WAF Web ACL - Restricts access to Jira IPs only
resource "aws_wafv2_web_acl" "webhook_acl" {
  name  = "webhook-ACL"
  scope = "REGIONAL"

  # SECURITY: Default action is BLOCK - only allow Jira IPs
  default_action {
    block {}
  }

  
  rule {
    name     = "AllowJiraIPv4"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.jira_ipv4.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowJiraIPv4"
      sampled_requests_enabled   = true
    }
  }

  # IPv6 rule for Jira IP ranges - ALLOW these IPs
  rule {
    name     = "AllowJiraIPv6"
    priority = 2

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.jira_ipv6.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowJiraIPv6"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Block Anonymous IPs (applies to allowed IPs)
  rule {
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 50

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Block Known Bad Inputs
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 200

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Block SQL Injection
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 201

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Common Rule Set
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 700

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "webhook-ACL"
    sampled_requests_enabled   = true
  }

  tags = local.common_tags
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "webhook_api" {
  name        = "webhookAPI"
  description = "API Gateway for webhook processing"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  binary_media_types = ["*/*"]

  tags = local.common_tags
}

# API Gateway Resource
resource "aws_api_gateway_resource" "webhook_resource" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  parent_id   = aws_api_gateway_rest_api.webhook_api.root_resource_id
  path_part   = "webhook"
}

# API Gateway Method
resource "aws_api_gateway_method" "webhook_method" {
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  resource_id   = aws_api_gateway_resource.webhook_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = false
}

# API Gateway Integration
resource "aws_api_gateway_integration" "webhook_integration" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  resource_id = aws_api_gateway_resource.webhook_resource.id
  http_method = aws_api_gateway_method.webhook_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.webhook_handler.arn}/invocations"
  timeout_milliseconds   = 29000
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.webhook_handler.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.webhook_api.execution_arn}/*/*"
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/webhookAPI"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "webhook_deployment" {
  depends_on = [
    aws_api_gateway_method.webhook_method,
    aws_api_gateway_integration.webhook_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.webhook_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.webhook_resource.id,
      aws_api_gateway_method.webhook_method.id,
      aws_api_gateway_integration.webhook_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "webhook_stage" {
  deployment_id = aws_api_gateway_deployment.webhook_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  stage_name    = "stage1"

  # Throttling settings
  throttle_settings {
    rate_limit  = 1000
    burst_limit = 500
  }

  cache_cluster_enabled = false

  # Access logging
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  xray_tracing_enabled = var.enable_xray_tracing

  tags = local.common_tags
}

# Associate WAF with API Gateway
resource "aws_wafv2_web_acl_association" "webhook_acl_association" {
  resource_arn = aws_api_gateway_stage.webhook_stage.arn
  web_acl_arn  = aws_wafv2_web_acl.webhook_acl.arn
}

# API Gateway Method Settings
resource "aws_api_gateway_method_settings" "webhook_settings" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  stage_name  = aws_api_gateway_stage.webhook_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = var.api_enable_detailed_metrics
    logging_level         = var.api_enable_detailed_metrics ? "INFO" : "OFF"
    data_trace_enabled    = var.api_enable_detailed_metrics
    throttling_rate_limit = 1000
    throttling_burst_limit = 500
    caching_enabled       = false
  }
}