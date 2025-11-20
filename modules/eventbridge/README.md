# EventBridge Module Usage

## Setting Credentials

The EventBridge module requires username and password for basic authentication. You can provide these in several ways:

### Option 1: Using terraform.tfvars (Recommended for local development)

1. Copy the example file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and add your credentials:
   ```hcl
   eventbridge_username = "your-actual-username"
   eventbridge_password = "your-actual-password"
   ```

3. **IMPORTANT**: The `terraform.tfvars` file is already in `.gitignore` and will NOT be committed to version control.

### Option 2: Using Environment Variables

Set the credentials as environment variables:

```bash
export TF_VAR_eventbridge_username="your-username"
export TF_VAR_eventbridge_password="your-password"
terraform apply
```

### Option 3: Pass via Command Line

```bash
terraform apply \
  -var="eventbridge_username=your-username" \
  -var="eventbridge_password=your-password"
```

### Option 4: Interactive Prompt

If you don't provide the variables, Terraform will prompt you interactively during `terraform plan` or `terraform apply`.

## Security Best Practices

- ✅ Never commit `terraform.tfvars` to version control
- ✅ Use environment variables in CI/CD pipelines
- ✅ Consider using AWS Secrets Manager for production
- ✅ Rotate credentials regularly
