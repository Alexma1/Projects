# 🚀 EC2 Instance Resource (Direct creation without external module)
resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux2.id
  instance_type              = var.instance_type
  subnet_id                  = data.aws_subnet.this.id
  associate_public_ip_address = var.associate_public_ip
  vpc_security_group_ids     = var.security_group_ids
  key_name                   = var.key_name

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}

# 🔍 Discover a specific subnet
data "aws_subnet" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "availabilityZone"
    values = [var.availability_zone]
  }

  # Optional CIDR block filter
  dynamic "filter" {
    for_each = var.subnet_cidr_block != null ? [1] : []
    content {
      name   = "cidrBlock"
      values = [var.subnet_cidr_block]
    }
  }
}

# 🧬 Amazon Linux 2 AMI (latest)
data "aws_ami" "amazon_linux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
