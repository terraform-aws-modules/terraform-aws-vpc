provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
}

################################################################################
# VPC Module
################################################################################

data "aws_region" "current" {}

resource "aws_vpc_ipam" "main" {
  description = "My IPAM"
  operating_regions {
    region_name = data.aws_region.current.name
  }

  tags = {
    Test = "Main"
  }
}

resource "aws_vpc_ipam_pool" "top_level" {
  description    = "top-level-pool"
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.main.private_default_scope_id

  locale = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "top_level" {
  ipam_pool_id = aws_vpc_ipam_pool.top_level.id
  cidr         = "10.0.0.0/8"
}


module "vpc" {
  source = "../../"

  name = "ipam-example"

  cidr                = null
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.top_level.id
  ipv4_netmask_length = 16

  azs                     = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets         = ["24", "24", "24"]
  private_subnets_indexes = [0, 1, 2]

  database_subnets         = ["24", "24"]
  database_subnets_indexes = [3, 7]

  public_subnets         = ["24", "24", "24"]
  public_subnets_indexes = [4, 5, 6]

  enable_ipv6 = false

  enable_nat_gateway = false
  single_nat_gateway = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-name"
  }

  depends_on = [
    aws_vpc_ipam_pool_cidr.top_level
  ]
}
