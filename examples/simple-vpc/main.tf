provider "aws" {
  region = "eu-west-1"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "../../"

  name = "vpc-terratest"

  cidr = "10.120.0.0/16"

  azs                     = ["eu-west-1a", "eu-west-1c"]
  compute_public_subnets  = ["10.120.3.0/24", "10.120.4.0/24"]
  compute_private_subnets = ["10.120.0.0/24", "10.120.1.0/24"]
  lb_subnets              = ["10.120.5.0/24", "10.120.6.0/24"]
  database_subnets        = ["10.120.7.0/24", "10.120.8.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = true

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
