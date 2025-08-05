# Variables for Security Group Module

variable "sg_name" {
  description = "Docker-SG"
  type        = string
}

variable "description" {
  description = "Description for the security group"
  type        = string
  default     = "Security Group that allows all inbound and outbound traffic"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the security group"
  type        = map(string)
  default     = {}
}
