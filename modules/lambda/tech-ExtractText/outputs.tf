Tech-ExtractText
Output
output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.document_processor.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.document_processor.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.document_processor.invoke_arn
}

output "role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}
Variable
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
  default     = 512
}

variable "timeout" {
  description = "Timeout for Lambda function"
  type        = number
  default     = 300
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

# Bedrock model ID and readable ratios are now hardcoded in Lambda code
# No variables needed for these values

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

variable "lambda_layer_arn" {
  description = "ARN of the Lambda layer containing document processing dependencies"
  type        = string
  default     = null
}