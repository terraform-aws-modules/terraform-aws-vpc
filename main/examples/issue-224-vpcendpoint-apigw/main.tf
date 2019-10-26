provider "aws" {
  region = "us-east-1"
}

#################
# Security group
#################
module "http_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 3.0"

  name        = "http-sg"
  description = "Security group with HTTP ports open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

######
# VPC
######
module "vpc" {
  source = "../../"

  name = "vpcendpoint-example"

  cidr = "10.15.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.15.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC endpoint for API gateway
  enable_apigw_endpoint              = true
  apigw_endpoint_security_group_ids  = [module.http_sg.this_security_group_id]
  apigw_endpoint_private_dns_enabled = true

  tags = {
    Owner       = "user"
    Environment = "test"
    Name        = "test-224"
  }
}

