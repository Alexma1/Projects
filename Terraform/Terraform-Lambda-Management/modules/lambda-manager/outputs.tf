# Lambda Manager Module Outputs
# These outputs provide information about the created resources

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda_manager.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda_manager.function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.lambda_manager.invoke_arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda function's IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "Name of the Lambda function's IAM role"
  value       = aws_iam_role.lambda_role.name
}

output "cloudwatch_event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule"
  value       = aws_cloudwatch_event_rule.lambda_schedule.arn
}

output "cloudwatch_event_rule_name" {
  description = "Name of the CloudWatch Event Rule"
  value       = aws_cloudwatch_event_rule.lambda_schedule.name
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

output "lambda_function_url" {
  description = "Lambda function URL (if enabled)"
  value       = var.enable_function_url ? aws_lambda_function_url.lambda_url[0].function_url : null
}

output "lambda_function_last_modified" {
  description = "Date the Lambda function was last modified"
  value       = aws_lambda_function.lambda_manager.last_modified
}

output "lambda_function_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.lambda_manager.version
}
