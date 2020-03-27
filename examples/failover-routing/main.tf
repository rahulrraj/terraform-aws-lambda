provider "aws" {
  region = "us-east-1"
}

module "api_with_failover_routing" {
  providers {
    aws           = "aws"
    aws.dns       = "aws"
    aws.secondary = "aws"
  }

  source = "../../"

  #source                      = "rahulrraj/lambda/aws"
  #version                     = "0.0.2"
  name = "${var.name}"

  vpc_id                    = "${var.aws_vpc_id}"
  secondary_vpc_id          = "${var.aws_secondary_vpc_id}"
  subnets                   = ["${var.aws_vpc_subnet_primary}", "${var.aws_vpc_subnet_secondary}"]
  secondary_subnets         = ["${var.aws_vpc_subnet_dr_primary}", "${var.aws_vpc_subnet_dr_secondary}"]
  fqdn                      = "${var.name}.${var.domain}"
  zone_id                   = "${var.aws_zone_id}"
  routing_policy            = "failover"
  lambda_zip_file_fullname  = "${local.lambda_zip_file_fullname}"
  lambda_zip_file_shortname = "${local.lambda_zip_file_shortname}"
  department_tag            = "${var.department}"
  project_tag               = "${var.project}"
  env_qualifier             = "${var.env_qualifier}"
  env_qualifier_no_dot      = "${var.env_qualifier_no_dot}"
}
