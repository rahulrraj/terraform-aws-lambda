############################################################################
# Primary
############################################################################
resource "aws_s3_bucket" "lambda_s3_bucket" {
  bucket        = "${local.lambda_s3_bucket_name}"
  force_destroy = true
  tags          = "${local.tags}"
}
resource "aws_s3_bucket_object" "lambda_s3_bucket_object" {
  bucket = "${aws_s3_bucket.lambda_s3_bucket.bucket}"
  key    = "${var.lambda_zip_file_shortname}"
  source = "${var.lambda_zip_file_fullname}"
}
############################################################################
# Secondary
############################################################################
resource "aws_s3_bucket" "secondary_lambda_s3_bucket" {

  count         = "${var.routing_policy == "failover" ? 1 : 0}"
  provider      = "aws.secondary"
  bucket        = "${local.secondary_lambda_s3_bucket_name}"
  force_destroy = true
  tags          = "${local.tags}"
}
resource "aws_s3_bucket_object" "secondary_lambda_s3_bucket_object" {
  count     = "${var.routing_policy == "failover" ? 1 : 0}"
  provider  = "aws.secondary"
  bucket    = "${aws_s3_bucket.secondary_lambda_s3_bucket.bucket}"
  key       = "${var.lambda_zip_file_shortname}"
  source    = "${var.lambda_zip_file_fullname}"
}