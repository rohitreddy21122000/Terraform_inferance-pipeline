variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "qa"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# S3 variables
variable "bucket_name" {
  description = "S3 bucket name for storing documents"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "document_retention_days" {
  description = "Number of days to retain documents"
  type        = number
  default     = 90
}

variable "enable_intelligent_tiering" {
  description = "Enable S3 intelligent tiering"
  type        = bool
  default     = false
}

# Lambda variables
variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = "tech-webhooklambda"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 90
}

# Jira variables
variable "jira_api_token" {
  description = "Jira API token"
  type        = string
  sensitive   = true
}

variable "jira_email" {
  description = "Jira email address"
  type        = string
  sensitive   = true
}

variable "jira_base_url" {
  description = "Jira base URL"
  type        = string
}

variable "jira_connection_arn" {
  description = "Jira connection ARN"
  type        = string
}

variable "jira_webhook_secret" {
  description = "Jira webhook secret"
  type        = string
  sensitive   = true
}

# Step Functions variables
variable "state_definition_file" {
  description = "Step Functions state definition file"
  type        = string
  default     = "state_machine_definition.json"
}

# WAF variables
variable "waf_rate_limit" {
  description = "WAF rate limit per 5 minutes"
  type        = number
  default     = 2000
}
