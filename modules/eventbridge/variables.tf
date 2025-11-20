variable "connection_name" {
  description = "Name of the EventBridge connection"
  type        = string
  default     = "tech-webhookconnection"
}

variable "connection_username" {
  description = "Username for basic authentication (use environment variable or sensitive value)"
  type        = string
  sensitive   = true
}

variable "connection_password" {
  description = "Password for basic authentication (use environment variable or sensitive value)"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
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
