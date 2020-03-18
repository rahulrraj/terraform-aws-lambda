variable "enable"{
  default = true
}

############# Product Tags #################
variable "name" {}

variable "department_tag" {}

variable "project_tag" {}

variable env_qualifier {
  description = "Environment Qualifier. .dev, .qa, .uat, .prod"
}

variable "env_qualifier_no_dot" {
  description = "Environment Qualifier: dev, qa, uat, prod"
}

############# VPC & Subnets ################
variable "vpc_id" {}

variable "subnets" {
  type = "list"
}

############### Lambda ########################
variable "aws_lambda_function_role" {}

variable "handler" {
  default = "not-required"
}
variable "runtime" {
  description = "Example dotnetcore2.1"
  default = "provided"
}
variable "enable_tracing_mode"{
  description = "Can be either PassThrough or Active"
  default = "PassThrough"
}
variable "timeout"{
  default = "300"
}
variable "memory_size"{
  default = "512"
}
variable "lambda_zip_file_fullname" {
  description = "The package file full path name"
}
variable "lambda_zip_file_shortname" {
  description = "The package file full path name"
}
variable "stage_name"{
  default = "all"
}

############### S3 ########################

/*
variable "s3_bucket" {
 
}

variable "s3_key" {
  
}
*/

############### locals ########################
locals {
  tags = {
    Name        = "${var.name}"
    Department  = "${var.department_tag}"
    Project     = "${var.project_tag}"
  }
}