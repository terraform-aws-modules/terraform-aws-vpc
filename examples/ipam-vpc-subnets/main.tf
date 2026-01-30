provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-2" # VPC and IPAM region

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# VPC Module with IPAM Pool for Subnet Planning
################################################################################

# This example demonstrates the native Terraform resource approach for IPAM:
# 1. VPC-scoped IPAM pool using aws_vpc_ipam_pool with source_resource block
# 2. IPAM-allocated subnets using native aws_subnet resources
# 3. RAM sharing for cross-account access using native aws_ram_* resources
#
# The module now uses native Terraform AWS provider resources (>= 6.28.0)
# instead of null_resource workarounds with AWS CLI commands.

module "vpc" {
  source = "../.."

  name = local.name

  # Create VPC using IPAM pool allocation
  use_ipam_pool       = true
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.top_level.id
  ipv4_netmask_length = 16

  azs = local.azs

  # Don't create traditional subnets - all subnets will come from IPAM pool
  private_subnets = []
  public_subnets  = []

  enable_nat_gateway = false
  enable_vpn_gateway = false

  # Enable VPC IPAM Pool for subnet planning (VPC-specific pool)
  # This creates a VPC-scoped IPAM pool using the native aws_vpc_ipam_pool resource
  # with a source_resource block that associates the pool with the VPC
  create_vpc_ipam_pool = true
  vpc_ipam_scope_id    = aws_vpc_ipam.this.private_default_scope_id
  vpc_ipam_pool_locale = local.region # Where the pool operates (must match VPC region)

  # Source pool to allocate from (the top-level IPAM pool)
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id

  # vpc_ipam_pool_cidr is optional - if not provided, will use the VPC's CIDR
  # (which was allocated from the top-level IPAM pool in this case)

  # Configure allocation constraints for subnets
  # These constraints control the size of subnets that can be allocated from the pool
  vpc_ipam_pool_allocation_default_netmask_length = 24
  vpc_ipam_pool_allocation_min_netmask_length     = 24
  vpc_ipam_pool_allocation_max_netmask_length     = 20

  # Enable RAM sharing for cross-account access
  # The module uses native aws_ram_resource_share, aws_ram_resource_association,
  # and aws_ram_principal_association resources
  vpc_ipam_pool_ram_share_enabled    = true
  vpc_ipam_pool_ram_share_principals = var.ram_share_principals

  # Create subnets using IPAM pool allocation
  # The module uses native aws_subnet resources with ipv4_ipam_pool_id parameter
  # All subnets are created from the VPC-specific IPAM pool with auto-allocated CIDRs
  # based on the specified netmask_length
  ipam_subnets = [
    {
      name              = "${local.name}-private-subnet-1"
      availability_zone = "${local.region}a"
      netmask_length    = 24 # /24 for private subnets
      tags = {
        Type = "private"
        Tier = "application"
      }
    },
    {
      name              = "${local.name}-private-subnet-2"
      availability_zone = "${local.region}b"
      netmask_length    = 24
      tags = {
        Type = "private"
        Tier = "application"
      }
    },
    {
      name              = "${local.name}-private-subnet-3"
      availability_zone = "${local.region}c"
      netmask_length    = 24
      tags = {
        Type = "private"
        Tier = "application"
      }
    },
    {
      name              = "${local.name}-public-subnet-1"
      availability_zone = "${local.region}a"
      netmask_length    = 24 # /24 for public subnets
      tags = {
        Type = "public"
        Tier = "web"
      }
    },
    {
      name              = "${local.name}-public-subnet-2"
      availability_zone = "${local.region}b"
      netmask_length    = 24
      tags = {
        Type = "public"
        Tier = "web"
      }
    },
    {
      name              = "${local.name}-public-subnet-3"
      availability_zone = "${local.region}c"
      netmask_length    = 24
      tags = {
        Type = "public"
        Tier = "web"
      }
    }
  ]

  tags = local.tags

  depends_on = [
    aws_vpc_ipam_pool_cidr.top_level
  ]
}

################################################################################
# Supporting IPAM Resources
################################################################################

# Top-level IPAM (created in same region as VPC)
# This is the organization-wide or account-wide IPAM instance
resource "aws_vpc_ipam" "this" {
  description = "IPAM for ${local.name}"

  operating_regions {
    region_name = local.region
  }

  tags = local.tags
}

# Top-level IPAM Pool (organization-wide or account-wide)
# Created in same region with locale set to where it operates
# This pool serves as the source for VPC-scoped IPAM pools
resource "aws_vpc_ipam_pool" "top_level" {
  description                       = "Top-level IPv4 pool"
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.this.private_default_scope_id
  locale                            = local.region # Where the pool operates (VPC region)
  allocation_default_netmask_length = 16

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-top-level"
    }
  )
}

# Provision CIDR to top-level pool
# This makes the CIDR range available for allocation to VPC-scoped pools
resource "aws_vpc_ipam_pool_cidr" "top_level" {
  ipam_pool_id = aws_vpc_ipam_pool.top_level.id
  cidr         = "10.0.0.0/8"
}
