################################################################################
# IPAM Resources in Networking Account
################################################################################

# Create IPAM instance in networking account
resource "aws_vpc_ipam" "main" {
  provider = aws.networking

  description = "Cross-account IPAM for centralized IP management"

  operating_regions {
    region_name = var.region
  }

  tags = merge(
    var.tags,
    {
      Name = "cross-account-ipam"
    }
  )
}

# Create top-level IPAM pool in networking account
resource "aws_vpc_ipam_pool" "top_level" {
  provider = aws.networking

  description    = "Top-level IPAM pool for cross-account allocation"
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.main.private_default_scope_id
  locale         = var.region

  tags = merge(
    var.tags,
    {
      Name = "top-level-pool"
    }
  )
}

# Provision CIDR to top-level pool
resource "aws_vpc_ipam_pool_cidr" "top_level" {
  provider = aws.networking

  ipam_pool_id = aws_vpc_ipam_pool.top_level.id
  cidr         = var.top_level_pool_cidr
}

################################################################################
# RAM Sharing - Share IPAM Pool with Application Account
################################################################################

# Create RAM resource share in networking account
resource "aws_ram_resource_share" "ipam_pool" {
  provider = aws.networking

  name                      = "ipam-pool-cross-account-share"
  allow_external_principals = var.allow_external_principals

  tags = merge(
    var.tags,
    {
      Name = "ipam-pool-cross-account-share"
    }
  )
}

# Associate IPAM pool with RAM share
resource "aws_ram_resource_association" "ipam_pool" {
  provider = aws.networking

  resource_arn       = aws_vpc_ipam_pool.top_level.arn
  resource_share_arn = aws_ram_resource_share.ipam_pool.arn
}

# Share with application account
resource "aws_ram_principal_association" "application_account" {
  provider = aws.networking

  principal          = var.application_account_id
  resource_share_arn = aws_ram_resource_share.ipam_pool.arn
}

################################################################################
# VPC and Subnets in Application Account
################################################################################

# Get available AZs in application account
data "aws_availability_zones" "application" {
  provider = aws.application

  state = "available"
}

# Create VPC with VPC-scoped IPAM pool in application account
module "vpc" {
  source = "../.."

  # Use application account provider
  providers = {
    aws = aws.application
  }

  name = var.vpc_name
  cidr = var.vpc_cidr

  # Create VPC-scoped IPAM pool for subnet planning
  # This pool is created in the application account but uses the shared top-level pool
  create_vpc_ipam_pool    = true
  vpc_ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id
  vpc_ipam_pool_cidr      = var.vpc_cidr

  # Configure allocation constraints for subnet sizing
  vpc_ipam_pool_allocation_default_netmask_length = var.default_netmask_length
  vpc_ipam_pool_allocation_min_netmask_length     = var.min_netmask_length
  vpc_ipam_pool_allocation_max_netmask_length     = var.max_netmask_length

  # Create subnets from VPC-scoped IPAM pool
  # CIDRs are automatically allocated based on netmask_length
  ipam_subnets = [
    {
      name              = "private-subnet-1"
      availability_zone = data.aws_availability_zones.application.names[0]
      netmask_length    = 24
      tags = {
        Tier = "private"
      }
    },
    {
      name              = "private-subnet-2"
      availability_zone = data.aws_availability_zones.application.names[1]
      netmask_length    = 24
      tags = {
        Tier = "private"
      }
    },
    {
      name              = "private-subnet-3"
      availability_zone = data.aws_availability_zones.application.names[2]
      netmask_length    = 24
      tags = {
        Tier = "private"
      }
    }
  ]

  tags = merge(
    var.tags,
    {
      Environment = "cross-account-example"
    }
  )
}
