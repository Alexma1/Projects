provider "aws" {
  region = var.aws_region
}

# 🔒 Security Group Module (needed for ECS)
module "security_group" {
  source = "../../Modules/sg"
  
  sg_name = var.sg_name
  vpc_id  = var.vpc_id
  
  tags = var.tags
}

# 🐳 ECS Module Only
module "ecs" {
  source = "../../Modules/ECS"
  
  cluster_name       = var.ecs_cluster_name
  service_name       = var.ecs_service_name
  task_family        = var.ecs_task_family
  container_name     = var.ecs_container_name
  container_image    = var.ecs_container_image
  container_port     = var.ecs_container_port
  cpu                = var.ecs_cpu
  memory             = var.ecs_memory
  desired_count      = var.ecs_desired_count
  
  # Use custom container definitions with multiple images
  container_definitions = var.ecs_container_definitions
  
  vpc_id             = var.vpc_id
  subnet_ids         = [data.aws_subnet.ecs_subnet.id]
  availability_zones = [var.availability_zone]
  security_group_ids = [module.security_group.security_group_id]
  assign_public_ip   = var.ecs_assign_public_ip
  container_insights = var.ecs_container_insights
  
  environment_variables = var.ecs_environment_variables
  
  tags = var.tags
}

# 🔍 Data source for ECS subnet
data "aws_subnet" "ecs_subnet" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "availability-zone"
    values = [var.availability_zone]
  }
}
