# Configure the AWS Provider
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}


module "s3_bucket" {
  source = "./modules/s3_bucket"

  bucket_name         = "dummy-main-bucket"
  log_bucket_name     = "dummy-log-bucket"
  folder_name         = "contracts/"
  lifecycle_rule_name = "dummy-expiration-rule"
  expiration_days     = 90
  aws_region          = var.aws_region

  providers = {
    aws = aws
  }
}