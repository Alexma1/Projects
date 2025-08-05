output "asg_ids" {
  value = aws_autoscaling_group.app_asg.*.id
}