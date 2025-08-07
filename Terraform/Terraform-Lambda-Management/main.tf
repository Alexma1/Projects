# Root Terraform Configuration
# This file configures the main infrastructure using the lambda-manager module

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Lambda Management"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Create a zip file for the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-code"
  output_path = "${path.module}/lambda-function.zip"
}

# Use the lambda-manager module to create the Lambda function
module "lambda_manager" {
  source = "./modules/lambda-manager"

  function_name               = var.function_name
  retention_days             = var.retention_days
  schedule_expression        = var.schedule_expression
  environment                = var.environment
  lambda_zip_file           = data.archive_file.lambda_zip.output_path
  lambda_source_code_hash   = data.archive_file.lambda_zip.output_base64sha256
  
  # Optional variables
  memory_size    = var.memory_size
  timeout        = var.timeout
  runtime        = var.runtime
  
  tags = {
    Environment = var.environment
    Purpose     = "Lambda Function Management"
  }
}

# CloudWatch Log Group for the Lambda function (optional - module creates it, but this shows explicit creation)
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Purpose     = "Lambda Function Logs"
  }
}
