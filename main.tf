# S3 Bucket for storing documents
module "s3_bucket" {
  source                     = "./modules/s3_bucket"
  bucket_name                = var.bucket_name
  environment                = var.environment
  enable_versioning          = var.enable_versioning
  document_retention_days    = var.document_retention_days
  enable_intelligent_tiering = var.enable_intelligent_tiering
  tags                      = var.tags
}

# Lambda webhook function
module "lambda_webhook" {
  source              = "./modules/lambda_webhook"
  function_name       = var.function_name
  environment         = var.environment
  runtime             = var.runtime
  memory_size         = var.memory_size
  timeout             = var.timeout
  s3_bucket_name      = module.s3_bucket.bucket_name
  state_machine_arn   = module.step_functions.state_machine_arn
  jira_api_token      = var.jira_api_token
  jira_email          = var.jira_email
  jira_base_url       = var.jira_base_url
  jira_connection_arn = var.jira_connection_arn
  jira_webhook_secret = var.jira_webhook_secret
  tags                = var.tags
}

# IAM roles for Step Functions
module "iam" {
  source      = "./modules/iam"
  environment = var.environment
  lambda_arns = [module.lambda_webhook.function_arn]
  tags        = var.tags
}

# Step Functions workflow
module "step_functions" {
  source                  = "./modules/step_functions"
  state_machine_name      = "TechContractAnalysisWorkflow-${var.environment}"
  state_definition_file   = var.state_definition_file
  include_execution_data  = false
  log_level              = "ERROR"
  log_retention_days     = 14
  environment            = var.environment
  lambda_invocation_arns = [module.lambda_webhook.function_arn]
  s3_read_arns          = ["${module.s3_bucket.bucket_arn}/*"]
  tags                  = var.tags
}

# API Gateway
module "api_gateway" {
  source      = "./modules/api_gateway"
  env         = var.environment
  lambda_arn  = module.lambda_webhook.function_arn
  lambda_name = module.lambda_webhook.function_name
  region      = var.region
}

# WAF protection for API
module "waf" {
  source     = "./modules/waf"
  env        = var.environment
  rate_limit = var.waf_rate_limit
  api_id     = module.api_gateway.api_id
  stage_name = module.api_gateway.stage
  api_type   = "HTTP"
  region     = var.region
  tags       = var.tags
}

# Outputs
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "step_function_arn" {
  description = "Step Function state machine ARN"
  value       = module.step_functions.state_machine_arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda_webhook.function_name
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3_bucket.bucket_name
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = module.waf.web_acl_arn
}
