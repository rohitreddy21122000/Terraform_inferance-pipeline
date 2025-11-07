variable "state_machine_name" { type = string }
variable "state_definition_file" { type = string, default = "state_machine_definition.json" }
variable "include_execution_data" { type = bool, default = false }
variable "log_level" { type = string, default = "ERROR" }
variable "log_retention_days" { type = number, default = 14 }
variable "environment" { type = string }
variable "tags" { type = map(string), default = {} }
# dynamic ARNs referenced in policy (allow list)
variable "lambda_invocation_arns" { type = list(string), default = [] }
variable "s3_read_arns" { type = list(string), default = [] }
variable "jira_connection_pattern" { type = string, default = "Jira-Connection-*" }
variable "account_id" { type = string, default = "" }
variable "region" { type = string, default = "ap-south-1" }
