# Root Module Outputs
# These outputs provide information about the created resources

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_manager.lambda_function_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_manager.lambda_function_name
}

output "lambda_function_role_arn" {
  description = "ARN of the Lambda function's IAM role"
  value       = module.lambda_manager.lambda_role_arn
}

output "cloudwatch_event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule"
  value       = module.lambda_manager.cloudwatch_event_rule_arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = module.lambda_manager.log_group_name
}

output "lambda_function_url" {
  description = "Lambda function invoke URL (if enabled)"
  value       = module.lambda_manager.lambda_function_url
  sensitive   = true
}
