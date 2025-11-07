module "lambda" {
  source = "./modules/lambda"
  name   = "tech-extract-text"
  env    = var.environment
}

module "iam" {
  source = "./modules/iam"
  env = var.environment
  lambda_arns = [module.lambda.lambda_arn]
}

module "step_function" {
  source = "./modules/step_function"
  env = var.environment
  role_arn = module.iam.sfn_role_arn
  lambda_arn = module.lambda.lambda_arn
}

module "api_gateway" {
  source = "./modules/api_gateway"
  env = var.environment
  step_function_arn = module.step_function.state_machine_arn
  region = var.region
}

module "waf" {
  source = "./modules/waf"
  env = var.environment
  api_gateway_arn = module.api_gateway.api_gateway_arn
}

# Outputs
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value = module.api_gateway.api_endpoint
}

output "step_function_arn" {
  description = "Step Function state machine ARN"
  value = module.step_function.state_machine_arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value = module.lambda.lambda_name
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value = module.waf.web_acl_arn
}

module "s3_bucket" {
  source  = "./modules/s3_bucket"
  bucket_name = var.bucket_name
  enable_versioning = true
  document_retention_days = 90
  enable_intelligent_tiering = false
  tags = var.tags
}

module "lambda_webhook" {
  source              = "./modules/lambda_webhook"
  function_name       = "tech-webhooklambda"
  jira_email          = var.jira_email
  jira_api_token      = var.jira_api_token
  jira_base_url       = var.jira_base_url
  jira_webhook_secret = var.jira_webhook_secret
  jira_connection_arn = var.jira_connection_arn
  state_machine_arn   = module.step_functions.state_machine_arn
  s3_bucket_name      = module.s3_bucket.bucket_name
  tags                = var.tags
}

module "step_functions" {
  source               = "./modules/step_functions"
  state_machine_name   = "TechContractAnalysisWorkflow"
  document_processor_arn = var.document_processor_arn
  jira_connection_arn  = var.jira_connection_arn
  s3_bucket_name       = module.s3_bucket.bucket_name
  log_level            = "ERROR"
  include_execution_data = false
  tags                 = var.tags
}
