variable "main_bucket_name" {
  description = "Name of the main S3 bucket"
  type        = string
  default     = "my-main-app-bucket-12345"
}

variable "log_bucket_name" {
  description = "Name of the S3 bucket for storing access logs"
  type        = string
  default     = "my-app-logs-bucket-12345"
}

variable "folder_name" {
  description = "Name of the folder to create in the main bucket"
  type        = string
  default     = "my-application-folder"
}

variable "lifecycle_rule_name" {
  description = "Name of the lifecycle rule"
  type        = string
  default     = "expire-all-objects-rule"
}

variable "expiration_days" {
  description = "Number of days after which objects will expire"
  type        = number
  default     = 90
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# EventBridge Connection Variables
variable "eventbridge_username" {
  description = "Username for EventBridge connection basic authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "eventbridge_password" {
  description = "Password for EventBridge connection basic authentication"
  type        = string
  sensitive   = true
  default     = ""
}
