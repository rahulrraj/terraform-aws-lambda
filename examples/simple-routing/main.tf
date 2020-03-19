module "api_with_simple_routing" {
  providers {
    aws             = "aws"
    aws.dns         = "aws.dns"
    aws.secondary   = "aws.ohio"
  }
  source                      = "../../"
  #source                      = "rahulrraj/lambda/aws"
  #version                     = "0.0.2"
  name                        = "${var.name}-simple"
  vpc_id                      = "${var.aws_vpc_id}"
  subnets                     = ["${var.aws_vpc_subnet_primary}", "${var.aws_vpc_subnet_secondary}"]
  fqdn                        = "${var.name}-simple.${var.acadian_domain}"
  zone_id                     = "${var.aws_zone_id}"
  lambda_zip_file_fullname    = "${local.lambda_zip_file_fullname}"
  lambda_zip_file_shortname   = "${local.lambda_zip_file_shortname}"
  #aws_lambda_function_role_arn = "${aws_iam_role.iam_role_lambda_function.arn}"
  department_tag              = "${var.department}"
  project_tag                 = "${var.project}"
  env_qualifier               = "${var.env_qualifier}"
  env_qualifier_no_dot        = "${var.env_qualifier_no_dot}"
}
