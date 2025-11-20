# EventBridge Connection with Basic Authentication
resource "aws_cloudwatch_event_connection" "webhook_connection" {
  name               = var.connection_name
  description        = "EventBridge connection for webhook with basic authentication"
  authorization_type = "BASIC"

  auth_parameters {
    basic {
      username = var.connection_username
      password = var.connection_password
    }
  }
}
