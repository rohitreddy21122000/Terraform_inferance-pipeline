variable "bucket_name" {
  description = "Name of the main S3 bucket"
  type        = string
}

variable "log_bucket_name" {
  description = "Name of the S3 bucket for access logs"
  type        = string
}

variable "folder_name" {
  description = "Name of the folder to create inside the main bucket"
  type        = string
  default     = "contracts/"
}

variable "lifecycle_rule_name" {
  description = "Name of the lifecycle rule for the main bucket"
  type        = string
  default     = "dummy-expiration-rule"
}

variable "expiration_days" {
  description = "Number of days after which objects expire in the main bucket"
  type        = number
  default     = 90
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}
