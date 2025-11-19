# S3 Module Outputs
output "main_bucket_id" {
  description = "ID of the main S3 bucket"
  value       = module.s3_bucket.main_bucket_id
}

output "log_bucket_id" {
  description = "ID of the S3 logging bucket"
  value       = module.s3_bucket.log_bucket_id
}

output "folder_name" {
  description = "Name of the folder created in the main bucket"
  value       = module.s3_bucket.folder_name
}
