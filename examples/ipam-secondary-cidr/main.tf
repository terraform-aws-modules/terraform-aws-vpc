provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  azs                         = slice(data.aws_availability_zones.available.names, 0, 3)
  preview_partition           = cidrsubnets(aws_vpc_ipam_preview_next_cidr.this.cidr, 2, 2, 2)
  preview_partition_secondary = cidrsubnets(aws_vpc_ipam_preview_next_cidr.secondary.cidr, 2, 2, 2)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# VPC Module
################################################################################

# IPv4
module "vpc_ipam_secondary" {
  source = "../.."

  name = "${local.name}-ipam-secondary"

  use_ipam_pool       = true
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.this.id
  ipv4_netmask_length = 16
  azs                 = local.azs

  secondary_ipam_pool_ids     = [aws_vpc_ipam_pool.secondary.id]
  secondary_ipam_pool_netmask = [8]

  private_subnets = cidrsubnets(local.preview_partition[0], 2, 2, 2)
  public_subnets  = cidrsubnets(local.preview_partition_secondary[0], 2, 2, 2)

  tags = local.tags

  depends_on = [
    aws_vpc_ipam_pool_cidr.this
  ]
}

resource "aws_vpc_ipam" "this" {
  operating_regions {
    region_name = local.region
  }

  tags = local.tags
}

resource "aws_vpc_ipam_pool" "this" {
  description                       = "IPv4 pool"
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.this.private_default_scope_id
  locale                            = local.region
  allocation_default_netmask_length = 16

  tags = local.tags
}

resource "aws_vpc_ipam_pool_cidr" "this" {
  ipam_pool_id = aws_vpc_ipam_pool.this.id
  cidr         = "10.0.0.0/8"
}

resource "aws_vpc_ipam_preview_next_cidr" "this" {
  ipam_pool_id = aws_vpc_ipam_pool.this.id

  depends_on = [
    aws_vpc_ipam_pool_cidr.this
  ]
}

#Secondary CIDR

resource "aws_vpc_ipam" "secondary" {
  operating_regions {
    region_name = local.region
  }

  tags = local.tags
}

resource "aws_vpc_ipam_pool" "secondary" {
  description                       = "IPv4 pool"
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.secondary.private_default_scope_id
  locale                            = local.region
  allocation_default_netmask_length = 16

  tags = local.tags
}

resource "aws_vpc_ipam_pool_cidr" "secondary" {
  ipam_pool_id = aws_vpc_ipam_pool.secondary.id
  cidr         = "198.0.0.0/8"
}

resource "aws_vpc_ipam_preview_next_cidr" "secondary" {
  ipam_pool_id = aws_vpc_ipam_pool.secondary.id

  depends_on = [
    aws_vpc_ipam_pool_cidr.secondary
  ]
}
