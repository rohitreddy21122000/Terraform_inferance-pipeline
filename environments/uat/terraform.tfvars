environment = "uat"
region = "ap-south-1"

# tags
tags = {
  Environment = "uat"
  Owner       = "dev-team"
}

# s3
bucket_name = "pfj-legal-tech-contracts-uat"   # change to your unique bucket name
enable_versioning = true
document_retention_days = 90
enable_intelligent_tiering = false

# lambda webhook inputs
function_name = "tech-webhooklambda-uat"
runtime = "python3.11"
memory_size = 768
timeout = 45

# Jira - replace with your secret values or pass as env variables
jira_base_url = "https://pilotflyingj-sandbox-951.atlassian.net"
jira_email = "vamshi.gud@pilottravelcenters.com"
jira_api_token = "REPLACE_ME"
jira_webhook_secret = "REPLACE_ME"
jira_connection_arn = "REPLACE_ME"

# state machine file name (placed under modules/step_functions)
state_definition_file = "state_machine_definition.json"

# WAF settings
waf_rate_limit = 3000
