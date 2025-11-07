locals {
  access_logs_bucket = "${var.bucket_name}-access-logs"
  name_prefix = var.bucket_name
}

resource "aws_s3_bucket" "access_logs" {
  bucket = local.access_logs_bucket
  acl    = "private"

  tags = merge(var.tags, {
    Name    = "${local.name_prefix}-access-logs",
    Purpose = "Access Logs",
    Env     = var.environment
  })
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = var.enable_versioning
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
        bucket_key_enabled = true
      }
    }
  }

  lifecycle_rule {
    id      = "90-day-deletion"
    enabled = true

    expiration {
      days = var.document_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  logging {
    target_bucket = aws_s3_bucket.access_logs.id
    target_prefix = "access-logs/"
  }

  tags = merge(var.tags, { Env = var.environment })
}

# optional intelligent tiering config (simple placeholder)
resource "aws_s3_bucket_lifecycle_configuration" "intelligent_tiering" {
  count  = var.enable_intelligent_tiering ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "intelligent-tiering"
    status = "Enabled"
  }
}

# create minimal folder keys
resource "aws_s3_object" "folders" {
  for_each = toset(["uploads/", "extracted/"])

  bucket  = aws_s3_bucket.main.id
  key     = each.value
  content = ""
  tags    = merge(var.tags, { Env = var.environment })
}

# bucket public access block for primary bucket
resource "aws_s3_bucket_public_access_block" "main_block" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
