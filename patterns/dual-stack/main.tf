provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  # the well known prefix DNS64 synthesises into, routed at a NAT gateway for NAT64
  nat64_prefix = "64:ff9b::/96"

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

  enable_ipv6 = true
  create_igw  = true

  # the IPv6 equivalent of a NAT gateway: outbound only, stateful, no translation
  create_egress_only_igw = true

  tags = local.tags
}

################################################################################
# Public: dual stack, both defaults at the internet gateway
#
# Both subnets route to the same gateway, so the routes are declared once for the group
# and one route table serves them
################################################################################

module "public" {
  source = "../../modules/subnets"

  name   = "${local.name}-public"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i)
    ipv6_cidr_block   = cidrsubnet(module.vpc.vpc_ipv6_cidr_block, 8, i)

    create_nat_gateway = i == 0
  } }

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  routes = {
    ipv4 = { destination_ipv4_cidr_block = "0.0.0.0/0", gateway_id = module.vpc.igw_id }
    ipv6 = { destination_ipv6_cidr_block = "::/0", gateway_id = module.vpc.igw_id }
  }

  tags = local.tags
}

################################################################################
# Private: dual stack, IPv4 through the NAT gateway, IPv6 outbound only
################################################################################

module "private" {
  source = "../../modules/subnets"

  name   = "${local.name}-private"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i + 8)
    ipv6_cidr_block   = cidrsubnet(module.vpc.vpc_ipv6_cidr_block, 8, i + 8)
  } }

  assign_ipv6_address_on_creation = true

  routes = {
    ipv4 = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      nat_gateway_id              = module.public.nat_gateway_ids[local.azs[0]]
    }
    # no translation, so no NAT gateway on this path
    ipv6 = {
      destination_ipv6_cidr_block = "::/0"
      egress_only_gateway_id      = module.vpc.egress_only_internet_gateway_id
    }
  }

  tags = local.tags
}

################################################################################
# IPv6 only: no IPv4 address at all, reaching IPv4 hosts through DNS64 and NAT64
################################################################################

module "ipv6_only" {
  source = "../../modules/subnets"

  name   = "${local.name}-ipv6-only"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv6_cidr_block   = cidrsubnet(module.vpc.vpc_ipv6_cidr_block, 8, i + 16)
    ipv6_native       = true
  } }

  assign_ipv6_address_on_creation = true

  # synthesise IPv6 answers for IPv4 only destinations
  enable_dns64 = true

  routes = {
    ipv6 = {
      destination_ipv6_cidr_block = "::/0"
      egress_only_gateway_id      = module.vpc.egress_only_internet_gateway_id
    }
    # without this, DNS64 resolves names that then never connect
    nat64 = {
      destination_ipv6_cidr_block = local.nat64_prefix
      nat_gateway_id              = module.public.nat_gateway_ids[local.azs[0]]
    }
  }

  tags = local.tags
}
