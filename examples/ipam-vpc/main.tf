provider "aws" {
  region = "eu-west-1"
}

locals {
  name = "ipam-vpc-example"
  azs  = formatlist("${data.aws_region.current.name}%s", ["a", "b"])
}

data "aws_region" "current" {}

/*
NOTES ON IPAM USAGE:

In order to build subnets with your VPC Terraform must
know subnet CIDRs to properly plan # of resources to build.
Since CIDR is derived by IPAM by calling CreateVpc this is not
possible within a module unless cidr is known ahead of time.
We can get around this by "previewing" the CIDR and then using that
as the subnet values.

In the example below we use `cidrsubnets()` to calculate a public
and private "partitions" (group of cidrs) then calculate the specific
CIDRs for each subnet type.

For an explanation on prolonged delete times on IPAM pools see 2nd
*note* in terraform docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool_cidr
*/

data "aws_vpc_ipam_preview_next_cidr" "previewed_cidr" {
  ipam_pool_id   = aws_vpc_ipam_pool.ipv4_example.id
  netmask_length = 24

  depends_on = [
    aws_vpc_ipam_pool_cidr.ipv4_example
  ]
}

locals {
  partition       = cidrsubnets(data.aws_vpc_ipam_preview_next_cidr.previewed_cidr.cidr, 2, 2)
  private_subnets = cidrsubnets(local.partition[0], 2, 2)
  public_subnets  = cidrsubnets(local.partition[1], 2, 2)
}

module "ipv4_ipam_explicit_cidrs_calculate_subnets" {
  source            = "../.."
  name              = "ipv4-calculated-subnets-${local.name}"
  ipv4_ipam_pool_id = aws_vpc_ipam_pool.ipv4_example.id
  azs               = local.azs
  cidr              = data.aws_vpc_ipam_preview_next_cidr.previewed_cidr.cidr
  private_subnets   = local.private_subnets
  public_subnets    = local.public_subnets

  depends_on = [
    aws_vpc_ipam_pool_cidr.ipv4_example
  ]
}

################################
# IPAM Setup
# Included for testing & example purposes only
################################

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
