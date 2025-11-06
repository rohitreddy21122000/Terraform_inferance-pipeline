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
        limit = var.rate_limit
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

  # Additional security rules
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    override_action { 
      none {} 
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    override_action { 
      none {} 
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
    }
  }
}

# Associate WAF with API Gateway
resource "aws_wafv2_web_acl_association" "api_gateway_association" {
  resource_arn = var.api_gateway_arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}
