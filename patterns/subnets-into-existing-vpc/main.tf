provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

# the VPC is discovered, not created: nothing here manages it
data "aws_vpc" "existing" {
  tags = {
    Name = var.vpc_tag_name
  }
}

# a VPC can only have one internet gateway, so use the one it already has
data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # carved from spare space in the existing VPC's CIDR
  public  = { for i, az in local.azs : az => cidrsubnet(data.aws_vpc.existing.cidr_block, 8, i + 200) }
  private = { for i, az in local.azs : az => cidrsubnet(data.aws_vpc.existing.cidr_block, 8, i + 210) }

  tags = {
    Pattern    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# New public subnets, using the VPC's existing gateway
#
# Both route to the same gateway, so the routes are declared once for the group and one
# route table serves them
################################################################################

module "public" {
  source = "../../modules/subnets"

  name   = "${local.name}-public"
  vpc_id = data.aws_vpc.existing.id

  subnets = { for az, cidr in local.public : az => {
    availability_zone = az
    ipv4_cidr_block   = cidr

    create_nat_gateway = az == local.azs[0]
  } }

  map_public_ip_on_launch = true

  routes = {
    igw = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      gateway_id                  = data.aws_internet_gateway.existing.id
    }
  }

  tags = local.tags
}

################################################################################
# New private subnets, egressing through the new NAT gateway
################################################################################

module "private" {
  source = "../../modules/subnets"

  name   = "${local.name}-private"
  vpc_id = data.aws_vpc.existing.id

  subnets = { for az, cidr in local.private : az => {
    availability_zone = az
    ipv4_cidr_block   = cidr
  } }

  routes = {
    nat = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      nat_gateway_id              = module.public.nat_gateway_ids[local.azs[0]]
    }
  }

  tags = local.tags
}
