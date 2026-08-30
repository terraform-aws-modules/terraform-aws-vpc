provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  app_subnets      = { for i, az in local.azs : az => cidrsubnet(local.vpc_cidr, 8, i) }
  db_subnets       = { for i, az in local.azs : az => cidrsubnet(local.vpc_cidr, 8, i + 4) }
  firewall_subnets = { for i, az in local.azs : az => cidrsubnet(local.vpc_cidr, 8, i + 8) }

  # the firewall reports one endpoint per zone
  firewall_endpoints = {
    for s in flatten(module.network_firewall.status[*].sync_states) : s.availability_zone => {
      endpoint_id = s.attachment[0].endpoint_id
    }
  }

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

  tags = local.tags
}

################################################################################
# Firewall subnets
#
# Local routing only. Inspected traffic leaves here for its real destination, so a
# redirect on this table would send it straight back into the firewall
################################################################################

module "firewall" {
  source = "../../modules/subnets"

  name   = "${local.name}-firewall"
  vpc_id = module.vpc.vpc_id

  subnets = { for az, cidr in local.firewall_subnets : az => {
    availability_zone = az
    ipv4_cidr_block   = cidr
  } }

  tags = local.tags
}

################################################################################
# Application tier, sending database traffic through inspection first
################################################################################

module "app" {
  source = "../../modules/subnets"

  name   = "${local.name}-app"
  vpc_id = module.vpc.vpc_id

  # the endpoint is zonal, so each subnet redirects to the one in its own zone and
  # therefore keeps a route table of its own
  subnets = { for az, cidr in local.app_subnets : az => {
    availability_zone = az
    ipv4_cidr_block   = cidr

    # more specific than the local route, so it wins
    routes = {
      to_db = {
        destination_ipv4_cidr_block = local.db_subnets[az]
        vpc_endpoint_id             = local.firewall_endpoints[az].endpoint_id
      }
    }
  } }

  tags = local.tags
}

################################################################################
# Database tier, sending the return leg back through the same endpoint
################################################################################

module "db" {
  source = "../../modules/subnets"

  name   = "${local.name}-db"
  vpc_id = module.vpc.vpc_id

  subnets = { for az, cidr in local.db_subnets : az => {
    availability_zone = az
    ipv4_cidr_block   = cidr

    routes = {
      to_app = {
        destination_ipv4_cidr_block = local.app_subnets[az]
        vpc_endpoint_id             = local.firewall_endpoints[az].endpoint_id
      }
    }
  } }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "network_firewall" {
  source  = "terraform-aws-modules/network-firewall/aws"
  version = "~> 2.0"

  name        = local.name
  description = "East-west inspection for ${local.name}"

  delete_protection                 = false
  firewall_policy_change_protection = false
  subnet_change_protection          = false

  vpc_id = module.vpc.vpc_id
  subnet_mapping = { for k, v in module.firewall.ids :
    (k) => {
      subnet_id       = v
      ip_address_type = "IPV4"
    }
  }

  tags = local.tags
}
