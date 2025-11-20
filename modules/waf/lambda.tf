# Archive Lambda Layer with dependencies
data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_layer"
  output_path = "${path.module}/tech-extract-layer.zip"
}

# Lambda Layer for Extract Text Function
resource "aws_lambda_layer_version" "extract_layer" {
  layer_name          = "${var.project_name}-extract-layer"
  description         = "Lambda layer with dependencies for text extraction"
  compatible_runtimes = ["python3.11"]
  
  filename         = data.archive_file.lambda_layer.output_path
  source_code_hash = data.archive_file.lambda_layer.output_base64sha256
}

# Archive Webhook Lambda Function
data "archive_file" "webhook_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/lambda1"
  output_path = "${path.module}/lambda1.zip"
}

# Lambda Function 1: Webhook Handler
resource "aws_lambda_function" "webhook_handler" {
  function_name = var.webhook_function_name
  description   = "Webhook handler for processing incoming requests"
  role          = aws_iam_role.webhook_lambda_role.arn
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  
  filename         = data.archive_file.webhook_lambda.output_path
  source_code_hash = data.archive_file.webhook_lambda.output_base64sha256
  
  memory_size      = 512
  timeout          = 90
  architectures    = ["arm64"]
  
  ephemeral_storage {
    size = 1024
  }

  environment {
    variables = {
      CONTRACTS_BUCKET = var.contracts_bucket_name
      SECRET_ARN       = var.webhook_secret_arn
      STEP_FUNCTION_ARN = var.step_function_arn
    }
  }

  tags = var.tags
}

# CloudWatch Log Group for Webhook Lambda
resource "aws_cloudwatch_log_group" "webhook_lambda_logs" {
  name              = "/aws/lambda/${var.webhook_function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# Archive Extract Text Lambda Function
data "archive_file" "extract_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/lambda2"
  output_path = "${path.module}/lambda2.zip"
}

# Lambda Function 2: Extract Text
resource "aws_lambda_function" "extract_text" {
  function_name = var.extract_function_name
  description   = "Extract text from documents using Bedrock"
  role          = aws_iam_role.extract_lambda_role.arn
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  
  filename         = data.archive_file.extract_lambda.output_path
  source_code_hash = data.archive_file.extract_lambda.output_base64sha256
  
  memory_size      = 512
  timeout          = 120
  architectures    = ["arm64"]
  
  ephemeral_storage {
    size = 1024
  }

  layers = [aws_lambda_layer_version.extract_layer.arn]

  environment {
    variables = {
      CONTRACTS_BUCKET = var.contracts_bucket_name
    }
  }

  tags = var.tags
}

# CloudWatch Log Group for Extract Lambda
resource "aws_cloudwatch_log_group" "extract_lambda_logs" {
  name              = "/aws/lambda/${var.extract_function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}
