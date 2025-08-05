resource "aws_security_group" "web_sg" {
  name        = "${var.name_prefix}-sg"
  description = "Allow HTTP/HTTPS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "web_alb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.web_sg.id]
}

resource "aws_lb_target_group" "web_tg" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami
  instance_type = var.instance_type

  network_interfaces {
    security_groups = [aws_security_group.web_sg.id]
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.name_prefix}-web" }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name_prefix          = "${var.name_prefix}-asg-"
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [aws_lb_target_group.web_tg.arn]
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg"
    propagate_at_launch = true
  }
}