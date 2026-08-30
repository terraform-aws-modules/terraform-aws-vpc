provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Pattern    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source = "../../"

  name = local.name
  cidr = local.vpc_cidr

  azs = local.azs

  # a regional NAT gateway needs no public subnet, but the VPC still needs a gateway:
  # AWS gives the NAT gateway its own route table, pre-configured with a route to it
  create_igw = true

  # scoped to the VPC rather than to a subnet, so it has no subnet to sit in
  create_regional_nat_gateway = true

  tags = local.tags
}


################################################################################
# Private Subnets
#
# One route table for every zone, because every subnet routes to the same gateway ID
################################################################################

module "private" {
  source = "../../modules/subnets"

  name   = "${local.name}-private"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i)
  } }

  # a regional NAT gateway is one gateway ID for every zone, so the group's routes are
  # identical and a single table is created and shared
  routes = {
    nat = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      nat_gateway_id              = module.vpc.regional_nat_gateway_id
    }
  }

  tags = local.tags
}
