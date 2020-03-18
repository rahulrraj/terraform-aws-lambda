############# Product Tags #################
variable "name" {
  description = "Project name for tags and resource naming"
}
variable "department_tag" {
  description = "Department for resource tags"
}
variable "project_tag" {
  description = "Project for resource tags"
}
variable env_qualifier {
  description = "Environment Qualifier. e.g. .dev, .qa, .uat, .prod"
}
variable "env_qualifier_no_dot" {
  description = "Environment Qualifier: dev, qa, uat, prod"
}
############# VPC & Subnets ################
variable "vpc_id" {
  description = "VPC where primary resources will be created."
}

variable "secondary_vpc_id" {
  description = "(Required for failover routing policy) VPC where failover resources will be created."
  default = ""
}

variable "subnets" {
  description = "VPC subnet IDs."
  type = "list"
}

variable "secondary_subnets" {
  description = "(Required for failover routing policy) VPC subnet IDs for failover resources"
  type = "list"
  default = []
}
############### DNS ########################
variable "fqdn" {
  description = "Fully qualified domain name"
}
variable "zone_id" {}

variable routing_policy {
  description = "simple, failover"
  default = "simple"
}
variable health_check_resource_path {
  default = "/all/hc"
}

############### Lambda ########################
variable "aws_lambda_function_role_arn" {
  default = ""
}
variable "lambda_zip_file_fullname" {
  description = "The package file full path name"
}
variable "lambda_zip_file_shortname" {
  description = "The package file full path name"
}
variable "handler" {
  description = "The handler name of the lambda function. e.g. Acadian.Services.Performance.Reporting.Api.LambdaEntryPoint. For custom runtime this is not required as it is loaded by the main function"
  default = "not-required"
}
variable "runtime" {
  description = "The runtime of the lambda function. e.g. dotnetcore2.1"
  default = "provided"
}
variable "enable_tracing_mode"{
  description = "Can be either PassThrough or Active. Used to enable tracing in  X-Ray."
  default = "PassThrough"
}
variable "timeout"{
  description = "The timeout of the lambda function"
  default = "300"
}
variable "memory_size"{
  description = "Maximum memory capacity of the lambda function"
  default = "512"
}
variable "stage_name"{
  default = "all"
}

############### locals ########################
locals {
  tags = {
    Name        = "${var.name}"
    Department  = "${var.department_tag}"
    Project     = "${var.project_tag}"
  }
  lambda_s3_bucket_name = "${var.name}-lambda-${var.env_qualifier_no_dot}"
  secondary_lambda_s3_bucket_name = "${var.name}-secondary-lambda-${var.env_qualifier_no_dot}"
}

