S3 output
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_bucket_regional_domain_name
}
variable
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "document_retention_days" {
  description = "Number of days to retain documents"
  type        = number
  default     = 90
}

variable "enable_intelligent_tiering" {
  description = "Enable S3 Intelligent Tiering"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
main
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create access logs bucket for server access logging
resource "aws_s3_bucket" "access_logs" {
  bucket = "${var.bucket_name}-access-logs"
  
  tags = merge(var.tags, {
    Name = "${var.bucket_name}-access-logs"
    Purpose = "Access Logs"
  })
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = var.bucket_name

  # Security settings
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Versioning
  versioning = {
    enabled = var.enable_versioning
  }

  # Server-side encryption (matches your console: SSE-S3 with AES256)
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
        bucket_key_enabled = true
      }
    }
  }

  # Lifecycle rules (matches your console: 90-day deletion rule)
  lifecycle_rule = [
    {
      id     = "90-day-deletion"
      status = "Enabled"
      
      expiration = {
        days = var.document_retention_days
      }
      
      noncurrent_version_expiration = {
        days = 30
      }
    }
  ]

  # Intelligent Tiering (for production environments)
  intelligent_tiering = var.enable_intelligent_tiering ? {
    general = {
      status = "Enabled"
      tiering = {
        ARCHIVE_ACCESS = {
          days = 90
        }
        DEEP_ARCHIVE_ACCESS = {
          days = 180
        }
      }
    }
  } : {}

  # Server access logging (matches your console configuration)
  logging = {
    target_bucket = aws_s3_bucket.access_logs.id
    target_prefix = "access-logs/"
  }

  tags = var.tags
}

# Create folder structure - only the folders actually used by the application
resource "aws_s3_object" "folders" {
  for_each = toset([
    "uploads/",
    "extracted/"
  ])
  
  bucket  = module.s3_bucket.s3_bucket_id
  key     = each.value
  content = ""
  
  tags = var.tags
}

# Bucket notification for Lambda triggers (if needed)
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.s3_bucket.s3_bucket_id

  # Add Lambda function notifications here if needed
  # lambda_function {
  #   lambda_function_arn = var.lambda_function_arn
  #   events              = ["s3:ObjectCreated:*"]
  #   filter_prefix       = "uploads/"
  # }
}