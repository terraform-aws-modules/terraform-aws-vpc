provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  # the zone that hosts the one NAT gateway
  nat_zone = local.azs[0]

  tags = {
    Pattern    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

module "vpc" {
  source = "../../"

  name = local.name
  cidr = local.vpc_cidr
  azs  = local.azs

  # composing subnets outside the module, so ask for the gateway explicitly
  create_igw = true

  tags = local.tags
}

################################################################################
# Public subnets, with a NAT gateway in one zone only
#
# Every public subnet routes to the same internet gateway, so the routes are declared
# once for the group and one route table serves all three
################################################################################

module "public" {
  source = "../../modules/subnets"

  name   = "${local.name}-public"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i)

    # Placement is simply which subnet asks for one
    create_nat_gateway = az == local.nat_zone
  } }

  map_public_ip_on_launch = true

  routes = {
    igw = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      gateway_id                  = module.vpc.igw_id
    }
  }

  tags = local.tags
}

################################################################################
# Private subnets, all sharing one route table to the one gateway
#
# The target is the same gateway for every zone, so the routes stay identical and the
# group keeps a single table
################################################################################

module "private" {
  source = "../../modules/subnets"

  name   = "${local.name}-private"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i + 8)
  } }

  routes = {
    nat = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      nat_gateway_id              = module.public.nat_gateway_ids[local.nat_zone]
    }
  }

  tags = local.tags
}
