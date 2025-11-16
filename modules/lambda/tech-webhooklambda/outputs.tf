output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.webhook_handler.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.webhook_handler.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.webhook_handler.invoke_arn
}

output "role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}

variable.tf
variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.13"
}

variable "memory_size" {
  description = "Memory allocation for Lambda"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout for Lambda function"
  type        = number
  default     = 30
}

variable "jira_webhook_secret" {
  description = "Jira webhook secret"
  type        = string
  sensitive   = true
}

variable "jira_email" {
  description = "Jira user email for API authentication"
  type        = string
  sensitive   = true
}

variable "jira_api_token" {
  description = "Jira API token for authentication"
  type        = string
  sensitive   = true
}

variable "jira_connection_arn" {
  description = "ARN of the Jira EventBridge connection"
  type        = string
}

variable "jira_base_url" {
  description = "Jira base URL"
  type        = string
}

variable "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}



variable "supported_file_types" {
  description = "Supported file types"
  type        = string
  default     = "pdf,docx"
}

variable "max_file_size_mb" {
  description = "Maximum file size in MB"
  type        = number
  default     = 50
}

variable "max_retries" {
  description = "Maximum retry attempts"
  type        = number
  default     = 3
}

variable "download_timeout_seconds" {
  description = "Timeout for downloading files from Jira"
  type        = number
  default     = 120
}

variable "s3_upload_prefix" {
  description = "S3 prefix for uploaded files"
  type        = string
  default     = "uploads"
}

variable "max_webhook_body_size_mb" {
  description = "Maximum webhook body size in MB"
  type        = number
  default     = 10
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}