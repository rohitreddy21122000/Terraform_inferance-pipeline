# Step Functions State Machine

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

  tags = local.common_tags
}

# IAM policy for Step Functions
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
        Resource = aws_lambda_function.document_processor.arn
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
            "states:HTTPEndpoint" = "${var.jira_base_url}/*"
          }
        }
      },
      {
        Sid = "AllowConnectionAccess"
        Effect = "Allow"
        Action = "events:RetrieveConnectionCredentials"
        Resource = "${aws_cloudwatch_event_connection.jira_connection.arn}*"
      },
      {
        Sid = "AllowSecretForConnection"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:events!connection/Jira-Connection/*"
      },
      {
        Sid = "AllowSFNLoggingDelivery"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:ListLogDeliveries"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vendedlogs/states/TechAnalysisWorkflow-Logs:*"
      },
      {
        Sid = "AllowSFNLogWriting"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vendedlogs/states/TechAnalysisWorkflow-Logs:*"
      }
    ]
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "step_functions_logs" {
  name              = "/aws/vendedlogs/states/TechAnalysisWorkflow-Logs"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# Step Functions State Machine
resource "aws_sfn_state_machine" "contract_analysis" {
  name     = "TechContractAnalysisWorkflow"
  role_arn = aws_iam_role.step_functions_role.arn
  type     = "STANDARD"

  definition = jsonencode({
    Comment = "JIRA Document Processing - Lambda handles extraction and analysis"
    StartAt = "ExtractAndAnalyze"
    States = {
      ExtractAndAnalyze = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.document_processor.function_name
          "Payload.$" = "$"
        }
        ResultPath = "$.extractionResult"
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath = "$.errorInfo"
            Next = "FormatErrorComment"
          }
        ]
        Next = "ValidateExtraction"
      }
      ValidateExtraction = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$.extractionResult.Payload.success"
            BooleanEquals = true
            Next = "FormatSuccessComment"
          }
        ]
        Default = "FormatExtractionError"
      }
      FormatSuccessComment = {
        Type = "Pass"
        Parameters = {
          body = {
            type = "doc"
            version = 1
            content = [
              {
                type = "heading"
                attrs = {
                  level = 2
                }
                content = [
                  {
                    type = "text"
                    text = "📋 Data Governance Analysis Results"
                  }
                ]
              },
              {
                type = "paragraph"
                content = [
                  {
                    type = "text"
                    text = "Document Analyzed: "
                    marks = [
                      {
                        type = "strong"
                      }
                    ]
                  },
                  {
                    type = "text"
                    "text.$" = "$.extractionResult.Payload.originalFilename"
                    marks = [
                      {
                        type = "code"
                      }
                    ]
                  }
                ]
              },
              {
                type = "rule"
              },
              {
                type = "expand"
                attrs = {
                  title = "📊 Complete Analysis with Citations"
                }
                content = [
                  {
                    type = "codeBlock"
                    attrs = {
                      language = "text"
                    }
                    content = [
                      {
                        type = "text"
                        "text.$" = "$.extractionResult.Payload.analysisResult.Analysis"
                      }
                    ]
                  }
                ]
              },
              {
                type = "paragraph"
                content = [
                  {
                    type = "text"
                    text = "💡 "
                    marks = [
                      {
                        type = "strong"
                      }
                    ]
                  },
                  {
                    type = "text"
                    text = "Expand the section above to view detailed analysis with page numbers and section references for all quotes."
                  }
                ]
              }
            ]
          }
        }
        ResultPath = "$.formattedComment"
        Next = "PostCommentToJira"
      }
      PostCommentToJira = {
        Type = "Task"
        Resource = "arn:aws:states:::http:invoke"
        Parameters = {
          "ApiEndpoint.$" = "States.Format('{}/rest/api/3/issue/{}/comment', $.jiraBaseUrl, $.issueKey)"
          Method = "POST"
          Headers = {
            "Content-Type" = "application/json"
          }
          Authentication = {
            "ConnectionArn.$" = "$.jiraConnectionArn"
          }
          "RequestBody.$" = "$.formattedComment"
        }
        Retry = [
          {
            ErrorEquals = [
              "States.Http.StatusCode.429",
              "States.Http.StatusCode.502",
              "States.Http.StatusCode.503"
            ]
            BackoffRate = 2
            IntervalSeconds = 1
            MaxAttempts = 3
          }
        ]
        End = true
      }
      FormatExtractionError = {
        Type = "Pass"
        Parameters = {
          body = {
            type = "doc"
            version = 1
            content = [
              {
                type = "heading"
                attrs = {
                  level = 2
                }
                content = [
                  {
                    type = "text"
                    text = "⚠️ Document Processing Failed"
                  }
                ]
              },
              {
                type = "paragraph"
                content = [
                  {
                    type = "text"
                    text = "Document: "
                  },
                  {
                    type = "text"
                    "text.$" = "$.extractionResult.Payload.filename"
                    marks = [
                      {
                        type = "code"
                      }
                    ]
                  }
                ]
              },
              {
                type = "paragraph"
                content = [
                  {
                    type = "text"
                    "text.$" = "$.extractionResult.Payload.error"
                  }
                ]
              },
              {
                type = "paragraph"
                content = [
                  {
                    type = "text"
                    text = "This may be due to:"
                  }
                ]
              },
              {
                type = "bulletList"
                content = [
                  {
                    type = "listItem"
                    content = [
                      {
                        type = "paragraph"
                        content = [
                          {
                            type = "text"
                            text = "Image-based PDF (scanned document)"
                          }
                        ]
                      }
                    ]
                  },
                  {
                    type = "listItem"
                    content = [
                      {
                        type = "paragraph"
                        content = [
                          {
                            type = "text"
                            text = "Corrupted or encrypted file"
                          }
                        ]
                      }
                    ]
                  },
                  {
                    type = "listItem"
                    content = [
                      {
                        type = "paragraph"
                        content = [
                          {
                            type = "text"
                            text = "Unsupported document format"
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                type = "paragraph"
                content = [
                  {
                    type = "text"
                    text = "Please upload a text-based PDF or DOCX file for analysis."
                  }
                ]
              }
            ]
          }
        }
        ResultPath = "$.errorComment"
        Next = "PostErrorCommentToJira"
      }
      FormatErrorComment = {
        Type = "Pass"
        Parameters = {
          body = {
            type = "doc"
            version = 1
            content = [
              {
                type = "heading"
                attrs = {
                  level = 2
                }
                content = [
                  {
                    type = "text"
                    text = "⚠️ System Processing Error"
                  }
                ]
              },
              {
                type = "paragraph"
                content = [
                  {
                    type = "text"
                    text = "Document: "
                  },
                  {
                    type = "text"
                    "text.$" = "$.filename"
                    marks = [
                      {
                        type = "code"
                      }
                    ]
                  }
                ]
              },
              {
                type = "paragraph"
                content = [
                  {
                    type = "text"
                    text = "A system error occurred during processing. Please check the logs."
                  }
                ]
              },
              {
                type = "codeBlock"
                attrs = {
                  language = "json"
                }
                content = [
                  {
                    type = "text"
                    "text.$" = "States.JsonToString($.errorInfo)"
                  }
                ]
              }
            ]
          }
        }
        ResultPath = "$.errorComment"
        Next = "PostErrorCommentToJira"
      }
      PostErrorCommentToJira = {
        Type = "Task"
        Resource = "arn:aws:states:::http:invoke"
        Parameters = {
          "ApiEndpoint.$" = "States.Format('{}/rest/api/3/issue/{}/comment', $.jiraBaseUrl, $.issueKey)"
          Method = "POST"
          Headers = {
            "Content-Type" = "application/json"
          }
          Authentication = {
            "ConnectionArn.$" = "$.jiraConnectionArn"
          }
          "RequestBody.$" = "$.errorComment"
        }
        End = true
      }
    }
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions_logs.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy.step_functions_main_policy,
    aws_cloudwatch_log_group.step_functions_logs,
    aws_lambda_function.document_processor,
    aws_cloudwatch_event_connection.jira_connection
  ]
}