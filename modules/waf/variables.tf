variable "project_name" {
  description = "Name of the project used for resource naming"
  type        = string
  default     = "tech"
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "webhook_function_name" {
  description = "Name of the webhook Lambda function"
  type        = string
  default     = "techwebhookhandler"
}

variable "extract_function_name" {
  description = "Name of the extract text Lambda function"
  type        = string
  default     = "tech-ExtractText"
}

variable "waf_name" {
  description = "Name of the WAF Web ACL"
  type        = string
  default     = "tech-api-protection-waf"
}

variable "contracts_bucket_name" {
  description = "Name of the S3 bucket for contracts"
  type        = string
  default     = "pfj-legal-tech-contracts-bucket"
}

variable "contracts_bucket_arn" {
  description = "ARN of the S3 bucket for contracts"
  type        = string
  default     = "arn:aws:s3:::pfj-legal-tech-contracts-bucket"
}

variable "webhook_secret_arn" {
  description = "ARN of the Secrets Manager secret for webhook connections"
  type        = string
  default     = "arn:aws:secretsmanager:us-east-1:021891594383:secret:jirawebhookconnections-qazW4L"
}

variable "step_function_arn" {
  description = "ARN of the Step Functions state machine"
  type        = string
  default     = "arn:aws:states:us-east-1:021891594383:stateMachine:TechContractAnalysisWorkflow"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "enable_lambda_waf_association" {
  description = "Enable WAF association with Lambda functions"
  type        = bool
  default     = false
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
