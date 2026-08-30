provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Pattern    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# VPC, with its CIDR allocated by IPAM rather than written by hand
################################################################################

module "vpc" {
  source = "../../"

  name = local.name
  azs  = local.azs

  use_ipam_pool       = true
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.regional.id
  ipv4_netmask_length = 20

  create_igw = true

  tags = local.tags

  depends_on = [aws_vpc_ipam_pool_cidr.regional]
}

################################################################################
# Subnets carved from whatever IPAM allocated
#
# The keys come from the availability zone list so they are known at plan time. Only
# the CIDR values are unknown, which is what keeps the counts valid
################################################################################

module "public" {
  source = "../../modules/subnets"

  name   = "${local.name}-public"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az

    # derived from the allocation, so unknown until apply
    ipv4_cidr_block = cidrsubnet(module.vpc.vpc_cidr_block, 4, i)

    create_nat_gateway = i == 0
  } }

  map_public_ip_on_launch = true

  routes = {
    igw = { destination_ipv4_cidr_block = "0.0.0.0/0", gateway_id = module.vpc.igw_id }
  }

  tags = local.tags
}

module "private" {
  source = "../../modules/subnets"

  name   = "${local.name}-private"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(module.vpc.vpc_cidr_block, 4, i + 8)
  } }

  routes = {
    nat = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      nat_gateway_id              = module.public.nat_gateway_ids[local.azs[0]]
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
#
# In a real deployment these live in a networking account and are shared. They are
# created here only so the pattern stands alone
################################################################################

resource "aws_vpc_ipam" "this" {
  operating_regions {
    region_name = data.aws_region.current.region
  }

  tags = merge(local.tags, { Name = local.name })
}

resource "aws_vpc_ipam_pool" "top" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.this.private_default_scope_id

  tags = merge(local.tags, { Name = "${local.name}-top" })
}

resource "aws_vpc_ipam_pool_cidr" "top" {
  ipam_pool_id = aws_vpc_ipam_pool.top.id
  cidr         = "10.0.0.0/8"
}

resource "aws_vpc_ipam_pool" "regional" {
  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.this.private_default_scope_id
  source_ipam_pool_id = aws_vpc_ipam_pool.top.id
  locale              = data.aws_region.current.region

  tags = merge(local.tags, { Name = "${local.name}-regional" })
}

resource "aws_vpc_ipam_pool_cidr" "regional" {
  ipam_pool_id = aws_vpc_ipam_pool.regional.id
  cidr         = "10.0.0.0/16"

  depends_on = [aws_vpc_ipam_pool_cidr.top]
}
