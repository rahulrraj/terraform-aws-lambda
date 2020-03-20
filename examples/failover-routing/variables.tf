locals {
  lambda_zip_file_fullname    = "../artifacts/deploy-package.zip"
  lambda_zip_file_shortname    = "deploy-package.zip"
}
variable "name" {default = "my-example"}
variable "aws_vpc_id" {}
variable "aws_secondary_vpc_id" {}
variable "aws_vpc_subnet_primary" {}
variable "aws_vpc_subnet_secondary" {}
variable "aws_vpc_subnet_dr_primary" {}
variable "aws_vpc_subnet_dr_secondary" {}
variable "domain" {default = "my-domain"}
variable "aws_zone_id" {}
variable "department" {default = "my-department"}
variable "project" {default = "my-project"}
variable "env_qualifier" {default = "dev."}
variable "env_qualifier_no_dot" {default = "dev"}
