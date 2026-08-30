provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  # subnets the owner keeps, and subnets each team gets
  shared_subnets = merge(
    { for i, az in local.azs : "app-team-a-${az}" => { az = az, cidr = cidrsubnet(local.vpc_cidr, 8, i) } },
    { for i, az in local.azs : "app-team-b-${az}" => { az = az, cidr = cidrsubnet(local.vpc_cidr, 8, i + 4) } },
  )

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
# Egress, owned by this account and not shared
#
# Participants use it but cannot see or change it
################################################################################

module "egress" {
  source = "../../modules/subnets"

  name   = local.name
  vpc_id = module.vpc.vpc_id

  subnets = {
    public = {
      availability_zone = local.azs[0]
      ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, 200)
    }
  }

  map_public_ip_on_launch = true
  create_nat_gateway      = true

  # the table is the group's, and it is named for what it does rather than for the subnet
  route_table_tags = { Name = "${local.name}-egress" }

  routes = {
    igw = { destination_ipv4_cidr_block = "0.0.0.0/0", gateway_id = module.vpc.igw_id }
  }

  # deliberately not shared
  tags = local.tags
}

################################################################################
# Application subnets, shared with the participant accounts
################################################################################

module "app" {
  source = "../../modules/subnets"

  name   = local.name
  vpc_id = module.vpc.vpc_id

  subnets = { for k, v in local.shared_subnets : k => {
    availability_zone = v.az
    ipv4_cidr_block   = v.cidr
  } }

  # one table for every team subnet, because they all egress the same way
  route_table_tags = { Name = "${local.name}-app" }

  routes = {
    nat = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      nat_gateway_id              = module.egress.nat_gateway_ids["public"]
    }
  }

  # participants can launch here, but cannot touch the routing above
  share_subnet       = true
  resource_share_arn = aws_ram_resource_share.this.arn

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_ram_resource_share" "this" {
  name                      = local.name
  allow_external_principals = false

  tags = merge(local.tags, { Name = local.name })
}

resource "aws_ram_principal_association" "this" {
  for_each = toset(var.participant_account_ids)

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this.arn
}
