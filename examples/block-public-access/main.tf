provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

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
  source = "../../"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]

  ### VPC Block Public Access Options
  vpc_block_public_access_options = {
    internet_gateway_block_mode = "block-bidirectional"
  }

  ### VPC Block Public Access Exclusion at the VPC level
  vpc_block_public_access_exclusions = {
    exclude_vpc = {
      exclude_vpc                     = true
      internet_gateway_exclusion_mode = "allow-bidirectional"
    }
  }

  ### VPC Block Public Access Exclusion at the subnet level
  # vpc_block_public_access_exclusions = {
  #   exclude_subnet_private1 = {
  #     exclude_subnet                  = true
  #     subnet_type                     = "private"
  #     subnet_index                    = 1
  #     internet_gateway_exclusion_mode = "allow-egress"
  #   }
  #   exclude_subnet_private2 = {
  #     exclude_subnet                  = true
  #     subnet_type                     = "private"
  #     subnet_index                    = 2
  #     internet_gateway_exclusion_mode = "allow-egress"
  #   }
  # }

  tags = local.tags
}
