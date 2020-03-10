############################################################################
# Certificate Validation
############################################################################
resource "aws_route53_record" "cname" {
  provider = "aws.dns"
  name     = "${aws_acm_certificate.apigateway_certificate.domain_validation_options.0.resource_record_name}"
  type     = "${aws_acm_certificate.apigateway_certificate.domain_validation_options.0.resource_record_type}"
  zone_id  = "${var.zone_id}"
  records  = ["${aws_acm_certificate.apigateway_certificate.domain_validation_options.0.resource_record_value}"]
  ttl      = 60
}
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = "${aws_acm_certificate.apigateway_certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.cname.fqdn}"]
}
resource "aws_acm_certificate_validation" "secondary_acm_certificate_validation" {
  count                   = "${var.routing_policy == "failover" ? 1 : 0}"
  provider                = "aws.secondary"
  certificate_arn         = "${aws_acm_certificate.secondary_apigateway_certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.cname.fqdn}"]
}

############################################################################
# A Record
############################################################################
resource "aws_route53_record" "simple_routing_policy_a_record" {
  count     = "${var.routing_policy == "simple" ? 1 : 0}"
  provider  = "aws.dns"
  name      = "${var.fqdn}"
  type      = "A"
  zone_id   = "${var.zone_id}"
  
  alias {
    name                   = "${aws_api_gateway_domain_name.api_gateway_domain_name.regional_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.api_gateway_domain_name.regional_zone_id}"
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "primary_a_record" {
  count           = "${var.routing_policy == "failover" ? 1 : 0}"
  provider        = "aws.dns"
  name            = "${var.fqdn}"
  type            = "A"
  zone_id         = "${var.zone_id}"
  set_identifier  = "${var.name}"
  health_check_id = "${aws_route53_health_check.health-check.id}"
  failover_routing_policy {
    type = "PRIMARY"
  }
  
  alias {
    name                   = "${aws_api_gateway_domain_name.api_gateway_domain_name.regional_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.api_gateway_domain_name.regional_zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "secondary_a_record" {
  count           = "${var.routing_policy == "failover" ? 1 : 0}"
  provider        = "aws.dns"
  name            = "${var.fqdn}"
  type            = "A"
  zone_id         = "${var.zone_id}"
  set_identifier  = "${var.name}-secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }
  alias {
    name                   = "${aws_api_gateway_domain_name.secondary_api_gateway_domain_name.regional_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.secondary_api_gateway_domain_name.regional_zone_id}"
    evaluate_target_health = false
  }
}

############################################################################
# Health Check
############################################################################

resource "aws_route53_health_check" "health-check" {
  count             = "${var.routing_policy == "failover" ? 1 : 0}"
  provider          = "aws.dns"
  fqdn              = "${module.api_resources.api_id[0]}.execute-api.us-east-1.amazonaws.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "${var.health_check_resource_path}"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "${var.name}-health-check"
  }
}
