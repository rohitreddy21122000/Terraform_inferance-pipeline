# Terraform Infrastructure for Tech Contract Analysis Pipeline

This repository contains Terraform infrastructure as code for deploying a serverless tech contract analysis pipeline on AWS.

## Architecture

The pipeline implements a secure, scalable inference pipeline with the following flow:

**Request Flow**: `Client → WAF → API Gateway → Step Functions → Lambda → Response`

### Components:
- **API Gateway**: HTTP API for receiving document processing requests
- **Step Functions**: Orchestrates the document processing workflow with error handling
- **Lambda**: Processes and analyzes documents (NodeJS runtime)
- **WAF**: Web Application Firewall with rate limiting and AWS managed rule sets
- **IAM**: Roles and policies for secure service interactions

## Prerequisites
- Terraform >= 1.3.0
- AWS CLI configured with appropriate credentials
- Proper AWS permissions for creating resources

## Deployment

### Quick Start (Root Module)

1. Clone the repository:
```bash
git clone <repository-url>
cd Terraform_inferance-pipeline
```

2. Deploy using root module:
```bash
terraform init
terraform plan
terraform apply
```

### Environment-Specific Deployment (Recommended)

For different environments (qa/uat/prod):
```bash
cd environments/<environment>
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Configuration

### Environment Variables

Environment-specific variables in `environments/<env>/terraform.tfvars`:

| Variable | QA | UAT | PROD | Description |
|----------|----|----|------|-------------|
| `lambda_timeout` | 30s | 45s | 60s | Lambda function timeout |
| `lambda_memory_size` | 512MB | 768MB | 1024MB | Lambda memory allocation |  
| `waf_rate_limit` | 2000 | 3000 | 5000 | WAF rate limit (per 5 min) |
| `region` | ap-south-1 | ap-south-1 | ap-south-1 | AWS region |

## Usage

### API Endpoint

After deployment, use the API endpoint from outputs:

```bash
# Get endpoint URL
terraform output api_endpoint

# Test the pipeline
curl -X POST <api-endpoint>/ingest \
  -H "Content-Type: application/json" \
  -d '{
    "filename": "contract.pdf", 
    "document": "Sample contract content for analysis"
  }'
```

### Response Format

Successful response:
```json
{
  "final": {
    "message": "Document processed successfully",
    "filename": "contract.pdf",
    "documentContent": "Sample contract content for analysis"
  }
}
```

## Security Features

- **WAF Protection**: Rate limiting + AWS managed rule sets
- **IAM Least Privilege**: Service-specific roles and policies
- **API Gateway Integration**: Secure Step Functions invocation

## Module Structure

```
modules/
├── lambda/          # Document processing function
├── step_function/   # Workflow orchestration
├── api_gateway/     # HTTP API with Step Functions integration
├── iam/            # Service roles and policies
└── waf/            # Web Application Firewall
```

## Outputs

After deployment:
- `api_endpoint`: API Gateway endpoint URL
- `step_function_arn`: Step Function state machine ARN  
- `lambda_function_name`: Lambda function name
- `waf_web_acl_arn`: WAF Web ACL ARN

## Troubleshooting

### Common Issues:
1. **IAM Permissions**: Ensure AWS credentials have required permissions
2. **Resource Limits**: Check AWS service quotas in your region
3. **WAF Association**: May take a few minutes to propagate

### Validation:
```bash
# Check Step Function execution
aws stepfunctions list-executions --state-machine-arn <step-function-arn>

# Check Lambda logs
aws logs tail /aws/lambda/tech-extract-text-<env> --follow
```