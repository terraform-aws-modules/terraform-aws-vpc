provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

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

  # No subnets here on purpose: when IPAM picks the CIDR it is not known until apply, so
  # any subnet count derived from it cannot be planned. See the note below
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

  # IPv6 allocation can come from an IPAM pool the same way IPv4 does
  ipv6_cidr                            = null
  ipv6_ipam_pool_id                    = null
  ipv6_netmask_length                  = null
  ipv6_cidr_block_network_border_group = null
  azs                                  = local.azs

  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]

  tags = local.tags

  # The pool CIDR has to finish provisioning before a VPC can allocate out of it, otherwise
  # the allocation is rejected as larger than the pool
  depends_on = [
    aws_vpc_ipam_pool_cidr.this
  ]
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

# NOTES ON IPAM USAGE:
#
# Terraform has to know the subnet CIDRs at plan time to work out how many resources to
# create. When IPAM chooses the CIDR, it is only known after `CreateVpc` has run, so the
# subnet counts cannot be planned in the same pass. `aws_vpc_ipam_preview_next_cidr` does not
# solve this: its `cidr` is a computed resource attribute, so it is still unknown on the
# first plan and every subnet `count` derived from it fails with "Invalid count argument".
#
# So there are two ways to use this module with IPAM: let IPAM allocate the CIDR and define no
# subnets, as `set-netmask` does, or pass a CIDR you already know and define subnets against
# it, as `set-cidr` does.
#
# For an explanation on prolonged delete times on IPAM pools see 2nd
# *note* in terraform docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool_cidr

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
