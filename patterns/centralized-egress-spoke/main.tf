provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  # everything internal, summarised, so the spoke does not need per VPC routes
  internal_cidr = "10.0.0.0/8"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Pattern    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

# No internet gateway and no NAT gateway: create_igw is left at its default, so the
# module creates none, and nothing here asks for a NAT gateway
module "vpc" {
  source = "../../"

  name = local.name
  cidr = local.vpc_cidr
  azs  = local.azs

  tags = local.tags
}

################################################################################
# Transit gateway attachment subnets
#
# A dedicated /28 per zone so attachment interfaces do not sit in workload space and
# can route differently from the workloads
################################################################################

module "attachment" {
  source = "../../modules/subnets"

  name   = "${local.name}-tgw"
  vpc_id = module.vpc.vpc_id

  # Local routing only: the attachment does not need a default route. An empty `routes`
  # on the entry says these are the subnet's own routes and there are none of them, which
  # keeps a table per subnet rather than folding them onto one
  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 12, i + 4080)
    routes            = {}
  } }

  tags = local.tags
}

################################################################################
# Workload subnets, egressing through the transit gateway
#
# Every zone sends to the same attachment, so the routes are declared once for the group
# and one route table serves all three
################################################################################

module "private" {
  source = "../../modules/subnets"

  name   = "${local.name}-private"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i)
  } }

  routes = {
    # everything outbound goes to the hub, including internet traffic
    default = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      transit_gateway_id          = module.transit_gateway.ec2_transit_gateway_id
    }
    # and so does anything internal, summarised
    internal = {
      destination_ipv4_cidr_block = local.internal_cidr
      transit_gateway_id          = module.transit_gateway.ec2_transit_gateway_id
    }
  }

  tags = local.tags

  depends_on = [module.transit_gateway]
}

################################################################################
# Supporting Resources
################################################################################

# Stands in for the hub. In a real deployment this is owned by the networking account
# and shared, and the spoke only creates the attachment
module "transit_gateway" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 3.0"

  name        = local.name
  description = "Hub for ${local.name}"

  vpc_attachments = {
    spoke = {
      vpc_id     = module.vpc.vpc_id
      subnet_ids = values(module.attachment.ids)
    }
  }

  tags = local.tags
}
