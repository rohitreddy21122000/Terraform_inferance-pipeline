stepfunction
main
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM role for Step Functions
resource "aws_iam_role" "step_functions_role" {
  name = "TechAnalysisWorkflow-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Bedrock access is handled by the Lambda function, not Step Functions

# IAM policy for Step Functions - Exact match to your provided policy
resource "aws_iam_role_policy" "step_functions_main_policy" {
  name = "TechAnalysisWorkflow-policy"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowLambdaInvocation"
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = "arn:aws:lambda:us-east-1:021891594383:function:tech-ExtractText"
      },
      {
        Sid = "AllowS3Read"
        Effect = "Allow"
        Action = "s3:GetObject"
        Resource = "arn:aws:s3:::pfj-legal-tech-contracts-bucket/*"
      },
      {
        Sid = "AllowNativeHTTPInvokeToJira"
        Effect = "Allow"
        Action = "states:InvokeHTTPEndpoint"
        Resource = "*"
        Condition = {
          StringEquals = {
            "states:HTTPMethod" = "POST"
          }
          StringLike = {
            "states:HTTPEndpoint" = "https://pilotflyingj-sandbox-951.atlassian.net/*"
          }
        }
      },
      {
        Sid = "AllowConnectionAccess"
        Effect = "Allow"
        Action = "events:RetrieveConnectionCredentials"
        Resource = "arn:aws:events:us-east-1:021891594383:connection/Jira-Connection/*"
      },
      {
        Sid = "AllowSecretForConnection"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:021891594383:secret:events!connection/Jira-Connection/*"
      },
      {
        Sid = "AllowSFNLoggingDelivery"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:ListLogDeliveries"
        ]
        Resource = "arn:aws:logs:us-east-1:021891594383:log-group:/aws/vendedlogs/states/TechAnalysisWorkflow-Logs:*"
      },
      {
        Sid = "AllowSFNLogWriting"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:us-east-1:021891594383:log-group:/aws/vendedlogs/states/TechAnalysisWorkflow-Logs:*"
      }
    ]
  })
}



# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "step_functions_logs" {
  name              = "/aws/vendedlogs/states/TechAnalysisWorkflow-Logs"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# Step Functions State Machine
resource "aws_sfn_state_machine" "main" {
  name     = "TechContractAnalysisWorkflow"
  role_arn = aws_iam_role.step_functions_role.arn
  type     = "STANDARD"

  definition = file("${path.module}/state_machine_definition.json")

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions_logs.arn}:*"
    include_execution_data = var.include_execution_data
    level                  = var.log_level
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy.step_functions_main_policy,
    aws_cloudwatch_log_group.step_functions_logs
  ]
}
output
output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.main.name
}

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.main.arn
}

output "state_machine_status" {
  description = "Status of the Step Functions state machine"
  value       = aws_sfn_state_machine.main.status
}

output "role_arn" {
  description = "ARN of the Step Functions execution role"
  value       = aws_iam_role.step_functions_role.arn
}
variable
variable "state_machine_name" {
  description = "Name of the Step Functions state machine"
  type        = string
}

variable "document_processor_arn" {
  description = "ARN of the document processor Lambda function"
  type        = string
}

variable "jira_connection_arn" {
  description = "ARN of the Jira EventBridge connection"
  type        = string
}

variable "jira_connection_name" {
  description = "Name of the Jira EventBridge connection"
  type        = string
}

variable "jira_connection_name_pattern" {
  description = "Pattern for Jira connection names (for IAM policies)"
  type        = string
  default     = "Jira-Connection-*"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "log_level" {
  description = "Step Functions logging level"
  type        = string
  default     = "ERROR"
  
  validation {
    condition     = contains(["ALL", "ERROR", "FATAL", "OFF"], var.log_level)
    error_message = "Log level must be ALL, ERROR, FATAL, or OFF."
  }
}

variable "include_execution_data" {
  description = "Include execution data in logs"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for document storage"
  type        = string
}

variable "jira_base_url" {
  description = "Base URL for Jira instance"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

statemachine.json
{
  "Comment": "JIRA Document Processing - Lambda handles extraction and analysis",
  "StartAt": "ExtractAndAnalyze",
  "States": {
    "ExtractAndAnalyze": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "tech-ExtractText",
        "Payload.$": "$"
      },
      "ResultPath": "$.extractionResult",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "ResultPath": "$.errorInfo",
          "Next": "FormatErrorComment"
        }
      ],
      "Next": "ValidateExtraction"
    },
    "ValidateExtraction": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.extractionResult.Payload.success",
          "BooleanEquals": true,
          "Next": "FormatSuccessComment"
        }
      ],
      "Default": "FormatExtractionError"
    },
    "FormatSuccessComment": {
      "Type": "Pass",
      "Parameters": {
        "body": {
          "type": "doc",
          "version": 1,
          "content": [
            {
              "type": "heading",
              "attrs": {
                "level": 2
              },
              "content": [
                {
                  "type": "text",
                  "text": "📋 Data Governance Analysis Results"
                }
              ]
            },
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Document Analyzed: ",
                  "marks": [
                    {
                      "type": "strong"
                    }
                  ]
                },
                {
                  "type": "text",
                  "text.$": "$.extractionResult.Payload.originalFilename",
                  "marks": [
                    {
                      "type": "code"
                    }
                  ]
                }
              ]
            },
            {
              "type": "rule"
            },
            {
              "type": "expand",
              "attrs": {
                "title": "📊 Complete Analysis with Citations"
              },
              "content": [
                {
                  "type": "codeBlock",
                  "attrs": {
                    "language": "text"
                  },
                  "content": [
                    {
                      "type": "text",
                      "text.$": "$.extractionResult.Payload.analysisResult.Analysis"
                    }
                  ]
                }
              ]
            },
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "💡 ",
                  "marks": [
                    {
                      "type": "strong"
                    }
                  ]
                },
                {
                  "type": "text",
                  "text": "Expand the section above to view detailed analysis with page numbers and section references for all quotes."
                }
              ]
            }
          ]
        }
      },
      "ResultPath": "$.formattedComment",
      "Next": "PostCommentToJira"
    },
    "PostCommentToJira": {
      "Type": "Task",
      "Resource": "arn:aws:states:::http:invoke",
      "Parameters": {
        "ApiEndpoint.$": "States.Format('{}/rest/api/3/issue/{}/comment', $.jiraBaseUrl, $.issueKey)",
        "Method": "POST",
        "Headers": {
          "Content-Type": "application/json"
        },
        "Authentication": {
          "ConnectionArn.$": "$.jiraConnectionArn"
        },
        "RequestBody.$": "$.formattedComment"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "States.Http.StatusCode.429",
            "States.Http.StatusCode.502",
            "States.Http.StatusCode.503"
          ],
          "BackoffRate": 2,
          "IntervalSeconds": 1,
          "MaxAttempts": 3
        }
      ],
      "End": true
    },
    "FormatExtractionError": {
      "Type": "Pass",
      "Parameters": {
        "body": {
          "type": "doc",
          "version": 1,
          "content": [
            {
              "type": "heading",
              "attrs": {
                "level": 2
              },
              "content": [
                {
                  "type": "text",
                  "text": "⚠️ Document Processing Failed"
                }
              ]
            },
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Document: "
                },
                {
                  "type": "text",
                  "text.$": "$.extractionResult.Payload.filename",
                  "marks": [
                    {
                      "type": "code"
                    }
                  ]
                }
              ]
            },
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text.$": "$.extractionResult.Payload.error"
                }
              ]
            },
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "This may be due to:"
                }
              ]
            },
            {
              "type": "bulletList",
              "content": [
                {
                  "type": "listItem",
                  "content": [
                    {
                      "type": "paragraph",
                      "content": [
                        {
                          "type": "text",
                          "text": "Image-based PDF (scanned document)"
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "listItem",
                  "content": [
                    {
                      "type": "paragraph",
                      "content": [
                        {
                          "type": "text",
                          "text": "Corrupted or encrypted file"
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "listItem",
                  "content": [
                    {
                      "type": "paragraph",
                      "content": [
                        {
                          "type": "text",
                          "text": "Unsupported document format"
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Please upload a text-based PDF or DOCX file for analysis."
                }
              ]
            }
          ]
        }
      },
      "ResultPath": "$.errorComment",
      "Next": "PostErrorCommentToJira"
    },
    "FormatErrorComment": {
      "Type": "Pass",
      "Parameters": {
        "body": {
          "type": "doc",
          "version": 1,
          "content": [
            {
              "type": "heading",
              "attrs": {
                "level": 2
              },
              "content": [
                {
                  "type": "text",
                  "text": "⚠️ System Processing Error"
                }
              ]
            },
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Document: "
                },
                {
                  "type": "text",
                  "text.$": "$.filename",
                  "marks": [
                    {
                      "type": "code"
                    }
                  ]
                }
              ]
            },
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "A system error occurred during processing. Please check the logs."
                }
              ]
            },
            {
              "type": "codeBlock",
              "attrs": {
                "language": "json"
              },
              "content": [
                {
                  "type": "text",
                  "text.$": "States.JsonToString($.errorInfo)"
                }
              ]
            }
          ]
        }
      },
      "ResultPath": "$.errorComment",
      "Next": "PostErrorCommentToJira"
    },
    "PostErrorCommentToJira": {
      "Type": "Task",
      "Resource": "arn:aws:states:::http:invoke",
      "Parameters": {
        "ApiEndpoint.$": "States.Format('{}/rest/api/3/issue/{}/comment', $.jiraBaseUrl, $.issueKey)",
        "Method": "POST",
        "Headers": {
          "Content-Type": "application/json"
        },
        "Authentication": {
          "ConnectionArn.$": "$.jiraConnectionArn"
        },
        "RequestBody.$": "$.errorComment"
      },
      "End": true
    }
  }
}