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

# Call the WAF module with Lambda functions
module "waf" {
  source = "./modules/waf"

  project_name           = "tech"
  region                 = "us-east-1"
  webhook_function_name  = "techwebhookhandler"
  extract_function_name  = "tech-ExtractText"
  waf_name              = "tech-api-protection-waf"
  
  contracts_bucket_name  = "pfj-legal-tech-contracts-bucket"
  contracts_bucket_arn   = "arn:aws:s3:::pfj-legal-tech-contracts-bucket"
  webhook_secret_arn     = "arn:aws:secretsmanager:us-east-1:021891594383:secret:jirawebhookconnections-qazW4L"
  step_function_arn      = "arn:aws:states:us-east-1:021891594383:stateMachine:TechContractAnalysisWorkflow"
  
  log_retention_days             = 7
  enable_lambda_waf_association  = false
  
  tags = {
    Project     = "Tech"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
