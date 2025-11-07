# Use local backend for development/testing
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# For production, uncomment and configure the S3 backend below:
# terraform {
#   backend "s3" {
#     bucket         = "your-tf-state-bucket"
#     key            = "terraform/state.tfstate"
#     region         = "us-east-1"
#     use_lockfile   = true
#     encrypt        = true
#   }
# }