# Call the S3 bucket module
module "s3_buckets" {
  source = "./modules/s3_bucket"

  main_bucket_name = "my-main-app-bucket-rohit-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  log_bucket_name  = "my-app-logs-bucket-rohit-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  
  folder_name        = "my-application-folder/"
  lifecycle_rule_name = "expire-all-objects-rule"
  expiration_days    = 90
  
  versioning_enabled      = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  log_prefix = "access-logs/"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
