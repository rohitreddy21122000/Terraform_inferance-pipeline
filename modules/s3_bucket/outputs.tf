output "bucket_name" { value = aws_s3_bucket.main.id }
output "access_logs_bucket" { value = aws_s3_bucket.access_logs.id }
output "bucket_arn" { value = aws_s3_bucket.main.arn }
