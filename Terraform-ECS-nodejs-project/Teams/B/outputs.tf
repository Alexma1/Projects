# 📤 Team B ECS-Only Infrastructure Outputs

# Security Group Outputs
output "security_group_id" {
  description = "ID of the created security group"
  value       = module.security_group.security_group_id
}

output "security_group_name" {
  description = "Name of the created security group"
  value       = module.security_group.security_group_name
}

# 🐳 ECS Outputs
output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = module.ecs.service_arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = module.ecs.task_definition_arn
}

output "ecs_task_definition_family" {
  description = "Family of the ECS task definition"
  value       = module.ecs.task_definition_family
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = module.ecs.execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.ecs.task_role_arn
}

output "ecs_log_group_name" {
  description = "Name of the ECS CloudWatch log group"
  value       = module.ecs.log_group_name
}

output "ecs_log_group_arn" {
  description = "ARN of the ECS CloudWatch log group"
  value       = module.ecs.log_group_arn
}
