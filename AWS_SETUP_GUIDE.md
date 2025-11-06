# AWS Configuration Guide for Terraform Infrastructure

## Required Configuration

### 1. AWS Credentials Setup (Choose ONE option)

#### Option A: AWS CLI Configuration (Recommended)
```bash
# Install AWS CLI first if not installed
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Configure with your credentials
aws configure
# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key  
# - Default region: ap-south-1
# - Default output format: json
```

#### Option B: Environment Variables
```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-south-1"
```

#### Option C: AWS Profile (Multiple AWS Accounts)
```bash
# Create named profile
aws configure --profile mycompany
export AWS_PROFILE=mycompany
```

### 2. Required AWS Permissions

Your AWS user/role needs these permissions:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:*",
                "states:*",
                "apigateway:*",
                "wafv2:*",
                "iam:*",
                "logs:*",
                "events:*"
            ],
            "Resource": "*"
        }
    ]
}
```

## Optional Customizations

### 1. Change AWS Region
**File**: `environments/<env>/terraform.tfvars`
```hcl
# Change this to your preferred region
region = "us-east-1"  # or us-west-2, eu-west-1, etc.
```

### 2. Customize Resource Sizing
**File**: `environments/<env>/terraform.tfvars`
```hcl
# Adjust these based on your needs
lambda_timeout = 60          # seconds
lambda_memory_size = 1024    # MB
waf_rate_limit = 5000       # requests per 5 minutes
```

### 3. Add Additional Tags
**File**: `provider.tf` (line 19)
```hcl
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project = "TechContractInfra"
      Environment = var.environment
      Owner = "YourName"
      CostCenter = "Engineering"
    }
  }
}
```

## Deployment Commands

### Deploy to QA Environment
```bash
cd environments/qa
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Deploy to Production
```bash
cd environments/prod
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Verification Commands

### Test AWS Connection
```bash
aws sts get-caller-identity
```

### Check Terraform
```bash
terraform version
terraform validate
```