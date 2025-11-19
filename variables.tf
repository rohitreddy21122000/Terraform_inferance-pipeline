# AWS Region
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

# S3 Bucket Name
variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

# Environment
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}
