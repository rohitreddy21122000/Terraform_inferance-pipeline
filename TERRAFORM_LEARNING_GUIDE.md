# 🚀 Terraform Learning Guide - From Your Own Infrastructure Code

## 📚 Table of Contents
1. [Terraform Basics](#terraform-basics)
2. [Project Structure](#project-structure)
3. [Provider Configuration](#provider-configuration)
4. [Variables System](#variables-system)
5. [Resources](#resources)
6. [Modules](#modules)
7. [Outputs](#outputs)
8. [Data Sources](#data-sources)
9. [Best Practices](#best-practices)

---

## 🔧 Terraform Basics

### What is Terraform?
- **Infrastructure as Code (IaC)** tool
- **Declarative** - you describe what you want, not how to build it
- **State Management** - tracks what exists vs what should exist
- **Multi-cloud** - works with AWS, Azure, GCP, etc.

### Core Workflow
```bash
terraform init     # Download providers & modules
terraform plan     # Preview changes
terraform apply    # Make changes
terraform destroy  # Delete everything
```

---

## 📁 Project Structure (Your Current Setup)

```
Terraform_inferance-pipeline/
├── main.tf                 # Root module - calls other modules
├── provider.tf            # Provider configuration (AWS)
├── variables.tf           # Root variables
├── environments/          # Environment-specific configs
│   ├── qa/
│   ├── uat/
│   └── prod/
└── modules/               # Reusable components
    ├── lambda/
    ├── api_gateway/
    ├── step_function/
    ├── iam/
    └── waf/
```

### Why This Structure?
- **Separation of Concerns**: Each module has one purpose
- **Reusability**: Same module used across environments
- **Environment Isolation**: QA/UAT/PROD separate configs
- **Modularity**: Easy to add/remove components

---

## 🔌 Provider Configuration

### Your `provider.tf`:
```hcl
terraform {
  required_version = ">= 1.3.0"           # Minimum Terraform version
  required_providers {                     # External plugins needed
    aws = {
      source  = "hashicorp/aws"           # Where to download from
      version = ">= 4.0"                  # Minimum provider version
    }
    archive = {
      source  = "hashicorp/archive"       # For zip files
      version = ">= 2.2.0"
    }
  }
}

provider "aws" {
  region = var.region                     # Use variable for flexibility
  default_tags {                          # Tags applied to ALL resources
    tags = {
      Project = "TechContractInfra"
    }
  }
}
```

### Key Concepts:
- **Provider**: Plugin that talks to cloud APIs
- **required_providers**: Ensures everyone uses same versions
- **default_tags**: Automatic tagging for cost tracking

---

## 🔤 Variables System

### 3 Types of Variables:

#### 1. Input Variables (`variables.tf`)
```hcl
variable "region" {
  description = "AWS region"              # Documentation
  type        = string                    # Data type validation
  default     = "ap-south-1"             # Fallback value
}

variable "lambda_memory_size" {
  description = "Lambda memory in MB"
  type        = number                    # Number validation
  default     = 512
  
  validation {                            # Custom validation
    condition     = var.lambda_memory_size >= 128
    error_message = "Lambda memory must be at least 128 MB."
  }
}
```

#### 2. Local Values (`locals`)
```hcl
locals {
  env = var.environment
  name_prefix = "tech-contract"
  
  # Computed values
  lambda_name = "${local.name_prefix}-${local.env}"
}
```

#### 3. Output Values (`outputs.tf`)
```hcl
output "api_endpoint" {
  description = "API Gateway URL"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}
```

### Variable Precedence (Highest to Lowest):
1. Command line: `-var="region=us-east-1"`
2. `.tfvars` files: `terraform.tfvars`
3. Environment variables: `TF_VAR_region=us-east-1`
4. Default values in `variables.tf`

---

## 🏗️ Resources (Building Blocks)

### Basic Resource Syntax:
```hcl
resource "resource_type" "resource_name" {
  argument1 = "value1"
  argument2 = var.variable_name
  
  # Nested block
  nested_block {
    nested_argument = "value"
  }
}
```

### Example from Your Lambda Module:
```hcl
resource "aws_lambda_function" "fn" {
  function_name = "${var.name}-${var.env}"     # String interpolation
  filename      = data.archive_file.lambda_zip.output_path
  role          = aws_iam_role.lambda_exec.arn # Reference another resource
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
}
```

### Key Concepts:
- **Resource Type**: `aws_lambda_function` (from AWS provider)
- **Resource Name**: `fn` (your local reference)
- **Arguments**: Configuration parameters
- **References**: `aws_iam_role.lambda_exec.arn` (use output from another resource)

---

## 📦 Modules (Reusable Components)

### Your Root Module (`main.tf`):
```hcl
module "lambda" {
  source = "./modules/lambda"              # Where the module is
  
  # Pass variables to the module
  name   = "tech-extract-text"
  env    = var.environment
}

module "step_function" {
  source = "./modules/step_function"
  
  env        = var.environment
  role_arn   = module.iam.sfn_role_arn    # Use output from another module
  lambda_arn = module.lambda.lambda_arn   # Chain modules together
}
```

### Module Structure:
```
modules/lambda/
├── main.tf       # Resources
├── variables.tf  # Input variables
└── outputs.tf    # Return values
```

### Why Use Modules?
- **DRY**: Don't Repeat Yourself
- **Consistency**: Same setup across environments
- **Testability**: Test modules independently
- **Sharing**: Reuse across projects

---

## 📤 Outputs (Return Values)

### From Your Lambda Module (`modules/lambda/outputs.tf`):
```hcl
output "lambda_arn" {
  value = aws_lambda_function.fn.arn
}

output "lambda_name" {
  value = aws_lambda_function.fn.function_name
}
```

### Usage in Root Module:
```hcl
# Use lambda module output in step function module
module "step_function" {
  lambda_arn = module.lambda.lambda_arn    # ← Using output here
}
```

### Why Outputs?
- **Module Communication**: Pass data between modules
- **External Integration**: Get values for scripts/apps
- **Debugging**: See computed values

---

## 📊 Data Sources (Read Existing Resources)

### Example from Your Step Function:
```hcl
data "template_file" "asl" {
  template = file("${path.module}/state_machine.asl.json.tpl")
  vars = {
    lambda_arn = var.lambda_arn
    comment    = "TechContractAnalysisWorkflow - ${var.env}"
  }
}

resource "aws_sfn_state_machine" "state_machine" {
  definition = data.template_file.asl.rendered    # Use data source output
}
```

### Common Data Sources:
```hcl
# Read existing VPC
data "aws_vpc" "default" {
  default = true
}

# Read current AWS account
data "aws_caller_identity" "current" {}

# Read availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
```

---

## 🎯 Resource Dependencies

### Implicit Dependencies (Automatic):
```hcl
resource "aws_iam_role" "lambda_exec" {
  # ... role definition
}

resource "aws_lambda_function" "fn" {
  role = aws_iam_role.lambda_exec.arn    # ← Terraform knows role must exist first
}
```

### Explicit Dependencies (Manual):
```hcl
resource "aws_lambda_function" "fn" {
  # ... configuration
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic    # Force dependency
  ]
}
```

---

## 🔄 State Management

### What is State?
- **Current Reality**: What actually exists in AWS
- **State File**: `terraform.tfstate` (JSON file)
- **Comparison**: Terraform compares desired vs actual state

### State Commands:
```bash
terraform state list                    # Show all resources
terraform state show aws_lambda_function.fn    # Show specific resource
terraform state mv old_name new_name   # Rename resource
terraform state rm resource_name       # Remove from state (not AWS)
```

### Remote State (Recommended):
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "environments/qa/terraform.tfstate"
    region = "ap-south-1"
  }
}
```

---

## 🏆 Best Practices (From Your Code)

### 1. **Environment Separation**
```
environments/
├── qa/     ← Separate state files
├── uat/    ← Different configurations
└── prod/   ← Production isolation
```

### 2. **Module Organization**
```hcl
# Good: Single responsibility
module "lambda" { }
module "api_gateway" { }

# Bad: Everything in one module
module "entire_app" { }
```

### 3. **Variable Validation**
```hcl
variable "environment" {
  type = string
  validation {
    condition = contains(["qa", "uat", "prod"], var.environment)
    error_message = "Environment must be qa, uat, or prod."
  }
}
```

### 4. **Consistent Naming**
```hcl
resource "aws_lambda_function" "fn" {
  function_name = "${var.name}-${var.env}"    # tech-extract-text-qa
}
```

### 5. **Resource Tagging**
```hcl
provider "aws" {
  default_tags {
    tags = {
      Project     = "TechContractInfra"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
```

---

## 🚀 Getting Started Writing Your Own

### 1. **Start Simple**
```hcl
# Create a single S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-12345"
}
```

### 2. **Add Variables**
```hcl
variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}
```

### 3. **Add Outputs**
```hcl
output "bucket_url" {
  value = aws_s3_bucket.my_bucket.bucket_domain_name
}
```

### 4. **Create Module**
```
modules/s3/
├── main.tf
├── variables.tf
└── outputs.tf
```

### 5. **Use Module**
```hcl
module "storage" {
  source = "./modules/s3"
  bucket_name = "my-app-storage"
}
```

---

## 🎓 Learning Path

### Phase 1: Basics (1-2 weeks)
- ✅ Understand providers, resources, variables
- ✅ Practice with simple resources (S3, EC2)
- ✅ Learn state management

### Phase 2: Intermediate (2-3 weeks)
- ✅ Create your first module
- ✅ Use data sources
- ✅ Understand dependencies

### Phase 3: Advanced (Ongoing)
- ✅ Remote state backends
- ✅ Workspaces for environments
- ✅ CI/CD integration
- ✅ Testing strategies

---

## 💡 Pro Tips

### 1. **Use `terraform fmt`**
```bash
terraform fmt    # Auto-format your code
```

### 2. **Validate Before Apply**
```bash
terraform validate    # Check syntax
terraform plan        # Preview changes
```

### 3. **Version Everything**
```hcl
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      version = "~> 5.0"    # Allow minor updates
    }
  }
}
```

### 4. **Use Locals for Complex Logic**
```hcl
locals {
  is_production = var.environment == "prod"
  instance_type = local.is_production ? "t3.large" : "t3.micro"
}
```

---

## 🔧 Common Patterns in Your Code

### 1. **String Interpolation**
```hcl
function_name = "${var.name}-${var.env}"    # tech-extract-text-qa
```

### 2. **Conditional Logic**
```hcl
memory_size = var.environment == "prod" ? 1024 : 512
```

### 3. **Resource References**
```hcl
role_arn = aws_iam_role.lambda_exec.arn    # Use ARN from another resource
```

### 4. **Module Chaining**
```hcl
module "step_function" {
  lambda_arn = module.lambda.lambda_arn    # Chain modules
}
```

---

This guide covers the core concepts you need to start writing Terraform independently. Your current infrastructure is an excellent example of real-world Terraform usage! 🎉