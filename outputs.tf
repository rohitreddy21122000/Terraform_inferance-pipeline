output "main_bucket_id" {
  description = "The ID of the main S3 bucket"
  value       = module.s3_buckets.main_bucket_id
}

output "main_bucket_arn" {
  description = "The ARN of the main S3 bucket"
  value       = module.s3_buckets.main_bucket_arn
}

output "main_bucket_name" {
  description = "The name of the main S3 bucket"
  value       = module.s3_buckets.main_bucket_name
}

output "log_bucket_id" {
  description = "The ID of the log S3 bucket"
  value       = module.s3_buckets.log_bucket_id
}

output "log_bucket_arn" {
  description = "The ARN of the log S3 bucket"
  value       = module.s3_buckets.log_bucket_arn
}

output "log_bucket_name" {
  description = "The name of the log S3 bucket"
  value       = module.s3_buckets.log_bucket_name
}

output "folder_key" {
  description = "The key of the created folder"
  value       = module.s3_buckets.folder_key
}
