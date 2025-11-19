###############################################
# S3 MAIN BUCKET
###############################################
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "aws/s3"
    }

    bucket_key_enabled = true
  }
}

###############################################
# CREATE FOLDER (Windows Safe)
###############################################
resource "aws_s3_object" "folder" {
  bucket = aws_s3_bucket.main.id
  key    = var.folder_name

  source = "${path.module}/empty.txt"
  etag   = filemd5("${path.module}/empty.txt")
}

###############################################
# LOGGING BUCKET
###############################################
resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket_name

  tags = {
    Name = var.log_bucket_name
  }
}

resource "aws_s3_bucket_ownership_controls" "log" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "log" {
  depends_on = [aws_s3_bucket_ownership_controls.log]

  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

###############################################
# ENABLE ACCESS LOGGING ON MAIN BUCKET
###############################################
resource "aws_s3_bucket_logging" "main" {
  bucket        = aws_s3_bucket.main.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "logs/"

  depends_on = [aws_s3_bucket.log_bucket] # Ensure log bucket exists first
}

###############################################
# LIFECYCLE RULE
###############################################
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = var.lifecycle_rule_name
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.expiration_days
    }
  }
}
