# Lambda Management Project - Deployment Guide

## Overview

This Terraform project creates a Lambda function that automatically manages other Lambda functions by identifying and deleting outdated ones based on configurable criteria.

## Project Structure

```
lambda-management/
├── main.tf                           # Root module configuration
├── variables.tf                      # Root module variables
├── outputs.tf                        # Root module outputs
├── terraform.tfvars.example         # Example variables file
├── deploy.sh                        # Deployment script
├── README.md                        # This file
├── modules/
│   └── lambda-manager/
│       ├── main.tf                  # Lambda module main config
│       ├── variables.tf             # Lambda module variables
│       ├── outputs.tf               # Lambda module outputs
│       └── iam.tf                   # IAM policies and roles
└── lambda-code/
    ├── lambda_function.py           # Lambda function source code
    └── requirements.txt             # Python dependencies
```

## Features

- ✅ **Automated Lambda Management**: Scans and deletes outdated Lambda functions
- ✅ **Configurable Retention**: Set custom retention periods (default: 30 days)
- ✅ **Protection Mechanisms**: Name patterns and tags to protect critical functions
- ✅ **Scheduled Execution**: Runs automatically on a configurable schedule
- ✅ **CloudWatch Integration**: Logs and metrics for monitoring
- ✅ **IAM Security**: Least-privilege permissions for safe operation
- ✅ **Flexible Configuration**: Environment-specific settings

## Prerequisites

1. **AWS CLI**: Configured with appropriate credentials
2. **Terraform**: Version >= 1.0
3. **IAM Permissions**: Lambda, IAM, CloudWatch, and EventBridge permissions

### Required AWS Permissions

Your AWS credentials need the following permissions:
- `lambda:*` (for creating and managing Lambda functions)
- `iam:*` (for creating IAM roles and policies)
- `logs:*` (for CloudWatch logs)
- `events:*` (for EventBridge rules)

## Quick Start

### 1. Clone and Configure

```bash
# Navigate to the project directory
cd lambda-management

# Copy and edit the variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
```

### 2. Deploy

```bash
# Option 1: Use the deployment script (recommended)
chmod +x deploy.sh
./deploy.sh deploy

# Option 2: Manual deployment
terraform init
terraform plan
terraform apply
```

### 3. Verify Deployment

```bash
# Check outputs
terraform output

# Verify Lambda function
aws lambda get-function --function-name lambda-function-manager

# Check CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/lambda-function-manager"
```

## Configuration

### terraform.tfvars

```hcl
# AWS Configuration
aws_region  = "us-east-1"
environment = "prod"

# Lambda Function Configuration
function_name       = "lambda-function-manager"
retention_days      = 30              # Delete functions older than 30 days
schedule_expression = "rate(7 days)"  # Run weekly
memory_size        = 256
timeout            = 300

# Logging
log_retention_days = 14

# Tags
tags = {
  Owner       = "DevOps Team"
  Environment = "Production"
  Purpose     = "Lambda Management"
}
```

### Protection Rules

The Lambda function includes built-in protection for:

1. **Name Patterns** (modify in `lambda_function.py`):
   - `.*-prod-.*` - Production functions
   - `lambda-function-manager.*` - The manager function itself
   - `.*-critical-.*` - Critical functions

2. **Tags** (functions with these tags are protected):
   - `Protected`
   - `Critical`
   - `DoNotDelete`

## Usage

### Manual Invocation

```bash
# Invoke the function manually
aws lambda invoke \
  --function-name lambda-function-manager \
  --payload '{}' \
  response.json

# View the response
cat response.json
```

### Monitoring

```bash
# View function logs
aws logs tail /aws/lambda/lambda-function-manager --follow

# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace "Lambda/Management" \
  --metric-name "DeletedFunctions" \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum
```

### Schedule Modification

To change the execution schedule, update the `schedule_expression` variable:

```hcl
# Daily execution
schedule_expression = "rate(1 day)"

# Weekly on Sundays at 2 AM UTC
schedule_expression = "cron(0 2 ? * SUN *)"

# Monthly on the 1st at midnight
schedule_expression = "cron(0 0 1 * ? *)"
```

## Advanced Configuration

### Custom Protection Rules

Modify `lambda_function.py` to add custom protection logic:

```python
# Add custom name patterns
protected_patterns = [
    r'.*-prod-.*',
    r'.*-staging-.*',
    r'my-important-function.*',
]

# Add custom tag checks
protected_tags = ['Protected', 'Critical', 'DoNotDelete', 'Production']
```

### Environment-Specific Deployments

```bash
# Development environment
terraform workspace new dev
terraform apply -var="environment=dev" -var="retention_days=7"

# Production environment
terraform workspace new prod
terraform apply -var="environment=prod" -var="retention_days=90"
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Check AWS credentials
   aws sts get-caller-identity
   
   # Verify IAM permissions
   aws iam get-user
   ```

2. **Function Not Deleting Functions**
   ```bash
   # Check function logs
   aws logs tail /aws/lambda/lambda-function-manager
   
   # Verify IAM permissions for the Lambda role
   aws iam get-role-policy --role-name lambda-function-manager-role --policy-name lambda-function-manager-management-policy
   ```

3. **Schedule Not Working**
   ```bash
   # Check EventBridge rule
   aws events describe-rule --name lambda-function-manager-schedule
   
   # Check rule targets
   aws events list-targets-by-rule --rule lambda-function-manager-schedule
   ```

### Debugging

Enable debug logging by setting the `LOG_LEVEL` environment variable:

```hcl
environment {
  variables = {
    LOG_LEVEL = "DEBUG"
  }
}
```

## Security Considerations

1. **Least Privilege**: The function only has permissions it needs
2. **Protection Mechanisms**: Multiple layers protect critical functions
3. **Audit Logging**: All actions are logged to CloudWatch
4. **Tag-Based Protection**: Use tags to mark important functions
5. **Environment Isolation**: Separate environments prevent cross-contamination

## Cleanup

To destroy all resources:

```bash
# Using the deployment script
./deploy.sh destroy

# Or manually
terraform destroy
```

## Customization

### Adding Notification

To add SNS notifications when functions are deleted:

1. Create an SNS topic in `main.tf`
2. Add SNS permissions to the IAM policy
3. Modify the Lambda function to publish to SNS

### Integration with Other Tools

- **Terraform Cloud**: Use for team collaboration
- **GitLab CI/CD**: Automate deployments
- **Monitoring**: Integrate with Datadog, New Relic, etc.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review CloudWatch logs
3. Verify IAM permissions
4. Test with a smaller retention period first
