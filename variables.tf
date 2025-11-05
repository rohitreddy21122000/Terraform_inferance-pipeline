variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (qa/uat/prod)"
  type        = string
  default     = "qa"
}

variable "use_remote_backend" {
  description = "Toggle to use remote backend (S3/DynamoDB). See README for setup."
  type        = bool
  default     = false
}
