module "api_resources" {
  providers {
    aws             = "aws"
    aws.dns         = "aws.dns"
  }
  source                      = "./modules/common"
  name                        = "${var.name}"
  vpc_id                      = "${var.vpc_id}"
  subnets                     = "${var.subnets}"
  aws_lambda_function_role    = "${aws_iam_role.iam_role_lambda_function.arn}"
  handler                     = "${var.handler}"
  runtime                     = "${var.runtime}"
  timeout                     = "${var.timeout}"
  memory_size                 = "${var.memory_size}"
  stage_name                  = "${var.stage_name}"
  enable_tracing_mode         = "${var.enable_tracing_mode}"
  s3_bucket                   = "${aws_s3_bucket.lambda_s3_bucket.bucket}"
  s3_key                      = "${var.lambda_zip_file_shortname}"
  department_tag              = "${var.department_tag}"
  project_tag                 = "${var.project_tag}"
  env_qualifier               = "${var.env_qualifier}"
  env_qualifier_no_dot        = "${var.env_qualifier_no_dot}"
  
}

module "secondary_api_resources" {
  enable    = "${var.routing_policy == "failover"}"
  providers {
    aws             = "aws.secondary"
    aws.dns         = "aws.dns"

  }
  source                      = "./modules/common"
  name                        = "${var.name}"
  vpc_id                      = "${var.secondary_vpc_id}"
  subnets                     = "${var.secondary_subnets}"
  aws_lambda_function_role    = "${aws_iam_role.iam_role_lambda_function.arn}"
  handler                     = "${var.handler}"
  runtime                     = "${var.runtime}"
  enable_tracing_mode         = "${var.enable_tracing_mode}"
  timeout                     = "${var.timeout}"
  memory_size                 = "${var.memory_size}"
  stage_name                  = "${var.stage_name}"
  #s3_bucket                   = "${local.secondary_lambda_s3_bucket_name}"
  s3_bucket                   = "${var.routing_policy == "failover" ? aws_s3_bucket.secondary_lambda_s3_bucket.bucket : ""}"
  
  s3_key                      = "${var.lambda_zip_file_shortname}"
  department_tag              = "${var.department_tag}"
  project_tag                 = "${var.project_tag}"
  env_qualifier               = "${var.env_qualifier}"
  env_qualifier_no_dot        = "${var.env_qualifier_no_dot}"
}

