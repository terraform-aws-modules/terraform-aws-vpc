provider "aws" {
  region = "us-east-1"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "../../"

  name = "complete-example"

  cidr = "10.15.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.15.1.0/24"]

  # VPC endpoint for API gateway
  enable_apigw_endpoint              = true
  apigw_endpoint_security_group_ids  = [data.aws_security_group.default.id]
  apigw_endpoint_private_dns_enabled = true

  tags = {
    Owner       = "user"
    Environment = "test"
    Name        = "test-224"
  }
}

