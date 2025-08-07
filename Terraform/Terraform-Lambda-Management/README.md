# Lambda Function Management Terraform Project

This project creates a Lambda function that monitors and manages other Lambda functions by identifying and deleting outdated or older versions.

## Project Structure

```
lambda-management/
├── main.tf                 # Root module configuration
├── variables.tf            # Root module variables
├── outputs.tf              # Root module outputs
├── terraform.tfvars        # Variable values
├── modules/
│   └── lambda-manager/
│       ├── main.tf         # Lambda module main configuration
│       ├── variables.tf    # Lambda module variables
│       ├── outputs.tf      # Lambda module outputs
│       └── iam.tf          # IAM policies and roles
└── lambda-code/
    ├── lambda_function.py  # Lambda function source code
    └── requirements.txt    # Python dependencies
```

## Features

- Creates a Lambda function with proper IAM permissions
- Function scans for outdated Lambda functions based on configurable criteria
- Automated cleanup of old Lambda function versions
- CloudWatch logging and monitoring
- Configurable retention policies

## Usage

1. Configure variables in `terraform.tfvars`
2. Run `terraform init`
3. Run `terraform plan`
4. Run `terraform apply`

## Variables

- `function_name`: Name of the Lambda function
- `retention_days`: Number of days to retain Lambda functions
- `schedule_expression`: CloudWatch Events schedule for automated execution
