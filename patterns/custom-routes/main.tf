provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr    = "10.0.0.0/16"
  onprem_cidr = "192.168.0.0/16"
  peer_cidr   = "172.16.0.0/12"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

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

  enable_ipv6            = true
  create_egress_only_igw = true

  tags = local.tags
}

################################################################################
# One NAT gateway, so the default route has a target
################################################################################

module "public_subnet" {
  source = "../../modules/subnet"

  name              = "${local.name}-public"
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.azs[0]
  ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, 100)

  map_public_ip_on_launch = true
  create_nat_gateway      = true

  routes = {
    igw = { destination_ipv4_cidr_block = "0.0.0.0/0", gateway_id = module.vpc.igw_id }
  }

  tags = local.tags
}

################################################################################
# Transit gateway attachment subnets
#
# Dedicated subnets for the attachment. Attaching to the private subnets instead would
# be circular: the private route table needs the transit gateway, and the attachment
# would need the private subnets
################################################################################

module "attachment" {
  source = "../../modules/subnets"

  name   = "${local.name}-tgw"
  vpc_id = module.vpc.vpc_id

  # An empty `routes` on the entry says these are the subnet's own routes and there are
  # none of them, which keeps a table per subnet rather than folding them onto one
  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 12, i + 4080)
    routes            = {}
  } }

  tags = local.tags
}

################################################################################
# Private subnets, with four routes rather than the one the root module allows
#
# Every zone routes the same way, so the four are declared once for the group and one
# route table carries them
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
    # the route the root module would have created for you
    nat = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      nat_gateway_id              = module.public_subnet.nat_gateway_id
    }
    # the ones it gives you no way to add
    onprem = {
      destination_ipv4_cidr_block = local.onprem_cidr
      transit_gateway_id          = module.transit_gateway.ec2_transit_gateway_id
    }
    peer = {
      destination_ipv4_cidr_block = local.peer_cidr
      transit_gateway_id          = module.transit_gateway.ec2_transit_gateway_id
    }
    ipv6_default = {
      destination_ipv6_cidr_block = "::/0"
      egress_only_gateway_id      = module.vpc.egress_only_internet_gateway_id
    }
  }

  tags = local.tags

  depends_on = [module.transit_gateway]
}

################################################################################
# Supporting Resources
################################################################################

module "transit_gateway" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 3.0"

  name        = local.name
  description = local.name

  vpc_attachments = {
    this = {
      vpc_id     = module.vpc.vpc_id
      subnet_ids = values(module.attachment.ids)
    }
  }

  tags = local.tags
}
