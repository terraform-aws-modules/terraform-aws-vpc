provider "aws" {
  region = local.region
}

locals {
  name   = "ex-${replace(basename(path.cwd), "_", "-")}"
  region = "eu-west-1"

  partition = cidrsubnets(aws_vpc_ipam_preview_next_cidr.this.cidr, 2, 2)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../.."

  name = local.name

  private_subnets = cidrsubnets(local.partition[0], 2, 2)
  public_subnets  = cidrsubnets(local.partition[1], 2, 2)

  ipv4_ipam_pool_id = aws_vpc_ipam_pool.this.id
  azs               = ["${local.region}a", "${local.region}b"]
  cidr              = aws_vpc_ipam_preview_next_cidr.this.cidr

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

/*
NOTES ON IPAM USAGE:

In order to build subnets with your VPC Terraform must know subnet CIDRs to properly plan # of resources to build.
Since CIDR is derived by IPAM by calling CreateVpc this is not possible within a module unless cidr is known ahead of time.
We can get around this by "previewing" the CIDR and then using that as the subnet values.

In the example below we use `cidrsubnets()` to calculate a public and private "partitions" (group of cidrs) then calculate the specific
CIDRs for each subnet type.

For an explanation on prolonged delete times on IPAM pools see 2nd
*note* in terraform docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool_cidr
*/

resource "aws_vpc_ipam" "this" {
  operating_regions {
    region_name = local.region
  }
}

resource "aws_vpc_ipam_pool" "this" {
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.this.private_default_scope_id
  locale                            = local.region
  allocation_default_netmask_length = 24
}

resource "aws_vpc_ipam_pool_cidr" "this" {
  ipam_pool_id = aws_vpc_ipam_pool.this.id
  cidr         = "10.0.0.0/16"
}

resource "aws_vpc_ipam_preview_next_cidr" "this" {
  ipam_pool_id   = aws_vpc_ipam_pool.this.id
  netmask_length = 20

  depends_on = [
    aws_vpc_ipam_pool_cidr.this
  ]
}
