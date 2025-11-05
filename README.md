# Terraform_inferance-pipeline => Tech Contract Analysis - Terraform

## prerequisites
- Terraform >= 1.2
- AWS CLI configured for your account (use AWS_PROFILE or env vars)
- An S3 bucket + DynamoDB table for remote state (or use local state initially)
- Ensure you have permissions to create Lambda, Step Functions, API Gateway, Secrets Manager, WAF (some features are regional).

## Quickstart (QA environment)
1. cd infra/envs/qa
2. terraform init
   - If you use the global/backend.tf with S3, init will configure remote backend
3. terraform plan -var-file=terraform.tfvars
4. terraform apply -var-file=terraform.tfvars

## Notes & important caveats
- **Amazon Bedrock**: Bedrock calls in your original ASL are not created by Terraform in this repo. Bedrock is not free-tier and may require account enrollment. The ASL template included is simplified and references LAMBDA and HTTP invoke tasks.
- **WAF and API Gateway associations**: you might need to manually associate WAF to API Gateway if Terraform cannot derive exact execution ARN in your region. I provided a WAF module; to associate add `aws_wafv2_web_acl_association` in root with the exact API stage execution ARN.
- **Secrets**: Jira token is placed in Secrets Manager via TF; replace `jira_token_json` variable with your token JSON (do not commit).
- **Costs**: Step Functions, Lambda, API Gateway have free-tier allowances but may incur cost beyond. Bedrock is billable. WAF and CloudWatch also can incur costs.
- **Testing**: After deploy, POST to `${module.apigw.api_endpoint}/ingest` with a JSON body resembling what your state machine expects (filename, document, jiraBaseUrl, issueKey, jiraConnectionArn, etc.)

## Promoting QA -> UAT -> PROD
- Use separate working directories (`envs/qa`, `envs/uat`, `envs/prod`) and separate tfvars with stricter settings for uat/prod.
- Use CI/CD (GitHub Actions) with manual approvals for promoting changes.

## Troubleshooting
- If `aws_sfn_state_machine` fails because `definition` contains unsupported characters or is too large, create an S3 object with the JSON and refer to it, or split your ASL.
- If Lambda fails to execute due to missing permissions, check CloudWatch logs and add permissions to the IAM role.
