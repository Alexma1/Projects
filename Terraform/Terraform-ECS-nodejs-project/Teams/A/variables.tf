# 📝 Team A Infrastructure Variables

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "sg_name" {
  description = "Name for the security group"
  type        = string
  default     = "team-a-allow-all-sg"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
  default     = "vpc-0b0cb142743067858"
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "team-a-ec2-instance"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "availability_zone" {
  description = "Availability zone for the EC2 instance"
  type        = string
  default     = "us-east-1a"
}

variable "key_name" {
  description = "Name of the AWS key pair for SSH access"
  type        = string
  default     = "team-a-key"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {
    Team        = "A"
    Environment = "Dev"
    Project     = "TeamA-Infrastructure"
  }
}

# 🐳 ECS Variables
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "team-a-cluster"
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "team-a-service"
}

variable "ecs_task_family" {
  description = "Family name for the ECS task definition"
  type        = string
  default     = "team-a-task"
}

variable "ecs_container_name" {
  description = "Name of the container"
  type        = string
  default     = "team-a-container"
}

variable "ecs_container_image" {
  description = "Docker image to run in the container"
  type        = string
  default     = "nginx:latest"
}

variable "ecs_container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "ecs_cpu" {
  description = "Number of CPU units for the task"
  type        = string
  default     = "256"
}

variable "ecs_memory" {
  description = "Amount of memory (in MiB) for the task"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Number of instances of the task to run"
  type        = number
  default     = 1
}

variable "ecs_assign_public_ip" {
  description = "Whether to assign a public IP to the ECS task"
  type        = bool
  default     = true
}

variable "ecs_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = false
}

variable "ecs_environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "ENVIRONMENT"
      value = "development"
    }
  ]
}
