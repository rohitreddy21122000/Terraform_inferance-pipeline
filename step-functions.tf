# Step Functions - Beginner Example
# This creates a simple state machine that waits and then succeeds

# IAM role for Step Functions
resource "aws_iam_role" "step_functions_role" {
  name = "${var.environment}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-step-functions-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Basic policy for Step Functions to write logs
resource "aws_iam_role_policy" "step_functions_policy" {
  name = "${var.environment}-step-functions-policy"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "step_functions_logs" {
  name              = "/aws/stepfunctions/${var.environment}-simple-workflow"
  retention_in_days = 7

  tags = {
    Name        = "${var.environment}-stepfunctions-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Step Functions State Machine
resource "aws_sfn_state_machine" "simple_workflow" {
  name     = "${var.environment}-simple-workflow"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "A simple workflow that demonstrates Step Functions"
    StartAt = "WaitState"
    States = {
      WaitState = {
        Type    = "Wait"
        Seconds = 10
        Next    = "SuccessState"
      }
      SuccessState = {
        Type = "Pass"
        Result = {
          message = "Workflow completed successfully!"
          timestamp = "$.timestamp"
        }
        End = true
      }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions_logs.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tags = {
    Name        = "${var.environment}-simple-workflow"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
