# IAM Role for Lambda Function 1 (Webhook Handler)
resource "aws_iam_role" "webhook_lambda_role" {
  name = "${var.project_name}-webhook-lambda-role"

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

  tags = var.tags
}

# IAM Policy for Lambda Function 1
resource "aws_iam_policy" "webhook_lambda_policy" {
  name        = "${var.project_name}-webhook-lambda-policy"
  description = "Policy for webhook Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Upload"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${var.contracts_bucket_arn}/contracts/*"
      },
      {
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        Resource = var.webhook_secret_arn
      },
      {
        Sid    = "AllowSFNStartExecution"
        Effect = "Allow"
        Action = "states:StartExecution"
        Resource = var.step_function_arn
      },
      {
        Sid    = "AllowLogWriting"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.webhook_function_name}:*"
      }
    ]
  })

  tags = var.tags
}

# Attach policy to webhook Lambda role
resource "aws_iam_role_policy_attachment" "webhook_lambda_policy_attachment" {
  role       = aws_iam_role.webhook_lambda_role.name
  policy_arn = aws_iam_policy.webhook_lambda_policy.arn
}

# IAM Role for Lambda Function 2 (Extract Text)
resource "aws_iam_role" "extract_lambda_role" {
  name = "${var.project_name}-extract-lambda-role"

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

  tags = var.tags
}

# IAM Policy for Lambda Function 2
resource "aws_iam_policy" "extract_lambda_policy" {
  name        = "${var.project_name}-extract-lambda-policy"
  description = "Policy for extract text Lambda function with Bedrock access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadFromUploads"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${var.contracts_bucket_arn}/contracts/*"
      },
      {
        Sid    = "AllowBedrockAccess"
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
        Sid    = "AllowLogging"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.extract_function_name}:*"
      }
    ]
  })

  tags = var.tags
}

# Attach policy to extract Lambda role
resource "aws_iam_role_policy_attachment" "extract_lambda_policy_attachment" {
  role       = aws_iam_role.extract_lambda_role.name
  policy_arn = aws_iam_policy.extract_lambda_policy.arn
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
