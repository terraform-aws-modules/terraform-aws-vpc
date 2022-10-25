provider "aws" {
  region = local.region
}

locals {
  name   = "ex-${replace(basename(path.cwd), "_", "-")}"
  region = "eu-west-1"

  azs               = ["${local.region}a", "${local.region}b", "${local.region}c"]
  preview_partition = cidrsubnets(aws_vpc_ipam_preview_next_cidr.this.cidr, 2, 2, 2)

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
module "vpc_ipam_set_netmask" {
  source = "../.."

  name = "${local.name}-set-netmask"

  use_ipam_pool       = true
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.this.id
  ipv4_netmask_length = 16
  azs                 = local.azs

  private_subnets = cidrsubnets(local.preview_partition[0], 2, 2, 2)
  public_subnets  = cidrsubnets(local.preview_partition[1], 2, 2, 2)

  tags = local.tags

  depends_on = [
    aws_vpc_ipam_pool_cidr.this
  ]
}

module "vpc_ipam_set_cidr" {
  source = "../.."

  name = "${local.name}-set-cidr"

  use_ipam_pool     = true
  ipv4_ipam_pool_id = aws_vpc_ipam_pool.this.id
  cidr              = "10.1.0.0/16"
  azs               = local.azs

  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]

  tags = local.tags
}

# # IPv6 - Requires having a CIDR plus its message and signature (see below)
# module "vpc_ipv6_ipam_set_netmask" {
#   source = "../.."

#   name = "${local.name}-ipv6-set-netmask"

#   use_ipam_pool       = true
#   ipv4_ipam_pool_id   = aws_vpc_ipam_pool.this.id
#   ipv6_ipam_pool_id   = aws_vpc_ipam_pool.ipv6.id
#   ipv6_netmask_length = 56
#   azs                 = local.azs

#   tags = local.tags
# }

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

  tags = local.tags
}

# IPv4
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

# IPv6
resource "aws_vpc_ipam_pool" "ipv6" {
  description                       = "IPv6 pool"
  address_family                    = "ipv6"
  ipam_scope_id                     = aws_vpc_ipam.this.public_default_scope_id
  locale                            = local.region
  allocation_default_netmask_length = 56
  publicly_advertisable             = false
  aws_service                       = "ec2"

  tags = local.tags
}

# # Requires having a CIDR plus its message and signature
# resource "aws_vpc_ipam_pool_cidr" "ipv6" {
#   ipam_pool_id = aws_vpc_ipam_pool.ipv6.id
#   cidr         = var.ipv6_cidr

#   cidr_authorization_context {
#     message   = var.message
#     signature = var.signature
#   }
# }
