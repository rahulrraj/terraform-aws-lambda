module "api_resources" {
  providers {
    aws     = "aws"
    aws.dns = "aws.dns"
  }

  source                   = "./modules/common"
  name                     = "${var.name}"
  vpc_id                   = "${var.vpc_id}"
  subnets                  = "${var.subnets}"
  aws_lambda_function_role = ["${aws_iam_role.iam_role_lambda_function.*.arn}", "${var.aws_lambda_function_role_arn}"]

  #passing role as list may seems unnecessary, but for the case when module is not creating IAM role and calling module passes it aws_iam_role.iam_role_lambda_function.arn will throw error as IAM role is not created
  #aws_lambda_function_role    = "${var.aws_lambda_function_role_arn == "" ? aws_iam_role.iam_role_lambda_function.arn : var.aws_lambda_function_role_arn}"
  handler = "${var.handler}"

  runtime                   = "${var.runtime}"
  timeout                   = "${var.timeout}"
  memory_size               = "${var.memory_size}"
  stage_name                = "${var.stage_name}"
  enable_tracing_mode       = "${var.enable_tracing_mode}"
  lambda_s3_bucket_name     = "${local.lambda_s3_bucket_name}"
  lambda_zip_file_fullname  = "${var.lambda_zip_file_fullname}"
  lambda_zip_file_shortname = "${var.lambda_zip_file_shortname}"
  department_tag            = "${var.department_tag}"
  project_tag               = "${var.project_tag}"
  env_qualifier             = "${var.env_qualifier}"
  env_qualifier_no_dot      = "${var.env_qualifier_no_dot}"
}

module "secondary_api_resources" {
  enable = "${var.routing_policy == "failover"}"

  providers {
    aws     = "aws.secondary"
    aws.dns = "aws.dns"
  }

  source                    = "./modules/common"
  name                      = "${var.name}"
  vpc_id                    = "${var.secondary_vpc_id}"
  subnets                   = "${var.secondary_subnets}"
  aws_lambda_function_role  = ["${aws_iam_role.iam_role_lambda_function.*.arn}", "${var.aws_lambda_function_role_arn}"]
  handler                   = "${var.handler}"
  runtime                   = "${var.runtime}"
  enable_tracing_mode       = "${var.enable_tracing_mode}"
  timeout                   = "${var.timeout}"
  memory_size               = "${var.memory_size}"
  stage_name                = "${var.stage_name}"
  lambda_zip_file_fullname  = "${var.lambda_zip_file_fullname}"
  lambda_zip_file_shortname = "${var.lambda_zip_file_shortname}"
  lambda_s3_bucket_name     = "${local.secondary_lambda_s3_bucket_name}"
  department_tag            = "${var.department_tag}"
  project_tag               = "${var.project_tag}"
  env_qualifier             = "${var.env_qualifier}"
  env_qualifier_no_dot      = "${var.env_qualifier_no_dot}"
}
