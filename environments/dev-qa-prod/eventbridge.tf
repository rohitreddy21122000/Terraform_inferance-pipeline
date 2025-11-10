resource "aws_cloudwatch_event_connection" "jira_connection" {
  name        = "Jira-Connection-${var.environment}"
  description = "EventBridge connection to Jira API for ${var.environment} environment"

  authorization_type = "BASIC"

  auth_parameters {
    basic {
      username = var.jira_email
      password = var.jira_api_token
    }

    invocation_http_parameters {
      header {
        key   = "Content-Type"
        value = "application/json"
      }
      header {
        key   = "Accept"
        value = "application/json"
      }
      header {
        key   = "User-Agent"
        value = "PFJ-Legal-Tech-Contracts/1.0"
      }
    }
  }

  tags = merge(local.common_tags, {
    Name = "Jira-Connection-${var.environment}"
    Environment = var.environment
    "aws:secretsmanager:owningService" = "events"
  })
}

# Data source to reference the auto-created secret
data "aws_secretsmanager_secret" "jira_connection_secret" {
  arn = aws_cloudwatch_event_connection.jira_connection.secret_arn
  
  depends_on = [aws_cloudwatch_event_connection.jira_connection]
}

# Data source to get the secret value
data "aws_secretsmanager_secret_version" "jira_connection_secret_version" {
  secret_id = data.aws_secretsmanager_secret.jira_connection_secret.id
  
  depends_on = [aws_cloudwatch_event_connection.jira_connection]
}