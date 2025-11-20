variable "api_name" {
  description = "Name of the API Gateway REST API"
  type        = string
  default     = "tech-webhookhandler-api"
}

variable "resource_path" {
  description = "Path part for the API Gateway resource"
  type        = string
  default     = "webhook"
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "devstage"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to integrate with"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with API Gateway"
  type        = string
  default     = ""
}

variable "enable_waf_association" {
  description = "Enable WAF association with API Gateway"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logging" {
  description = "Enable CloudWatch logging for API Gateway"
  type        = bool
  default     = false
}

variable "throttle_rate_limit" {
  description = "API Gateway throttle rate limit (requests per second)"
  type        = number
  default     = 1000
}

variable "throttle_burst_limit" {
  description = "API Gateway throttle burst limit"
  type        = number
  default     = 500
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Tech"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
