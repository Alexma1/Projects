resource "aws_iam_role" "instance_role" {
  name               = "instance-role"
  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "attach_ec2" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}