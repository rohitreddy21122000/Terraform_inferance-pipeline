# Terraform Environment Management Guide

## 🔄 Environment Lifecycle Management

### Destroying Environments

#### Destroy QA Environment
```bash
# Navigate to QA environment
cd environments/qa

# Plan the destroy (see what will be deleted)
terraform plan -destroy -var-file="terraform.tfvars"

# Destroy the environment
terraform destroy -var-file="terraform.tfvars"

# Confirm with 'yes' when prompted
```

#### Destroy UAT Environment
```bash
cd environments/uat
terraform destroy -var-file="terraform.tfvars"
```

#### Destroy Production Environment
```bash
cd environments/prod
terraform destroy -var-file="terraform.tfvars"
```

### Starting New Environments

#### Deploy to UAT
```bash
cd environments/uat
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

#### Deploy to Production
```bash
cd environments/prod
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Environment Promotion Workflow

#### Recommended Flow: QA → UAT → PROD
```bash
# 1. Test in QA
cd environments/qa
terraform apply -var-file="terraform.tfvars"
# Test your application...

# 2. Destroy QA (if needed)
terraform destroy -var-file="terraform.tfvars"

# 3. Deploy to UAT
cd ../uat
terraform apply -var-file="terraform.tfvars"
# Test in UAT environment...

# 4. Deploy to Production
cd ../prod
terraform apply -var-file="terraform.tfvars"
```

## 🛡️ Safety Best Practices

### Before Destroying
1. **Backup Important Data**: Export any logs or data you need
2. **Verify Environment**: Make sure you're in the right directory
3. **Check Resources**: Run `terraform plan -destroy` first

### Environment-Specific Considerations

#### QA Environment
- Safe to destroy/recreate frequently
- Use for testing new features
- Lower resource allocation (cost-effective)

#### UAT Environment  
- More stable than QA
- Used for user acceptance testing
- Medium resource allocation

#### Production Environment
- ⚠️ **NEVER** destroy without proper backup/migration plan
- Requires approval process
- Full resource allocation for performance

## 📊 Resource Differences by Environment

| Resource | QA | UAT | PROD |
|----------|----|----|------|
| Lambda Memory | 512MB | 768MB | 1024MB |
| Lambda Timeout | 30s | 45s | 60s |
| WAF Rate Limit | 2000/5min | 3000/5min | 5000/5min |
| Cost | Low | Medium | High |

## 🔍 Monitoring Commands

### Check Current Resources
```bash
# See what's currently deployed
terraform show

# List all resources
terraform state list

# Get specific resource info
terraform state show aws_lambda_function.fn
```

### Environment Status
```bash
# Check if environment is healthy
terraform plan -var-file="terraform.tfvars"

# Get outputs (API endpoints, etc.)
terraform output
```

## 🚨 Emergency Commands

### Force Destroy (if normal destroy fails)
```bash
# Only use if regular destroy is stuck
terraform destroy -auto-approve -var-file="terraform.tfvars"
```

### Remove Stuck Resources from State
```bash
# If a resource is stuck, remove from state
terraform state rm aws_resource.stuck_resource

# Then destroy the environment
terraform destroy -var-file="terraform.tfvars"
```

## 💰 Cost Management

### Minimize Costs
1. **Destroy QA/UAT** when not actively testing
2. **Use smaller instances** in non-prod environments  
3. **Schedule deployments** during business hours only

### Cost-Effective Workflow
```bash
# Morning: Deploy for testing
cd environments/qa
terraform apply -var-file="terraform.tfvars"

# Evening: Destroy to save costs
terraform destroy -var-file="terraform.tfvars"
```