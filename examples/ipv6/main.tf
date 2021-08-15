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
  source = "../.."

  name = "ipv6"
  cidr = "10.0.0.0/16"

  azs              = ["${local.region}a", "${local.region}b"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.103.0/24", "10.0.104.0/24"]

  enable_nat_gateway = false

  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true

  private_subnet_assign_ipv6_address_on_creation = false

  public_subnet_ipv6_prefixes   = [0, 1]
  private_subnet_ipv6_prefixes  = [2, 3]
  database_subnet_ipv6_prefixes = [4, 5]

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
