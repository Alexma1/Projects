# Lambda Manager Module - Main Configuration
# This module creates a Lambda function that manages other Lambda functions

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Lambda Function
resource "aws_lambda_function" "lambda_manager" {
  filename         = var.lambda_zip_file
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = var.lambda_source_code_hash
  runtime         = var.runtime
  memory_size     = var.memory_size
  timeout         = var.timeout

  environment {
    variables = {
      RETENTION_DAYS = var.retention_days
      ENVIRONMENT    = var.environment
      LOG_LEVEL      = "INFO"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs,
  ]

  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Event Rule for scheduled execution
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "${var.function_name}-schedule"
  description         = "Schedule for Lambda function manager"
  schedule_expression = var.schedule_expression

  tags = var.tags
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "LambdaManagerTarget"
  arn       = aws_lambda_function.lambda_manager.arn
}

# Permission for CloudWatch Events to invoke Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_manager.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}

# Optional: Lambda Function URL for manual invocation
resource "aws_lambda_function_url" "lambda_url" {
  count          = var.enable_function_url ? 1 : 0
  function_name  = aws_lambda_function.lambda_manager.function_name
  authorization_type = "AWS_IAM"

  cors {
    allow_credentials = false
    allow_methods     = ["POST"]
    allow_origins     = ["*"]
    expose_headers    = ["date", "keep-alive"]
    max_age          = 86400
  }
}
