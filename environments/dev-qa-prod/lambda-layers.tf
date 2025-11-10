# Lambda Layers

# Package Lambda layer dependencies
data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_layer.zip"
  
  source_dir = "${path.root}/../../../src/lambda-layer"
}

# Lambda Layer for document processing dependencies
resource "aws_lambda_layer_version" "document_processing_layer" {
  filename            = data.archive_file.lambda_layer_zip.output_path
  layer_name          = "Tech-TextExtractlayer"
  source_code_hash    = data.archive_file.lambda_layer_zip.output_base64sha256
  
  compatible_runtimes = ["python3.13", "python3.12", "python3.11"]
  
  description = "Document processing dependencies: PyPDF2, docx2txt, requests"

  tags = local.common_tags
}

# Output the layer ARN for reference
output "lambda_layer_arn" {
  description = "ARN of the Lambda layer"
  value       = aws_lambda_layer_version.document_processing_layer.arn
}

output "lambda_layer_version" {
  description = "Version of the Lambda layer"
  value       = aws_lambda_layer_version.document_processing_layer.version
}