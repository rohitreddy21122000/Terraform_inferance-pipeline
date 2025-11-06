terraform {
  required_providers {
    aws     = { source = "hashicorp/aws" }
    archive = { source = "hashicorp/archive" }
  }
}

provider "aws" {
  region = var.region
}

locals {
  env = var.environment
  name_prefix = "tech-contract"
}

module "lambda" {
  source = "../../modules/lambda"
  name   = "tech-extract-text"
  env    = local.env
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory_size
}

module "iam" {
  source = "../../modules/iam"
  env = local.env
  lambda_arns = [module.lambda.lambda_arn]
}

module "step_function" {
  source = "../../modules/step_function"
  env = local.env
  role_arn = module.iam.sfn_role_arn
  lambda_arn = module.lambda.lambda_arn
}

module "api_gateway" {
  source = "../../modules/api_gateway"
  env = local.env
  step_function_arn = module.step_function.state_machine_arn
  region = var.region
}

module "waf" {
  source = "../../modules/waf"
  env = local.env
  rate_limit = var.waf_rate_limit
  api_gateway_arn = module.api_gateway.api_gateway_arn
}

output "api_endpoint" {
  value = module.api_gateway.api_endpoint
}

output "sfn_arn" {
  value = module.step_function.state_machine_arn
}
