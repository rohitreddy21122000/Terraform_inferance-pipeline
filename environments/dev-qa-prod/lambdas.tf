# Lambda Functions

# ===== Webhook Lambda =====

# Package Lambda function code
data "archive_file" "webhook_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_webhook.zip"
  
  source_dir = "${path.root}/../../../src/tech-webhooklambda"
}

# IAM role for Webhook Lambda
resource "aws_iam_role" "webhook_lambda_role" {
  name = "tech-webhooklambdarole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Basic execution role
resource "aws_iam_role_policy_attachment" "webhook_lambda_basic_execution" {
  role       = aws_iam_role.webhook_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for Webhook Lambda
resource "aws_iam_role_policy" "webhook_lambda_policy" {
  name = "tech-webhooklambdapolicy"
  role = aws_iam_role.webhook_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowS3Upload"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::pfj-legal-tech-contracts-bucket/uploads/*"
      },
      {
        Sid = "AllowSFNStartExecution"
        Effect = "Allow"
        Action = "states:StartExecution"
        Resource = "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:TechContractAnalysisWorkflow"
      },
      {
        Sid = "AllowLogWriting"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/tech-webhooklambda:*"
      }
    ]
  })
}

# CloudWatch Log Group for Webhook Lambda
resource "aws_cloudwatch_log_group" "webhook_lambda_logs" {
  name              = "/aws/lambda/tech-webhooklambda"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# Webhook Lambda function
resource "aws_lambda_function" "webhook_handler" {
  function_name    = "tech-webhooklambda"
  role            = aws_iam_role.webhook_lambda_role.arn
  filename        = data.archive_file.webhook_lambda_zip.output_path
  source_code_hash = data.archive_file.webhook_lambda_zip.output_base64sha256

  runtime       = "python3.13"
  handler       = "lambda_function.lambda_handler"
  architectures = ["x86_64"]
  memory_size   = 512
  timeout       = 90

  # Use created layer or existing layer ARNs
  layers = local.webhook_lambda_layers

  environment {
    variables = {
      JIRA_API_TOKEN     = var.jira_api_token
      JIRA_BASE_URL      = var.jira_base_url
      JIRA_CONNECTION_ARN = aws_cloudwatch_event_connection.jira_connection.arn
      JIRA_EMAIL         = var.jira_email
      JIRA_WEBHOOK_SECRET = var.jira_webhook_secret
      S3_BUCKET_NAME     = "pfj-legal-tech-contracts-bucket"
      STATE_MACHINE_ARN  = aws_sfn_state_machine.contract_analysis.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.webhook_lambda_basic_execution,
    aws_cloudwatch_log_group.webhook_lambda_logs,
    aws_sfn_state_machine.contract_analysis,
    aws_lambda_layer_version.document_processing_layer
  ]

  tags = local.common_tags
}

# Webhook Lambda event invoke config
resource "aws_lambda_function_event_invoke_config" "webhook_handler_config" {
  function_name                = aws_lambda_function.webhook_handler.function_name
  maximum_event_age_in_seconds = 21600
  maximum_retry_attempts       = 2
}

# ===== ExtractText Lambda =====

# Package Lambda function code
data "archive_file" "extracttext_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_extracttext.zip"
  
  source_dir = "${path.root}/../../../src/tech-ExtractText"
}

# IAM role for ExtractText Lambda
resource "aws_iam_role" "extracttext_lambda_role" {
  name = "tech-extracttextlambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Custom policy for ExtractText Lambda
resource "aws_iam_role_policy" "extracttext_lambda_policy" {
  name = "tech-extracttext-policy"
  role = aws_iam_role.extracttext_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowReadFromUploads"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::pfj-legal-tech-contracts-bucket/uploads/*"
      },
      {
        Sid = "AllowWriteToExtracted"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::pfj-legal-tech-contracts-bucket/extracted/*"
      },
      {
        Sid = "AllowBedrockAccess"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:*:${data.aws_caller_identity.current.account_id}:inference-profile/*"
        ]
      },
      {
        Sid = "AllowLogging"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/tech-ExtractText:*"
      }
    ]
  })
}

# CloudWatch Log Group for ExtractText Lambda
resource "aws_cloudwatch_log_group" "extracttext_lambda_logs" {
  name              = "/aws/lambda/tech-ExtractText"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# ExtractText Lambda function
resource "aws_lambda_function" "document_processor" {
  function_name    = "tech-ExtractText"
  role            = aws_iam_role.extracttext_lambda_role.arn
  filename        = data.archive_file.extracttext_lambda_zip.output_path
  source_code_hash = data.archive_file.extracttext_lambda_zip.output_base64sha256

  runtime       = "python3.13"
  handler       = "lambda_function.lambda_handler"
  architectures = ["x86_64"]
  memory_size   = 512
  timeout       = 180

  # Use created layer or existing layer ARNs
  layers = local.extracttext_lambda_layers

  environment {
    variables = {
      S3_BUCKET_NAME = "pfj-legal-tech-contracts-bucket"
    }
  }

  depends_on = [
    aws_iam_role_policy.extracttext_lambda_policy,
    aws_cloudwatch_log_group.extracttext_lambda_logs,
    aws_lambda_layer_version.document_processing_layer
  ]

  tags = local.common_tags
}

# ExtractText Lambda event invoke config
resource "aws_lambda_function_event_invoke_config" "document_processor_config" {
  function_name                = aws_lambda_function.document_processor.function_name
  maximum_event_age_in_seconds = 21600
  maximum_retry_attempts       = 2
}