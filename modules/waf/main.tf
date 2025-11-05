variable "env" { type = string }
variable "rate_limit" { type = number default = 2000 }

resource "aws_wafv2_web_acl" "web_acl" {
  name  = "tech-waf-${var.env}"
  scope = "REGIONAL"

  default_action { allow {} }

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
    action { block {} }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "rateLimitRule"
    }
  }
}
