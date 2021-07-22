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

  name = "vpc-with-tgw-example"
  cidr = "10.0.0.0/22"

  azs                     = ["${local.region}a", "${local.region}b", "${local.region}c"]
  transit_gateway_subnets = ["10.0.0.0/28", "10.0.0.16/28", "10.0.0.32/28"]
  public_subnets          = ["10.0.1.0/26", "10.0.1.64/26", "10.0.1.128/26"]
  private_subnets         = ["10.0.2.0/26", "10.0.2.64/26", "10.0.2.128/26"]

  enable_ipv6 = true

  create_igw         = true
  enable_nat_gateway = true
  single_nat_gateway = false

}
