# 📝 Team B ECS-Only Infrastructure Variables

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "sg_name" {
  description = "Name for the security group"
  type        = string
  default     = "team-b-ecs-sg"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
  default     = "vpc-0b0cb142743067858"
}

variable "availability_zone" {
  description = "Availability zone for the ECS service"
  type        = string
  default     = "us-east-1a"
}

# 🐳 ECS Variables
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "team-b-cluster"
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "team-b-service"
}

variable "ecs_task_family" {
  description = "Family name for the ECS task definition"
  type        = string
  default     = "team-b-task"
}

variable "ecs_container_name" {
  description = "Name of the container"
  type        = string
  default     = "node-demo"
}

variable "ecs_container_image" {
  description = "Docker image to run in the container"
  type        = string
  default     = "uya0/node-example-1:node-deploy"  # Node.js application for Team B
}

variable "ecs_container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "ecs_cpu" {
  description = "Number of CPU units for the task"
  type        = string
  default     = "512"  # More CPU for Team B
}

variable "ecs_memory" {
  description = "Amount of memory (in MiB) for the task"
  type        = string
  default     = "1024"  # More memory for Team B
}

variable "ecs_desired_count" {
  description = "Number of instances of the task to run"
  type        = number
  default     = 1  # 1 task with 2 containers = 2 total containers
}

variable "ecs_assign_public_ip" {
  description = "Whether to assign a public IP to the ECS task"
  type        = bool
  default     = true
}

variable "ecs_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true  # Team B has monitoring enabled
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
      value = "production"
    },
    {
      name  = "TEAM"
      value = "B"
    }
  ]
}

# 🐳 Container Definitions for Multiple Images
variable "ecs_container_definitions" {
  description = "Complete container definitions with different images"
  type        = any
  default = [
    {
      name      = "node-app"
      image     = "uya0/node-example-1:node-deploy"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/team-b-task"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "node-app"
        }
      }
      environment = [
        {
          name  = "ENVIRONMENT"
          value = "production"
        },
        {
          name  = "TEAM"
          value = "B"
        },
        {
          name  = "PORT"
          value = "3000"
        }
      ]
    },
    {
      name      = "nginx-proxy"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/team-b-task"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "nginx-proxy"
        }
      }
      environment = [
        {
          name  = "ENVIRONMENT"
          value = "production"
        },
        {
          name  = "TEAM"
          value = "B"
        },
        {
          name  = "PROXY_TARGET"
          value = "localhost:3000"
        }
      ]
    }
  ]
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {
    Team        = "B"
    Environment = "Production"
    Project     = "TeamB-ECS-Only"
    Workload    = "Containerized"
  }
}
