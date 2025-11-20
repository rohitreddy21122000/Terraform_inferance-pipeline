#!/bin/bash

# GitHub Actions Setup Helper Script
# This script helps you set up GitHub secrets for CI/CD

echo "=========================================="
echo "GitHub Actions CI/CD Setup"
echo "=========================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "📥 Install it from: https://cli.github.com/"
    echo ""
    echo "Or install via:"
    echo "  macOS:  brew install gh"
    echo "  Linux:  sudo apt install gh"
    exit 1
fi

echo "✅ GitHub CLI detected"
echo ""

# Authenticate if needed
if ! gh auth status &> /dev/null; then
    echo "🔐 Please authenticate with GitHub:"
    gh auth login
fi

echo "=========================================="
echo "Setting up GitHub Secrets"
echo "=========================================="
echo ""

# QA Environment
echo "📝 QA Environment Secrets:"
echo ""
read -p "Enter AWS Access Key ID for QA: " AWS_ACCESS_KEY_ID_QA
read -s -p "Enter AWS Secret Access Key for QA: " AWS_SECRET_ACCESS_KEY_QA
echo ""
read -p "Enter EventBridge Username for QA: " EVENTBRIDGE_USERNAME_QA
read -s -p "Enter EventBridge Password for QA: " EVENTBRIDGE_PASSWORD_QA
echo ""
echo ""

# Production Environment
echo "📝 Production Environment Secrets:"
echo ""
read -p "Enter AWS Access Key ID for PROD: " AWS_ACCESS_KEY_ID_PROD
read -s -p "Enter AWS Secret Access Key for PROD: " AWS_SECRET_ACCESS_KEY_PROD
echo ""
read -p "Enter EventBridge Username for PROD: " EVENTBRIDGE_USERNAME_PROD
read -s -p "Enter EventBridge Password for PROD: " EVENTBRIDGE_PASSWORD_PROD
echo ""
echo ""

# Optional Slack
read -p "Do you want to set up Slack notifications? (y/n): " SETUP_SLACK
if [ "$SETUP_SLACK" = "y" ]; then
    read -p "Enter Slack Webhook URL: " SLACK_WEBHOOK_URL
fi
echo ""

echo "=========================================="
echo "Creating GitHub Secrets..."
echo "=========================================="

# Create QA secrets
echo "📤 Creating QA secrets..."
echo "$AWS_ACCESS_KEY_ID_QA" | gh secret set AWS_ACCESS_KEY_ID_QA
echo "$AWS_SECRET_ACCESS_KEY_QA" | gh secret set AWS_SECRET_ACCESS_KEY_QA
echo "$EVENTBRIDGE_USERNAME_QA" | gh secret set EVENTBRIDGE_USERNAME_QA
echo "$EVENTBRIDGE_PASSWORD_QA" | gh secret set EVENTBRIDGE_PASSWORD_QA

# Create Production secrets
echo "📤 Creating Production secrets..."
echo "$AWS_ACCESS_KEY_ID_PROD" | gh secret set AWS_ACCESS_KEY_ID_PROD
echo "$AWS_SECRET_ACCESS_KEY_PROD" | gh secret set AWS_SECRET_ACCESS_KEY_PROD
echo "$EVENTBRIDGE_USERNAME_PROD" | gh secret set EVENTBRIDGE_USERNAME_PROD
echo "$EVENTBRIDGE_PASSWORD_PROD" | gh secret set EVENTBRIDGE_PASSWORD_PROD

# Create Slack secret if needed
if [ "$SETUP_SLACK" = "y" ]; then
    echo "📤 Creating Slack secret..."
    echo "$SLACK_WEBHOOK_URL" | gh secret set SLACK_WEBHOOK_URL
fi

echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Update the approver username in .github/workflows/terraform-prod.yml"
echo "2. Create 'qa' and 'main' branches if they don't exist"
echo "3. Push your code to trigger workflows"
echo ""
echo "For more details, see: .github/CICD-SETUP.md"
echo ""
