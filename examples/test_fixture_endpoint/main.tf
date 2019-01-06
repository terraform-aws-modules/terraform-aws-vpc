provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source              = "../.."
  name                = "test-example"
  cidr                = "10.0.0.0/16"
  azs                 = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets      = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway  = true
  single_nat_gateway  = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_s3_endpoint   = true
  enable_ssm_endpoint  = true

  ssm_endpoint_security_group_ids = ["${aws_security_group.input_interface_endpoint.id}"]

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

resource "aws_security_group" "input_interface_endpoint" {
  name        = "input_interface_endpoint"
  description = "Allow https inbound traffic"

  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}
