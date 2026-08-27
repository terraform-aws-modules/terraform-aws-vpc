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
# subnets, as this example does, or do not use IPAM for that VPC at all and pass a CIDR you
# already know.
#
# Note that `cidr` is ignored whenever `use_ipam_pool = true`: the module sets `cidr_block` to
# null and lets IPAM choose. Asking IPAM for one specific CIDR is not supported today.
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
