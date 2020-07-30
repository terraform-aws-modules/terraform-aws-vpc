variable "region" {
  description = "The AWS region to create the VPC"
}

variable "environment" {
  description = "The name of the environment (ex. Dev)"
}

variable "vpc_cidr_prefix" {
  description = "The first two parts of the ipv4 cidr block (ex. 10.120)"
}

variable "region_prefix" {
  description = "The abbreviation of the region. i.e. VA, OH, etc."
}

variable "application_name" {
  description = "The name of the application to be used for naming resources"
}
