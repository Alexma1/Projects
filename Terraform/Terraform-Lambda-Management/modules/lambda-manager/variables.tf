# Lambda Manager Module Variables
# These variables are passed from the root module

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "retention_days" {
  description = "Number of days to retain Lambda functions before deletion"
  type        = number
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression for automated execution"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "lambda_zip_file" {
  description = "Path to the Lambda function zip file"
  type        = string
}

variable "lambda_source_code_hash" {
  description = "Base64-encoded SHA256 hash of the Lambda zip file"
  type        = string
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

variable "enable_function_url" {
  description = "Enable Lambda function URL for direct invocation"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
