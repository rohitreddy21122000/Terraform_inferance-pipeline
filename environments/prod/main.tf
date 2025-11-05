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
  lambda_arn = module.lambda.lambda_arn
  lambda_name = module.lambda.lambda_name
  region = var.region
}

module "waf" {
  source = "../../modules/waf"
  env = local.env
  rate_limit = 2000
}

output "api_endpoint" {
  value = module.api_gateway.api_endpoint
}

output "sfn_arn" {
  value = module.step_function.state_machine_arn
}
