# Terraform AWS Services - Beginner Guide

This Terraform project creates simple examples of three AWS services. Perfect for learning AWS and Terraform!

## What This Creates

This configuration creates:

### 1. **S3 Bucket**
- ✅ Storage bucket with versioning enabled
- ✅ Public access blocked (secure by default)
- ✅ Tagged for organization

### 2. **EventBridge (CloudWatch Events)**
- ✅ Scheduled rule that triggers every 5 minutes
- ✅ Sends events to CloudWatch Logs
- ✅ Great for scheduled tasks and automation

### 3. **Step Functions**
- ✅ Simple workflow state machine
- ✅ Waits 10 seconds then completes
- ✅ Logs all executions to CloudWatch
- ✅ Foundation for complex workflows

## Prerequisites

1. **Terraform installed** - [Download here](https://www.terraform.io/downloads)
2. **AWS Account** - Free tier eligible
3. **AWS CLI configured**
   ```bash
   aws configure
   ```

## Quick Start

### Step 1: Customize Your Settings

Edit `terraform.tfvars`:
```hcl
bucket_name = "my-unique-bucket-name-12345"  # Must be globally unique!
aws_region  = "us-east-1"
environment = "dev"
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Preview Resources
```bash
terraform plan
```

### Step 4: Create Resources
```bash
terraform apply
```
Type `yes` to confirm.

### Step 5: See Your Resources

After creation, you'll see outputs:
```
bucket_name              = "my-unique-bucket-name-12345"
bucket_arn               = "arn:aws:s3:::my-unique-bucket-name-12345"
eventbridge_rule_name    = "dev-every-5-minutes-rule"
step_function_name       = "dev-simple-workflow"
```

## Testing Your Resources

### Test S3 Bucket
```bash
# Upload a file
echo "Hello World" > test.txt
aws s3 cp test.txt s3://my-unique-bucket-name-12345/

# List files
aws s3 ls s3://my-unique-bucket-name-12345/
```

### Test EventBridge
```bash
# View EventBridge logs (wait 5 minutes for first event)
aws logs tail /aws/events/dev-eventbridge-logs --follow
```

### Test Step Functions
```bash
# Start an execution
aws stepfunctions start-execution \
  --state-machine-arn $(terraform output -raw step_function_arn) \
  --input '{"timestamp": "2025-11-19T12:00:00Z"}'

# List executions
aws stepfunctions list-executions \
  --state-machine-arn $(terraform output -raw step_function_arn)

# View logs
aws logs tail /aws/stepfunctions/dev-simple-workflow --follow
```

## Project Structure

```
.
├── main.tf              # AWS provider + S3 bucket
├── eventbridge.tf       # EventBridge scheduled rule
├── step-functions.tf    # Step Functions state machine
├── variables.tf         # Variable definitions
├── outputs.tf           # Output values
├── terraform.tfvars     # Your custom values
└── README.md           # This file
```

## Understanding Each Service

### S3 (Simple Storage Service)
- **What**: Object storage for files/data
- **Use cases**: Backups, static websites, data lakes
- **Cost**: ~$0.023 per GB/month (first 50 TB)

### EventBridge
- **What**: Event-driven automation service
- **Use cases**: Scheduled tasks, event routing, integrations
- **Cost**: Free for scheduled rules, $1/million custom events
- **This example**: Triggers every 5 minutes, logs to CloudWatch

### Step Functions
- **What**: Visual workflow orchestration
- **Use cases**: Multi-step processes, error handling, retries
- **Cost**: $25 per million state transitions
- **This example**: Simple 2-step workflow (wait → success)

## Common Commands

| Command | Description |
|---------|-------------|
| `terraform init` | Initialize (run first) |
| `terraform plan` | Preview changes |
| `terraform apply` | Create/update resources |
| `terraform destroy` | Delete everything |
| `terraform output` | Show output values |
| `terraform fmt` | Format code |
| `terraform validate` | Check syntax |

## Clean Up (Important!)

To avoid AWS charges, destroy resources when done:

```bash
terraform destroy
```

Type `yes` to confirm deletion.

## Cost Estimate

All three services in this example:
- **S3**: ~$0.02/month (minimal storage)
- **EventBridge**: FREE (scheduled rules)
- **Step Functions**: FREE (first 4,000 state transitions/month)

**Total**: Essentially FREE for learning! 🎉

## Next Steps

### Modify EventBridge Schedule
Edit `eventbridge.tf`:
```hcl
schedule_expression = "rate(1 hour)"    # Every hour
schedule_expression = "rate(1 day)"     # Daily
schedule_expression = "cron(0 9 * * ? *)"  # 9 AM daily
```

### Enhance Step Functions Workflow
Add more states in `step-functions.tf`:
- Add Lambda function invocations
- Add conditional logic (Choice states)
- Add parallel execution
- Add error handling (Catch/Retry)

### Connect Services Together
- Make EventBridge trigger Step Functions
- Have Step Functions write to S3
- Create a complete automation pipeline

## Troubleshooting

**Error: Bucket name already exists**
- Change `bucket_name` in `terraform.tfvars` to something more unique

**Error: No valid credential sources**
- Run `aws configure` to set up credentials

**EventBridge not logging**
- Wait 5 minutes for the first scheduled event
- Check CloudWatch Logs console

**Step Functions execution failed**
- Check CloudWatch Logs for details
- Verify IAM role permissions

## Learn More

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS EventBridge Documentation](https://docs.aws.amazon.com/eventbridge/)
- [AWS Step Functions Documentation](https://docs.aws.amazon.com/step-functions/)

## Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  EventBridge Rule (Every 5 min)                │
│         │                                       │
│         ▼                                       │
│  CloudWatch Logs (/aws/events/...)            │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  Step Functions State Machine                  │
│         │                                       │
│         ├─► Wait 10 seconds                    │
│         │                                       │
│         └─► Success (with message)             │
│         │                                       │
│         ▼                                       │
│  CloudWatch Logs (/aws/stepfunctions/...)     │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  S3 Bucket (my-unique-bucket-name-12345)       │
│         - Versioning enabled                   │
│         - Public access blocked                │
│                                                 │
└─────────────────────────────────────────────────┘
```

Happy Learning! 🚀
