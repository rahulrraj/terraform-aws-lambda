output "lambda_security_group_id" {
  value = "${module.api_resources.security_group_id[0]}"
}
output "secondary_lambda_security_group_ids" {
  value = "${module.secondary_api_resources.security_group_id}"
}

output "lambda_iam_role_name" {
  value = "${aws_iam_role.iam_role_lambda_function.name}"
}

output "lambda_iam_role_arn" {
  value = "${aws_iam_role.iam_role_lambda_function.arn}"
}

output "a_record_name" {
  value = "${var.fqdn}"
}
