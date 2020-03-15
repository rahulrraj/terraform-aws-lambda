############################################################################
# Primary
############################################################################
resource "aws_acm_certificate" "apigateway_certificate" {
  domain_name       = "${var.fqdn}"
  validation_method = "DNS"
  tags              = "${local.tags}"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_domain_name" "api_gateway_domain_name" {
  depends_on                = ["aws_acm_certificate_validation.acm_certificate_validation"]
  regional_certificate_arn  = "${aws_acm_certificate.apigateway_certificate.arn}"
  domain_name               = "${aws_acm_certificate.apigateway_certificate.domain_name}"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_base_path_mapping" "api_gateway_base_path_mapping" {
  api_id      = "${module.api_resources.api_id[0]}"
  stage_name  = "all"
  domain_name = "${aws_api_gateway_domain_name.api_gateway_domain_name.domain_name}"
}

############################################################################
# Secondary
############################################################################
resource "aws_acm_certificate" "secondary_apigateway_certificate" {
  count             = "${var.routing_policy == "failover" ? 1 : 0}"
  provider          = "aws.secondary"
  domain_name       = "${var.fqdn}"
  validation_method = "DNS"
  tags              = "${local.tags}"

  lifecycle {
    create_before_destroy = true
  }
  
}
resource "aws_api_gateway_domain_name" "secondary_api_gateway_domain_name" {
  count                     = "${var.routing_policy == "failover" ? 1 : 0}"
  depends_on                = ["aws_acm_certificate_validation.secondary_acm_certificate_validation"]
  provider                  = "aws.secondary"
  regional_certificate_arn  = "${aws_acm_certificate.secondary_apigateway_certificate.arn}"
  domain_name               = "${aws_acm_certificate.secondary_apigateway_certificate.domain_name}"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_base_path_mapping" "secondary_api_gateway_base_path_mapping" {
  count       = "${var.routing_policy == "failover" ? 1 : 0}" 
  provider    = "aws.secondary"
  api_id      = "${module.secondary_api_resources.api_id[0]}"
  stage_name  = "${var.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.secondary_api_gateway_domain_name.domain_name}"
}