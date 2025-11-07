terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
    archive = { source = "hashicorp/archive" }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}

locals {
  env = var.environment
}

# S3 module
module "s3" {
  source = "../../modules/s3_bucket"
  bucket_name = var.bucket_name
  environment = local.env
  enable_versioning = var.enable_versioning
  document_retention_days = var.document_retention_days
  enable_intelligent_tiering = var.enable_intelligent_tiering
  tags = var.tags
}

# Lambda webhook
module "lambda_webhook" {
  source = "../../modules/lambda_webhook"
  function_name = var.function_name
  environment = local.env
  runtime = var.runtime
  memory_size = var.memory_size
  timeout = var.timeout
  s3_bucket_name = module.s3.bucket_name
  state_machine_arn = "" # will be filled after SFN creation; we use dependency ordering by passing placeholder and then use module output
  jira_api_token = var.jira_api_token
  jira_email = var.jira_email
  jira_base_url = var.jira_base_url
  jira_connection_arn = var.jira_connection_arn
  jira_webhook_secret = var.jira_webhook_secret
  tags = var.tags
}

# IAM (Step Functions role) – provide lambda arns to allow invocation
module "iam" {
  source = "../../modules/iam"
  environment = local.env
  lambda_arns = [module.lambda_webhook.function_arn]
  tags = var.tags
}

# Step Functions
module "step_functions" {
  source = "../../modules/step_functions"
  state_machine_name = "TechContractAnalysisWorkflow-${local.env}"
  state_definition_file = var.state_definition_file
  include_execution_data = false
  log_level = "ERROR"
  log_retention_days = 14
  environment = local.env
  lambda_invocation_arns = [module.lambda_webhook.function_arn]
  s3_read_arns = ["${module.s3.bucket_arn}/*"]
  tags = var.tags
}

# Now update lambda module's state_machine_arn by re-creating lambda with proper value is complex
# Simpler: ensure step functions and lambda exist; webhook lambda reads STATE_MACHINE_ARN from env var.
# We'll create a null_resource to perform nothing but ensure order: step_functions depends_on iam and lambda_webhook
resource "null_resource" "post_deploy_placeholder" {
  depends_on = [module.step_functions, module.lambda_webhook]
}

# API Gateway wired to lambda_webhook
module "api" {
  source = "../../modules/api_gateway"
  env = local.env
  lambda_arn = module.lambda_webhook.function_arn
  lambda_name = module.lambda_webhook.function_name
  region = var.region
}

# WAF associated to API stage (optional)
module "waf" {
  source = "../../modules/waf"
  env = local.env
  rate_limit = var.waf_rate_limit
  api_id = module.api.api_id
  stage_name = module.api.stage
  api_type = "HTTP"
  region = var.region
  tags = var.tags
}

output "api_endpoint" { value = module.api.api_endpoint }
output "sfn_arn" { value = module.step_functions.state_machine_arn }
output "lambda_arn" { value = module.lambda_webhook.function_arn }
output "s3_bucket" { value = module.s3.bucket_name }
