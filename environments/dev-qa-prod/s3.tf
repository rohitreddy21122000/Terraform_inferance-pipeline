# S3 Bucket for document storage

# Create access logs bucket for server access logging
resource "aws_s3_bucket" "access_logs" {
  bucket = "pfj-legal-tech-contracts-bucket-access-logs"
  
  tags = merge(local.common_tags, {
    Name = "pfj-legal-tech-contracts-bucket-access-logs"
    Purpose = "Access Logs"
  })
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "pfj-legal-tech-contracts-bucket"

  # Security settings
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Versioning
  versioning = {
    enabled = true
  }

  # Server-side encryption (SSE-S3 with AES256)
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
        bucket_key_enabled = true
      }
    }
  }

  # Lifecycle configuration
  lifecycle_configuration = {
    rule = [
      {
        id     = "90-day-deletion"
        status = "Enabled"
        
        filter = {}
        
        expiration = {
          days = var.environment == "prod" ? 2555 : (var.environment == "qa" ? 365 : 90)
        }
        
        noncurrent_version_expiration = {
          noncurrent_days = 30
        }
      }
    ]
  }

  # Intelligent Tiering (for production environments)
  dynamic "intelligent_tiering_configuration" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      name   = "entire-bucket"
      status = "Enabled"
      
      filter {}
    }
  }

  # Server access logging
  logging = {
    target_bucket = aws_s3_bucket.access_logs.id
    target_prefix = "access-logs/"
  }

  tags = local.common_tags
}

# Create folder structure
resource "aws_s3_object" "folders" {
  for_each = toset([
    "uploads/",
    "extracted/"
  ])
  
  bucket  = module.s3_bucket.s3_bucket_id
  key     = each.value
  content = ""
  
  tags = local.common_tags
}

# Bucket notification for Lambda triggers
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.s3_bucket.s3_bucket_id
}