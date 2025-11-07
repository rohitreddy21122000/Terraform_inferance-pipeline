resource "aws_wafv2_web_acl" "web_acl" {
  name  = "tech-waf-${var.env}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "tech-waf-${var.env}"
  }

  rule {
    name     = "rateLimitRule"
    priority = 1

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "rateLimitRule"
    }
  }

  tags = var.tags
}

# Association: construct correct resource ARN for API Gateway stage
locals {
  resource_arn = var.api_type == "HTTP" ?
    "arn:aws:apigateway:${var.region}::/apis/${var.api_id}/stages/${var.stage_name}" :
    "arn:aws:apigateway:${var.region}::/restapis/${var.api_id}/stages/${var.stage_name}"
}

resource "aws_wafv2_web_acl_association" "api_gateway_association" {
  count = length(trim(local.resource_arn)) > 0 ? 1 : 0
  resource_arn = local.resource_arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}
