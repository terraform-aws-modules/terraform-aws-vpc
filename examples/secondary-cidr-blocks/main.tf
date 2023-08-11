provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr              = "10.0.0.0/16"
  secondary_cidr_blocks = ["10.1.0.0/16", "10.2.0.0/16"]
  azs                   = slice(data.aws_availability_zones.available.names, 0, 3)

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

  secondary_cidr_blocks = local.secondary_cidr_blocks # can add up to 5 total CIDR blocks

  azs = local.azs
  private_subnets = concat(
    [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)],
    [for k, v in local.azs : cidrsubnet(element(local.secondary_cidr_blocks, 0), 2, k)],
    [for k, v in local.azs : cidrsubnet(element(local.secondary_cidr_blocks, 1), 2, k)],
  )
  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = false

  tags = local.tags
}
