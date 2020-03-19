resource "aws_s3_bucket" "lambda_s3_bucket" {
  count         = "${var.enable ? 1 : 0}"
  bucket        = "${var.lambda_s3_bucket_name}"
  force_destroy = true
  tags          = "${local.tags}"
}
resource "aws_s3_bucket_object" "lambda_s3_bucket_object" {
  count  = "${var.enable ? 1 : 0}"
  bucket = "${aws_s3_bucket.lambda_s3_bucket.bucket}"
  key    = "${var.lambda_zip_file_shortname}"
  source = "${var.lambda_zip_file_fullname}"
}
