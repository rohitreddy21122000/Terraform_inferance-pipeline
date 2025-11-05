variable "env" { type = string }
variable "role_arn" { type = string }
variable "lambda_arn" { type = string }

data "template_file" "asl" {
  template = file("${path.module}/state_machine.asl.json.tpl")
  vars = {
    lambda_arn = var.lambda_arn
    comment    = "TechContractAnalysisWorkflow - ${var.env}"
  }
}

resource "aws_sfn_state_machine" "state_machine" {
  name     = "TechContractAnalysisWorkflow-${var.env}"
  role_arn = var.role_arn
  definition = data.template_file.asl.rendered
  type = "STANDARD"
}
