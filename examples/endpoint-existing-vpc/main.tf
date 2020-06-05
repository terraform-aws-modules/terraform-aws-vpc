provider "aws" {
  region = "ap-southeast-2"
}

data "aws_vpc" "existing_vpc" {
  id = "${var.vpc_id}"
}

data "aws_security_group" "endpoint_sg" {
  id = "${var.securitygoup_id}"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.existing_vpc.id
}

module "vpc_endpoints" {
  source = "../../"

  create_vpc                        = false
  use_existing_vpc_id_for_endpoints = true 
  vpc_id                            = data.aws_vpc.existing_vpc.id

  enable_ec2_endpoint               = true
  ec2_endpoint_security_group_ids   = [data.aws_security_group.endpoint_sg.id]
  ec2_endpoint_subnet_ids           = data.aws_subnet_ids.subnets.ids

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}