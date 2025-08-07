# 📝 ECS Module Variables

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "task_family" {
  description = "Family name for the ECS task definition"
  type        = string
}

variable "container_name" {
  description = "Name of the container (used for backward compatibility)"
  type        = string
}

variable "container_image" {
  description = "Docker image to run in the container (used for backward compatibility)"
  type        = string
  default     = "nginx:latest"
}

variable "container_definitions" {
  description = "Complete container definitions for the task"
  type        = any
  default     = null
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "cpu" {
  description = "Number of CPU units for the task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Amount of memory (in MiB) for the task"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of instances of the task to run"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "VPC ID where ECS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS service"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS service"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the task"
  type        = bool
  default     = true
}

variable "container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "target_group_arn" {
  description = "ARN of the load balancer target group (optional)"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
