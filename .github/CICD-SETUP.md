# GitHub Actions CI/CD Setup Guide

This repository uses GitHub Actions for automated Terraform deployments to QA and Production environments.

## 🏗️ Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│     Dev     │────▶│     QA      │────▶│   Production│
│   (Local)   │     │  (Auto)     │     │  (Manual)   │
└─────────────┘     └─────────────┘     └─────────────┘
      ↓                    ↓                    ↓
  terraform.tfvars   environments/      environments/
                     qa.tfvars          prod.tfvars
```

## 📋 Prerequisites

1. AWS Account with appropriate permissions
2. GitHub repository access
3. Terraform Cloud/Backend (optional but recommended)

## 🔐 Required GitHub Secrets

### Step 1: Navigate to GitHub Secrets
1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### Step 2: Add AWS Credentials

#### For QA Environment:
- `AWS_ACCESS_KEY_ID_QA` - AWS Access Key for QA account
- `AWS_SECRET_ACCESS_KEY_QA` - AWS Secret Key for QA account
- `EVENTBRIDGE_USERNAME_QA` - EventBridge connection username for QA
- `EVENTBRIDGE_PASSWORD_QA` - EventBridge connection password for QA

#### For Production Environment:
- `AWS_ACCESS_KEY_ID_PROD` - AWS Access Key for Production account
- `AWS_SECRET_ACCESS_KEY_PROD` - AWS Secret Key for Production account
- `EVENTBRIDGE_USERNAME_PROD` - EventBridge connection username for Production
- `EVENTBRIDGE_PASSWORD_PROD` - EventBridge connection password for Production

#### Optional (for Slack notifications):
- `SLACK_WEBHOOK_URL` - Slack webhook URL for deployment notifications

## 🚀 Deployment Workflows

### QA Deployment (Automated)

**Triggers:**
- Push to `qa` or `develop` branch
- Pull request to `qa` or `develop` branch

**Workflow:**
1. ✅ Terraform format check
2. ✅ Terraform init
3. ✅ Terraform validate
4. ✅ Terraform plan (comments on PR)
5. ✅ Terraform apply (only on push to `qa` branch)

**Branch Strategy:**
```bash
# Create a feature branch
git checkout -b feature/your-feature

# Push changes
git push origin feature/your-feature

# Create PR to develop/qa branch
# Workflow will run plan and comment on PR

# Merge to qa branch
# Workflow will automatically apply changes
```

### Production Deployment (Manual Approval)

**Triggers:**
- Push to `main` branch
- Manual workflow dispatch
- GitHub release

**Workflow:**
1. ✅ Terraform format check
2. ✅ Terraform init
3. ✅ Terraform validate
4. ✅ Terraform plan
5. ⏸️ **Manual approval required** (creates GitHub Issue)
6. ✅ Terraform apply (after approval)
7. 📢 Slack notification (if configured)

**Manual Deployment:**
```bash
# Go to Actions tab in GitHub
# Select "Terraform Production Deployment"
# Click "Run workflow"
# Choose action: plan, apply, or destroy
# Click "Run workflow" button
```

## 🌍 Environment Configuration

### File Structure:
```
environments/
├── dev.tfvars   # Local development (commit this)
├── qa.tfvars    # QA environment (commit this)
└── prod.tfvars  # Production environment (commit this)
```

### Local Development:
```bash
# Copy dev config to terraform.tfvars
cp environments/dev.tfvars terraform.tfvars

# Edit with your credentials
vim terraform.tfvars

# Apply locally
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

## 📊 Monitoring Deployments

### View Workflow Runs:
1. Go to **Actions** tab in GitHub
2. Select the workflow (QA or Production)
3. Click on a specific run to see details

### Artifacts:
- Terraform state files are uploaded as artifacts
- Retention: QA (30 days), Production (90 days)

## 🔄 Workflow Details

### QA Workflow Features:
- ✅ Automatic deployment on merge to `qa`
- ✅ PR comments with plan output
- ✅ No manual approval needed
- ✅ Fast iteration for testing

### Production Workflow Features:
- ✅ Manual approval required (via GitHub Issue)
- ✅ Slack notifications (optional)
- ✅ Manual destroy capability
- ✅ State file backup (90 days)
- ✅ Rollback support

## 🛡️ Security Best Practices

1. **AWS Credentials:**
   - Use separate AWS accounts/roles for QA and Production
   - Rotate credentials regularly
   - Use least-privilege IAM policies

2. **Secrets:**
   - Never commit secrets to repository
   - Use GitHub Secrets for all sensitive values
   - Rotate EventBridge credentials periodically

3. **Approvals:**
   - Production deployments require manual approval
   - Review Terraform plan before approving
   - Update `approvers` list in workflow

4. **State Management:**
   - Consider using Terraform Cloud or S3 backend
   - Enable state locking
   - Backup state files regularly

## 🔧 Troubleshooting

### Workflow Fails on Init:
```bash
# Check AWS credentials are correctly set in secrets
# Verify Terraform version compatibility
```

### Manual Approval Not Working:
```bash
# Update approvers list in .github/workflows/terraform-prod.yml
# Replace 'rohitreddy21122000' with your GitHub username
```

### State Lock Issues:
```bash
# If using S3 backend with DynamoDB locking
# Manually remove lock from DynamoDB table if needed
```

## 📝 Customization

### Update Terraform Version:
Edit `TF_VERSION` in workflow files:
```yaml
env:
  TF_VERSION: '1.5.0'  # Change this
```

### Change Approval Requirements:
Edit `.github/workflows/terraform-prod.yml`:
```yaml
approvers: your-github-username
minimum-approvals: 1  # Increase for multiple approvers
```

### Add More Environments:
1. Create new tfvars file: `environments/staging.tfvars`
2. Copy and modify workflow file
3. Add corresponding GitHub secrets

## 📞 Support

For issues or questions:
1. Check workflow logs in GitHub Actions
2. Review Terraform plan output
3. Check AWS CloudWatch logs
4. Create an issue in this repository

---

**Ready to Deploy?** 🚀

1. ✅ Add all GitHub secrets
2. ✅ Update approvers in production workflow
3. ✅ Test with QA deployment first
4. ✅ Review and approve production deployment
