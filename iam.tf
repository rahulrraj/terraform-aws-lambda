resource "aws_iam_role" "iam_role_lambda_function" {
  count              = "${var.create_iam_role ? 1 : 0}"
  name               = "${var.name}-lambdafunction"
  assume_role_policy = "${file("${path.module}/template/lambda-assume-role-policy.json")}"
  tags               = "${local.tags}"
}

//Review to use from the managed policy
//https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html
resource "aws_iam_role_policy" "iam_role_policy_lambda_function" {
  count  = "${var.create_iam_role ? 1 : 0}"
  name   = "${var.name}-lambda-function"
  role   = "${aws_iam_role.iam_role_lambda_function.name}"
  policy = "${file("${path.module}/template/lambda-function-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_function" {
  count      = "${var.create_iam_role ? 1 : 0}"
  role       = "${aws_iam_role.iam_role_lambda_function.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
