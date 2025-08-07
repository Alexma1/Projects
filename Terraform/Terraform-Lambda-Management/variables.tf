# Root Module Variables
# These variables configure the Lambda function management infrastructure

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "lambda-function-manager"
}

variable "retention_days" {
  description = "Number of days to retain Lambda functions before deletion"
  type        = number
  default     = 30
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression for automated execution"
  type        = string
  default     = "rate(7 days)"  # Run weekly
}

variable "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Amount of time in seconds for the Lambda function timeout"
  type        = number
  default     = 300
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
