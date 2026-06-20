resource "aws_iam_instance_profile" "instance-profile" {
  name = "saitej-profile"
  role = aws_iam_role.iam-role.name
}
