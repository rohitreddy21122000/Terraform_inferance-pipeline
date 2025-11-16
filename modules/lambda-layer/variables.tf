# Variables for Lambda Layer module

variable "stack_name" {
  description = "Name of the stack for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "legal-real-estate"
}

# Lambda Layer for Document Processing Dependencies
# Contains pypdf, docx2txt, and other document processing libraries

resource "aws_lambda_layer_version" "document_processing" {
  filename                 = "${path.module}/../../../src/lambda-layer/document-processing-layer.zip"
  layer_name              = "${var.stack_name}-document-processing-layer"
  description             = "Document processing libraries with updated pypdf and docx2txt"
  compatible_runtimes     = ["python3.9", "python3.10", "python3.11"]
  compatible_architectures = ["x86_64"]

  source_code_hash = filebase64sha256("${path.module}/../../../src/lambda-layer/document-processing-layer.zip")
}

# Output the layer ARN for use in Lambda functions
output "layer_arn" {
  description = "ARN of the document processing Lambda layer"
  value       = aws_lambda_layer_version.document_processing.arn
}

output "layer_version" {
  description = "Version of the document processing Lambda layer"
  value       = aws_lambda_layer_version.document_processing.version
}