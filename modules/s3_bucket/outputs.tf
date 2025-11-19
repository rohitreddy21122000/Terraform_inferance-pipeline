output "main_bucket_id" {
  description = "ID of the main S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "log_bucket_id" {
  description = "ID of the S3 logging bucket"
  value       = aws_s3_bucket.log_bucket.id
}

output "folder_name" {
  description = "Name of the folder created in the main bucket"
  value       = var.folder_name
}
