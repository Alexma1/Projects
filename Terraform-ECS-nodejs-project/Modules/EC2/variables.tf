# 📝 EC2 Module Variables

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "my-ec2-instance"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be created"
  type        = string
  default     = "vpc-0b0cb142743067858"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet (optional filter)"
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the AWS key pair for SSH access"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Name        = "MyEC2Instance"
    Environment = "Dev"
  }
}
