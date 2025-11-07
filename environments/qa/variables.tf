variable "env" {
  description = "Deployment environment (qa, uat, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "rate_limit" {
  description = "Rate limit for WAF protection"
  type        = number
  default     = 2000
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "document_retention_days" {
  description = "S3 object retention period in days"
  type        = number
  default     = 30
}

variable "enable_intelligent_tiering" {
  description = "Enable S3 intelligent tiering"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "TechAutomation"
    Environment = "qa"
    ManagedBy   = "Terraform"
  }
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = "jira-webhook-handler"
}

variable "runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "python3.9"
}

variable "memory_size" {
  description = "Lambda memory allocation in MB"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "jira_api_token" {
  description = "Jira API token"
  type        = string
  sensitive   = true
}

variable "jira_email" {
  description = "Jira user email"
  type        = string
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
  description = "Webhook secret for Jira validation"
  type        = string
  sensitive   = true
}

variable "state_definition_file" {
  description = "Path to Step Function state definition JSON"
  type        = string
  default     = "state_machine_definition.json"
}
