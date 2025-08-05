resource "aws_security_group" "app_sg" {
  name        = "${var.name_prefix}-sg"
  description = "Allow traffic from web tier"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.web_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami
  instance_type = var.instance_type

  network_interfaces {
    security_groups            = [aws_security_group.app_sg.id]
    associate_public_ip_address = false
  }

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.name_prefix}-app" }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name_prefix          = "${var.name_prefix}-asg-"
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.private_subnet_ids
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg"
    propagate_at_launch = true
  }
}