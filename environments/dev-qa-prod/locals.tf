locals {

  config = yamldecode(
    templatefile(
      var.config,
      {
        stack_name  = var.stack_name,
        environment = var.environment,
        line_of_business = var.line_of_business,
        product = var.product,
        project = var.project
      }
    )
  )

  # Common tags for all resources
  common_tags = merge(
    try(local.config.tags, {}),
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  )

  # Lambda layer configuration
  webhook_lambda_layers = var.create_lambda_layer ? [
    aws_lambda_layer_version.document_processing_layer.arn
  ] : var.existing_webhook_layer_arns

  extracttext_lambda_layers = var.create_lambda_layer ? [
    aws_lambda_layer_version.document_processing_layer.arn
  ] : var.existing_extracttext_layer_arns
}