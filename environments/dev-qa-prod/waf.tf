# Core Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be dev, qa, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "pfj-legal-tech-contracts"
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "S3 bucket name for document storage"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.s3_bucket_name))
    error_message = "S3 bucket name must be lowercase, contain only letters, numbers, and hyphens."
  }
}

# Jira Configuration
variable "jira_email" {
  description = "Jira email address"
  type        = string
  sensitive   = true
}

variable "jira_api_token" {
  description = "Jira API token"
  type        = string
  sensitive   = true
}

variable "jira_webhook_secret" {
  description = "Jira webhook secret for HMAC verification"
  type        = string
  sensitive   = true
}

variable "jira_base_url" {
  description = "Jira base URL"
  type        = string
}

# File Processing Configuration
variable "supported_file_types" {
  description = "Supported file types for processing (pdf,docx)"
  type        = string
  default     = "pdf,docx"
  
  validation {
    condition     = can(regex("^(pdf|docx)(,(pdf|docx))*$", var.supported_file_types))
    error_message = "Supported file types must be a comma-separated list of: pdf, docx"
  }
}

variable "max_file_size_mb" {
  description = "Maximum file size in MB"
  type        = number
  default     = 50
}

variable "max_retries" {
  description = "Maximum retry attempts"
  type        = number
  default     = 3
}

variable "download_timeout_seconds" {
  description = "Timeout for downloading files from Jira"
  type        = number
  default     = 120
}

variable "s3_upload_prefix" {
  description = "S3 prefix for uploaded files"
  type        = string
  default     = "uploads"
}

variable "max_webhook_body_size_mb" {
  description = "Maximum webhook body size in MB"
  type        = number
  default     = 10
}

# EventBridge Configuration
variable "jira_connection_name_pattern" {
  description = "Pattern for Jira connection names (for IAM policies)"
  type        = string
  default     = "Jira-Connection-*"
}

# Lambda Configuration
variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "python3.13"
}

variable "webhook_lambda_memory" {
  description = "Memory allocation for webhook Lambda"
  type        = number
  default     = 128
}

variable "webhook_lambda_timeout" {
  description = "Timeout for webhook Lambda"
  type        = number
  default     = 30
}

variable "document_processor_memory" {
  description = "Memory allocation for document processor Lambda"
  type        = number
  default     = 512
}

variable "document_processor_timeout" {
  description = "Timeout for document processor Lambda (tech-ExtractText)"
  type        = number
  default     = 180
}

# Monitoring Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

# API Gateway Configuration
variable "waf_rate_limit" {
  description = "WAF rate limit (requests per 5 minutes)"
  type        = number
  default     = 2000
}

variable "api_throttle_rate_limit" {
  description = "API Gateway throttle rate limit (requests per second)"
  type        = number
  default     = 10000
}

variable "api_throttle_burst_limit" {
  description = "API Gateway throttle burst limit"
  type        = number
  default     = 5000
}

variable "api_enable_caching" {
  description = "Enable API Gateway caching"
  type        = bool
  default     = false
}

variable "api_cache_cluster_size" {
  description = "API Gateway cache cluster size"
  type        = string
  default     = "0.5"
}

variable "api_cache_ttl_seconds" {
  description = "API Gateway cache TTL in seconds"
  type        = number
  default     = 300
}

variable "api_integration_timeout_ms" {
  description = "API Gateway integration timeout in milliseconds"
  type        = number
  default     = 29000
}

variable "api_enable_detailed_metrics" {
  description = "Enable detailed CloudWatch metrics for API Gateway"
  type        = bool
  default     = false
}

# Jira IP Allowlist Configuration
variable "jira_ip_ranges" {
  description = "List of Jira IP ranges to allow through WAF"
  type        = list(string)
  default     = []
}

variable "enable_jira_ip_allowlist" {
  description = "Enable Jira IP allowlist rule in WAF"
  type        = bool
  default     = true
}
# Lambda
 Layer Configuration
variable "create_lambda_layer" {
  description = "Whether to create a new Lambda layer or use existing ones"
  type        = bool
  default     = true
}

variable "existing_webhook_layer_arns" {
  description = "List of existing Lambda layer ARNs for webhook Lambda (used if create_lambda_layer is false)"
  type        = list(string)
  default     = []
}

variable "existing_extracttext_layer_arns" {
  description = "List of existing Lambda layer ARNs for ExtractText Lambda (used if create_lambda_layer is false)"
  type        = list(string)
  default     = []
}