provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  # Keyed by availability zone name, which is what the firewall reports its endpoints
  # against, so the two line up without reconstructing zone names from the region
  public_subnets   = { for i, az in local.azs : az => cidrsubnet(local.vpc_cidr, 8, i + 4) }
  firewall_subnets = { for i, az in local.azs : az => cidrsubnet(local.vpc_cidr, 8, i + 8) }

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

  create_igw      = true
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]

  tags = local.tags
}

################################################################################
# Subnet(s)
################################################################################

locals {
  firewall_endpoints = {
    for s in flatten(module.network_firewall.status[*].sync_states) : s.availability_zone => {
      subnet_id   = s.attachment[0].subnet_id
      endpoint_id = s.attachment[0].endpoint_id
    }
  }
}

module "public" {
  source = "../../modules/subnets"

  name   = "${local.name}-public"
  vpc_id = module.vpc.vpc_id

  # the endpoint is zonal, so each subnet sends its traffic to the endpoint in its own
  # zone and therefore keeps a route table of its own
  subnets = { for az, cidr in local.public_subnets : az => {
    availability_zone = az
    ipv4_cidr_block   = cidr

    routes = {
      firewall-endpoint = {
        destination_ipv4_cidr_block = "0.0.0.0/0"
        vpc_endpoint_id             = local.firewall_endpoints[az].endpoint_id
      }
    }
  } }

  tags = local.tags
}

module "firewall" {
  source = "../../modules/subnets"

  name   = "${local.name}-firewall"
  vpc_id = module.vpc.vpc_id

  subnets = { for az, cidr in local.firewall_subnets : az => {
    availability_zone = az
    ipv4_cidr_block   = cidr
  } }

  # inspected traffic leaves through the internet gateway. Every zone leaves the same
  # way, so the group's routes are declared once and one table serves them all
  routes = {
    igw = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      gateway_id                  = module.vpc.igw_id
    }
  }

  tags = local.tags
}

################################################################################
# Internet Gateway Ingress Routing
################################################################################

# Without this, inbound traffic goes straight from the internet gateway into the public
# subnets and never reaches the firewall, while outbound traffic does. The firewall then
# sees only one direction of each connection, which a stateful engine cannot evaluate.
#
# This route table is associated with the gateway and with no subnet, which is why it
# comes from the route-table sub-module rather than the subnet sub-module
#
# Route table layout: https://docs.aws.amazon.com/network-firewall/latest/developerguide/arch-two-zone-igw.html
# Dedicated gateway route table: https://docs.aws.amazon.com/vpc/latest/userguide/igw-ingress-routing.html
module "igw_ingress" {
  source = "../../modules/route-table"

  name   = "${local.name}-igw-ingress"
  vpc_id = module.vpc.vpc_id

  gateway_id = module.vpc.igw_id

  # Traffic destined for each public subnet is sent to the firewall endpoint in that
  # subnet's own availability zone, which is what keeps the flow symmetric
  routes = { for az, cidr in local.public_subnets :
    az => {
      destination_ipv4_cidr_block = cidr
      vpc_endpoint_id             = local.firewall_endpoints[az].endpoint_id
    }
  }

  tags = local.tags
}

################################################################################
# Network Firewall
################################################################################

module "network_firewall" {
  source  = "terraform-aws-modules/network-firewall/aws"
  version = "~> 2.0"

  # Firewall
  name        = local.name
  description = "Example network firewall"

  # Only for example
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
