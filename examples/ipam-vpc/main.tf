provider "aws" {
  region = local.region
}

locals {
  name   = "ex-${replace(basename(path.cwd), "_", "-")}"
  region = "eu-west-1"

  azs               = ["${local.region}a", "${local.region}b", "${local.region}c"]
  preview_partition = cidrsubnets(aws_vpc_ipam_preview_next_cidr.this.cidr, 2, 2)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc_without_ipam" {
  source = "../.."

  name = "${local.name}-without-ipam"
  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  tags = local.tags
}

module "vpc_ipam_set_cidr" {
  source = "../.."

  name = "${local.name}-set-cidr"

  ipv4_ipam_pool_id = aws_vpc_ipam_pool.this.id
  cidr              = "10.0.0.0/16"
  azs               = local.azs

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  tags = local.tags

  depends_on = [
    aws_vpc_ipam_pool_cidr.this
  ]
}

module "vpc_ipam_set_netmask" {
  source = "../.."

  name = "${local.name}-set-netmask"

  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.this.id
  ipv4_netmask_length = 28
  azs                 = local.azs


  private_subnets = cidrsubnets(local.preview_partition[0], 2, 2, 2)
  public_subnets  = cidrsubnets(local.preview_partition[1], 2, 2, 2)

  tags = local.tags

  depends_on = [
    aws_vpc_ipam_pool_cidr.this
  ]
}

################################################################################
# Supporting Resources
################################################################################

/*
NOTES ON IPAM USAGE:

In order to build subnets with your VPC Terraform must know subnet CIDRs to properly plan # of resources to build.
Since CIDR is derived by IPAM by calling CreateVpc this is not possible within a module unless cidr is known ahead of time.
We can get around this by "previewing" the CIDR and then using that as the subnet values.

In the example above we use `cidrsubnets()` to calculate a public and private "partitions" (group of cidrs) then calculate the specific
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
