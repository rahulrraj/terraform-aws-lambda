output "lambda_security_group_id" {
  description = "AWS security group id of the lambda function"
  value = "${module.api_resources.security_group_id[0]}"
}
output "secondary_lambda_security_group_ids" {
  description = "AWS security group id of the secondar lambda function. Its an array so id can be accessed using 0 index"
  value = "${module.secondary_api_resources.security_group_id}"
}

output "lambda_iam_role_name" {
  description = "IAM Role name, user by the lambda function"
  value = "${aws_iam_role.iam_role_lambda_function.name}"
}

output "lambda_iam_role_arn" {
  description = "IAM Role arn, user by the lambda function"
  value = "${aws_iam_role.iam_role_lambda_function.arn}"
}

output "a_record_name" {
  description = "Route 53 A-Record Name"
  value = "${var.fqdn}"
}
