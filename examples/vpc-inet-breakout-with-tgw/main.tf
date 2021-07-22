provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../"

  name = "vpc-inet-breakout-example"
  cidr = "10.0.0.0/23"

  azs                     = ["${local.region}a", "${local.region}b"]
  public_subnets          = ["10.0.0.0/28", "10.0.0.16/28"]
  transit_gateway_subnets = ["10.0.1.0/28", "10.0.1.16/28"]

  create_igw         = true
  enable_nat_gateway = true
  single_nat_gateway = false

  create_transit_gateway_nat_gateway_route = true

}
