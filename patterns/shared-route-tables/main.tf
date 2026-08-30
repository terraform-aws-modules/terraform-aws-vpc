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

module "vpc" {
  source = "../../"

  name = local.name
  cidr = local.vpc_cidr
  azs  = local.azs

  create_igw = true

  tags = local.tags
}

################################################################################
# Shared: identical routes, so one table with a name of its own
#
# The routes are declared once on the group, which is what makes it one table
################################################################################

module "shared" {
  source = "../../modules/subnets"

  name   = "${local.name}-shared"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i)
  } }

  map_public_ip_on_launch = true

  # each of these hosts a NAT gateway for the tier below
  create_nat_gateway = true

  # the generated name is overridden on the one table the group creates
  route_table_tags = { Name = "${local.name}-public-egress" }

  routes = {
    igw = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      gateway_id                  = module.vpc.igw_id
    }
  }

  tags = local.tags
}

################################################################################
# Per subnet: routes differ by zone, so a shared table cannot express them
#
# The routes move inside the subnet entries, and a table per subnet follows from that
################################################################################

module "per_az" {
  source = "../../modules/subnets"

  name   = "${local.name}-per-az"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i + 8)

    # each table is named for the zone it serves, which a group-wide tag cannot do
    route_table_tags = { Name = "${local.name}-per-az-${az}" }

    routes = {
      nat = {
        destination_ipv4_cidr_block = "0.0.0.0/0"
        nat_gateway_id              = module.shared.nat_gateway_ids[az]
      }
    }
  } }

  tags = local.tags
}
