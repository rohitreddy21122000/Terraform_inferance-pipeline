terraform {
  backend "s3" {
    bucket         = "your-tf-state-bucket"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}


#Later, you can toggle to local backend by commenting this and adding:

# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }