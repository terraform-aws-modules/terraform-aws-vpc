provider "aws" {
  region = local.region
}

# Provider alias for IPAM resources (when IPAM is in a different region)
# This is required when vpc_ipam_pool_region is set
provider "aws" {
  alias  = "ipam"
  region = local.ipam_region
}

data "aws_availability_zones" "available" {}

locals {
  name        = "ex-${basename(path.cwd)}"
  region      = "eu-west-2"  # VPC region
  ipam_region = "eu-west-1"  # IPAM region (best practice: IPAM in home region)

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

module "vpc" {
  source = "../.."

  providers = {
    aws      = aws
    aws.ipam = aws.ipam
  }

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
  create_vpc_ipam_pool    = true
  vpc_ipam_pool_region    = local.ipam_region  # Where IPAM resources are created
  vpc_ipam_scope_id       = aws_vpc_ipam.this.private_default_scope_id
  vpc_ipam_pool_locale    = local.region       # Where the pool operates (must match VPC region)

  # Source pool to allocate from (the top-level IPAM pool)
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id

  # For cross-account setups, specify AWS profiles:
  # vpc_ipam_pool_aws_profile = "ipam-account-profile"  # Profile for IPAM account
  # vpc_aws_profile           = "vpc-account-profile"   # Profile for VPC account

  # vpc_ipam_pool_cidr is optional - if not provided, will use the VPC's CIDR
  # (which was allocated from the top-level IPAM pool in this case)

  # Configure allocation constraints for subnets
  vpc_ipam_pool_allocation_default_netmask_length = 24
  vpc_ipam_pool_allocation_min_netmask_length     = 24
  vpc_ipam_pool_allocation_max_netmask_length     = 20

  # Enable RAM sharing
  vpc_ipam_pool_ram_share_enabled    = true
  vpc_ipam_pool_ram_share_principals = var.ram_share_principals

  # Create subnets using IPAM pool allocation
  # All subnets are created from the VPC-specific IPAM pool with auto-allocated CIDRs
  ipam_subnets = [
    {
      name              = "${local.name}-private-subnet-1"
      availability_zone = "${local.region}a"
      netmask_length    = 24  # /24 for private subnets
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
      netmask_length    = 24  # /24 for public subnets
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

# Top-level IPAM (created in IPAM region)
resource "aws_vpc_ipam" "this" {
  provider = aws.ipam

  description = "IPAM for ${local.name}"

  operating_regions {
    region_name = local.region
  }

  tags = local.tags
}

# Top-level IPAM Pool (organization-wide or account-wide)
# Created in IPAM region with locale set to where it operates
resource "aws_vpc_ipam_pool" "top_level" {
  provider = aws.ipam

  description                       = "Top-level IPv4 pool"
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.this.private_default_scope_id
  locale                            = local.region  # Where the pool operates (VPC region)
  allocation_default_netmask_length = 16

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-top-level"
    }
  )
}

# Provision CIDR to top-level pool
resource "aws_vpc_ipam_pool_cidr" "top_level" {
  provider = aws.ipam

  ipam_pool_id = aws_vpc_ipam_pool.top_level.id
  cidr         = "10.0.0.0/8"
}
