output "api_id" {
  value = "${aws_api_gateway_rest_api.api_gateway.*.id}"
}

output "security_group_id" {
  value = "${aws_security_group.lambda_function_security_group.*.id}"
}
