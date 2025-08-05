variable "aws_region"      { type = string }
variable "vpc_cidr"        { type = string }
variable "public_subnets"  { type = list(string) }
variable "private_subnets" { type = list(string) }

variable "instance_ami"         { type = string }
variable "instance_type"        { type = string }
variable "desired_capacity_web" { type = number }
variable "desired_capacity_app" { type = number }
variable "min_size"             { type = number }
variable "max_size"             { type = number }

variable "db_username"       { type = string }
variable "db_password"       { type = string }
variable "db_allocated_storage" { type = number }
variable "db_engine"         { type = string }
variable "db_instance_class" { type = string }

variable "zone_name"   { type = string }
variable "record_name" { type = string }