terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_cloudwatch_event_connection" "jira_connection" {
  name        = "Jira-Connection-${var.environment}"
  description = "EventBridge connection to Jira API for ${var.environment} environment"

  authorization_type = "BASIC"

  auth_parameters {
    basic {
      username = var.jira_email
      password = var.jira_api_token
    }

    invocation_http_parameters {
      header {
        key   = "Content-Type"
        value = "application/json"
      }
      header {
        key   = "Accept"
        value = "application/json"
      }
      header {
        key   = "User-Agent"
        value = "PFJ-Legal-Tech-Contracts/1.0"
      }
    }
  }
}

# Data source to reference the auto-created secret
# EventBridge automatically creates a secret in the format: eventsconnection/{connection-name}/{unique-id}
# We use the secret_arn from the connection resource since the unique ID is generated
data "aws_secretsmanager_secret" "jira_connection_secret" {
  arn = aws_cloudwatch_event_connection.jira_connection.secret_arn
  
  depends_on = [aws_cloudwatch_event_connection.jira_connection]
}

# Data source to get the secret value (for reference, not to expose)
data "aws_secretsmanager_secret_version" "jira_connection_secret_version" {
  secret_id = data.aws_secretsmanager_secret.jira_connection_secret.id
  
  depends_on = [aws_cloudwatch_event_connection.jira_connection]
}
Outputs
output "connection_arn" {
  description = "ARN of the EventBridge connection"
  value       = aws_cloudwatch_event_connection.jira_connection.arn
}

output "connection_name" {
  description = "Name of the EventBridge connection"
  value       = aws_cloudwatch_event_connection.jira_connection.name
}

output "secret_arn" {
  description = "ARN of the auto-created secret"
  value       = aws_cloudwatch_event_connection.jira_connection.secret_arn
}

output "secret_name" {
  description = "Name of the auto-created secret"
  value       = data.aws_secretsmanager_secret.jira_connection_secret.name
}

output "secret_version_arn" {
  description = "ARN of the secret version"
  value       = data.aws_secretsmanager_secret_version.jira_connection_secret_version.arn
}

output "connection_secret_pattern" {
  description = "Pattern for the auto-created secret name"
  value       = "eventsconnection/Jira-Connection-${var.environment}/{unique-id}"
}
variables