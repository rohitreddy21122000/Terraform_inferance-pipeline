data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "sfn_role" {
  name = "${var.state_machine_name}-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# Inline policy: permit things SFN must do. Use variables to provide ARNs.
resource "aws_iam_role_policy" "sfn_policy" {
  name = "${var.state_machine_name}-policy-${var.environment}"
  role = aws_iam_role.sfn_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(
      [
        {
          Sid = "AllowLambdaInvocation",
          Effect = "Allow",
          Action = ["lambda:InvokeFunction"],
          Resource = var.lambda_invocation_arns
        },
        {
          Sid = "AllowS3Read",
          Effect = "Allow",
          Action = ["s3:GetObject"],
          Resource = var.s3_read_arns
        },
        {
          Sid = "AllowNativeHTTPInvokeToJira",
          Effect = "Allow",
          Action = ["states:InvokeHTTPEndpoint"],
          Resource = ["*"],
          Condition = {
            StringEquals = { "states:HTTPMethod" = "POST" },
            StringLike   = { "states:HTTPEndpoint" = "https://*"}
          }
        },
        {
          Sid = "AllowSFNLoggingDelivery",
          Effect = "Allow",
          Action = [
            "logs:CreateLogDelivery",
            "logs:GetLogDelivery",
            "logs:ListLogDeliveries"
          ],
          Resource = "*"
        },
        {
          Sid = "AllowSFNLogWriting",
          Effect = "Allow",
          Action = [
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
          ],
          Resource = "*"
        }
      ],
      []
    )
  })
}

resource "aws_cloudwatch_log_group" "sfn_logs" {
  name              = "/aws/vendedlogs/states/${var.state_machine_name}-Logs"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# State machine body file must exist in module folder or be passed in as content
data "local_file" "definition_file" {
  filename = "${path.module}/${var.state_definition_file}"
  # if not present, Terraform will error; supply correct file in module path
}

resource "aws_sfn_state_machine" "this" {
  name     = var.state_machine_name
  role_arn = aws_iam_role.sfn_role.arn
  type     = "STANDARD"
  definition = data.local_file.definition_file.content

  logging_configuration {
    log_destination = "${aws_cloudwatch_log_group.sfn_logs.arn}:*"
    include_execution_data = var.include_execution_data
    level = var.log_level
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy.sfn_policy, aws_cloudwatch_log_group.sfn_logs]
}
