data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/${var.function_name}_${var.environment}.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_custom" {
  name = "${var.function_name}-policy-${var.environment}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowS3Upload",
        Effect = "Allow",
        Action = ["s3:PutObject","s3:PutObjectAcl"],
        Resource = ["arn:aws:s3:::${var.s3_bucket_name}/uploads/*"]
      },
      {
        Sid = "AllowSFNStartExecution",
        Effect = "Allow",
        Action = ["states:StartExecution"],
        Resource = [var.state_machine_arn]
      },
      {
        Sid = "AllowLogWriting",
        Effect = "Allow",
        Action = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"],
        Resource = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}:*"]
      },
      {
        Sid = "AllowSecretsAndEventsIfProvided",
        Effect = "Allow",
        Action = ["secretsmanager:GetSecretValue","secretsmanager:DescribeSecret","events:RetrieveConnectionCredentials"],
        Resource = ["*"]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_lambda_function" "webhook" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  runtime          = var.runtime
  handler          = "lambda_function.lambda_handler"
  memory_size      = var.memory_size
  timeout          = var.timeout
  architectures    = ["x86_64"]
  environment {
    variables = {
      JIRA_API_TOKEN     = var.jira_api_token
      JIRA_BASE_URL      = var.jira_base_url
      JIRA_CONNECTION_ARN = var.jira_connection_arn
      JIRA_EMAIL         = var.jira_email
      JIRA_WEBHOOK_SECRET = var.jira_webhook_secret
      S3_BUCKET_NAME     = var.s3_bucket_name
      STATE_MACHINE_ARN  = var.state_machine_arn
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  dynamic "layers" {
    for_each = var.layer_arns
    content {
      layers = [layers.value]
    }
  }
  depends_on = [aws_iam_role_policy.lambda_custom, aws_cloudwatch_log_group.lambda_logs]
}

resource "aws_lambda_function_event_invoke_config" "webhook_handler_config" {
  function_name                 = aws_lambda_function.webhook.function_name
  maximum_event_age_in_seconds  = 21600
  maximum_retry_attempts        = 2
}
