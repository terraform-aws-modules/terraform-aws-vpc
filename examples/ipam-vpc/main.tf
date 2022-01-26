provider "aws" {
  region = "eu-west-1"
}

locals {
  name = "ipam-vpc-example"
}

# IPAM Setup
data "aws_region" "current" {}

resource "aws_vpc_ipam" "example" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_pool" "ipv4_example" {
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.example.private_default_scope_id
  locale                            = data.aws_region.current.name
  allocation_default_netmask_length = 28
}

resource "aws_vpc_ipam_pool_cidr" "ipv4_example" {
  ipam_pool_id = aws_vpc_ipam_pool.ipv4_example.id
  cidr         = "172.2.0.0/16"
}

# Usage Patterns

module "no_ipam_vpc_example" {
  source = "../.."
  name   = "no-ipam-${local.name}"
  cidr   = "172.2.0.32/28"
}

data "aws_vpc_ipam_preview_next_cidr" "previewed_cidr" {
  ipam_pool_id   = aws_vpc_ipam_pool.ipv4_example.id
  netmask_length = 24

  depends_on = [
    aws_vpc_ipam_pool_cidr.ipv4_example
  ]
}

locals {
  partition = cidrsubnets(data.aws_vpc_ipam_preview_next_cidr.previewed_cidr.cidr, 2, 2)
  private_subnets = cidrsubnets(local.partition[0], 2, 2)
  public_subnets = cidrsubnets(local.partition[1], 2, 2)
}

module "ipv4_ipam_calculate_subnets" {
  source            = "../.."
  name              = "ipv4-calculated-subnets-${local.name}"
  ipv4_ipam_pool_id = aws_vpc_ipam_pool.ipv4_example.id
  cidr              = data.aws_vpc_ipam_preview_next_cidr.previewed_cidr.cidr
  private_subnets   = local.private_subnets
  public_subnets    = local.public_subnets
  depends_on = [
    aws_vpc_ipam_pool_cidr.ipv4_example
  ]
}

# module "ipv4_ipam_explicit_cidr_vpc" {
#   source            = "../.."
#   name              = "ipv4-explicit-cidr-${local.name}"
#   ipv4_ipam_pool_id = aws_vpc_ipam_pool.ipv4_example.id
#   cidr              = "172.2.0.32/28"
#   depends_on = [
#     aws_vpc_ipam_pool_cidr.ipv4_example
#   ]
# }

# module "ipv4_ipam_explicit_netmask_vpc" {
#   source              = "../.."
#   name                = "ipv4-explicit-netmask-${local.name}"
#   ipv4_ipam_pool_id   = aws_vpc_ipam_pool.ipv4_example.id
#   ipv4_netmask_length = 28
#   depends_on = [
#     aws_vpc_ipam_pool_cidr.ipv4_example
#   ]
# }

# module "ipv4_ipam_default_netmask_vpc" {
#   source            = "../.."
#   name              = "ipv4-default-netmask-${local.name}"
#   ipv4_ipam_pool_id = aws_vpc_ipam_pool.ipv4_example.id
#   depends_on = [
#     aws_vpc_ipam_pool_cidr.ipv4_example
#   ]
# }
