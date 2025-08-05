# 📤 EC2 Module Outputs

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.this.arn
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.this.public_dns
}

output "subnet_id" {
  description = "ID of the subnet where the instance is launched"
  value       = data.aws_subnet.this.id
}

output "vpc_id" {
  description = "ID of the VPC where the instance is launched"
  value       = var.vpc_id
}

output "ami_id" {
  description = "ID of the AMI used for the instance"
  value       = data.aws_ami.amazon_linux2.id
}
