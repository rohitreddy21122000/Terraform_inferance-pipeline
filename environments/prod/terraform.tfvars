environment = "prod"
region = "ap-south-1"

# tags
tags = {
  Environment = "prod"
  Owner       = "ops-team"
}

# s3
bucket_name = "pfj-legal-tech-contracts-prod"   # change to your unique bucket name
enable_versioning = true
document_retention_days = 365
enable_intelligent_tiering = true

# lambda webhook inputs
function_name = "tech-webhooklambda-prod"
runtime = "python3.11"
memory_size = 1024
timeout = 60

# Jira - replace with your secret values or pass as env variables
jira_base_url = "https://pilotflyingj.atlassian.net"  # prod Jira URL
jira_email = "prod-user@pilottravelcenters.com"
jira_api_token = "REPLACE_ME"
jira_webhook_secret = "REPLACE_ME"
jira_connection_arn = "REPLACE_ME"

# state machine file name (placed under modules/step_functions)
state_definition_file = "state_machine_definition.json"

# WAF settings
waf_rate_limit = 5000
