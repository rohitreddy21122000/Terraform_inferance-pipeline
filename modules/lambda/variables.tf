variable "function_name" { type = string }
variable "environment" { type = string }
variable "runtime" { type = string, default = "python3.11" }
variable "memory_size" { type = number, default = 512 }
variable "timeout" { type = number, default = 90 }
variable "s3_bucket_name" { type = string }
variable "state_machine_arn" { type = string }
variable "jira_api_token" { type = string, sensitive = true }
variable "jira_email" { type = string, sensitive = true }
variable "jira_base_url" { type = string }
variable "jira_connection_arn" { type = string }
variable "jira_webhook_secret" { type = string, sensitive = true }
variable "layer_arns" { type = list(string), default = [] }
variable "log_retention_days" { type = number, default = 14 }
variable "tags" { type = map(string), default = {} }
