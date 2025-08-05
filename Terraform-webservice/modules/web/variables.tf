variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "desired_capacity" {
  type = number
  default     = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "name_prefix" {
  type    = string
  default = "web"
}