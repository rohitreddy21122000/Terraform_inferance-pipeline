module "lambda" {
  source = "./modules/lambda"
}

module "step_function" {
  source = "./modules/step_function"
  lambda_arn = module.lambda.lambda_arn
}

module "api_gateway" {
  source = "./modules/api_gateway"
  step_function_arn = module.step_function.state_machine_arn
}

module "waf" {
  source = "./modules/waf"
  api_gateway_arn = module.api_gateway.api_gateway_arn
}

module "iam" {
  source = "./modules/iam"
}