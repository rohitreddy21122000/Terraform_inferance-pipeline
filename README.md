# Terraform S3 Bucket - Beginner Guide

This is a simple Terraform project to create an AWS S3 bucket. Perfect for learning Terraform basics!

## Prerequisites

1. **Install Terraform**: Download from [terraform.io](https://www.terraform.io/downloads)
2. **AWS Account**: You need an AWS account
3. **AWS CLI**: Install and configure with your credentials
   ```bash
   aws configure
   ```
   You'll need:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region (e.g., us-east-1)

## Project Structure

```
.
├── main.tf           # Main Terraform configuration (AWS provider & S3 bucket)
├── variables.tf      # Variable definitions
├── outputs.tf        # Output values to display after creation
├── terraform.tfvars  # Variable values (customize this!)
└── README.md         # This file
```

## What This Creates

This Terraform configuration creates:
- ✅ An S3 bucket with a unique name
- ✅ Versioning enabled (keeps history of file changes)
- ✅ Public access blocked (security best practice)
- ✅ Tags for organization

## Step-by-Step Usage

### Step 1: Customize Your Bucket Name

Edit `terraform.tfvars` and change the bucket name to something unique:

```hcl
bucket_name = "my-unique-bucket-name-12345"
```

**Important**: S3 bucket names must be:
- Globally unique across ALL AWS accounts
- 3-63 characters long
- Lowercase letters, numbers, and hyphens only
- No underscores or uppercase letters

### Step 2: Initialize Terraform

This downloads the AWS provider plugin:

```bash
terraform init
```

### Step 3: Preview Changes

See what Terraform will create:

```bash
terraform plan
```

### Step 4: Create the S3 Bucket

Apply the configuration:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Step 5: View Outputs

After creation, you'll see outputs like:
```
bucket_name   = "my-unique-bucket-name-12345"
bucket_arn    = "arn:aws:s3:::my-unique-bucket-name-12345"
bucket_region = "us-east-1"
```

## Managing Your Infrastructure

### View Current State

```bash
terraform show
```

### Destroy Resources

When you're done testing, clean up to avoid charges:

```bash
terraform destroy
```

Type `yes` to confirm deletion.

## Common Commands Cheat Sheet

| Command | Description |
|---------|-------------|
| `terraform init` | Initialize the project (run first) |
| `terraform plan` | Preview changes before applying |
| `terraform apply` | Create/update resources |
| `terraform destroy` | Delete all resources |
| `terraform show` | View current state |
| `terraform fmt` | Format your .tf files nicely |
| `terraform validate` | Check for syntax errors |

## Understanding the Files

### main.tf
- Defines the AWS provider and region
- Creates the S3 bucket resource
- Enables versioning and blocks public access

### variables.tf
- Declares variables (inputs) that can be customized
- Includes descriptions and default values

### outputs.tf
- Defines what information to show after creation
- Useful for getting resource details

### terraform.tfvars
- Where you set actual values for variables
- This is what you'll edit most often

## Next Steps

Once comfortable with this, you can:
1. Add more S3 bucket features (encryption, lifecycle rules)
2. Create multiple resources
3. Use modules to organize code
4. Set up remote state storage
5. Add more AWS services (EC2, Lambda, etc.)

## Troubleshooting

**Error: Bucket name already exists**
- Change the `bucket_name` in `terraform.tfvars` to something more unique

**Error: AWS credentials not found**
- Run `aws configure` to set up your credentials

**Error: Region not authorized**
- Change `aws_region` in `terraform.tfvars` to a region you have access to

## Learn More

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
