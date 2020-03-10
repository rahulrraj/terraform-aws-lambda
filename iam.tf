resource "aws_iam_role" "iam_role_lambda_function" {
  name = "${var.name}-lambdafunction"
  assume_role_policy= "${file("${path.module}/template/lambda-assume-role-policy.json")}"
  tags = "${local.tags}"
}

resource "aws_iam_role_policy" "iam_role_policy_lambda_function" {
  name = "${var.name}-lambda-function"
  role = "${aws_iam_role.iam_role_lambda_function.name}"
  policy= "${file("${path.module}/template/lambda-function-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_function" {
  role       = "${aws_iam_role.iam_role_lambda_function.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

