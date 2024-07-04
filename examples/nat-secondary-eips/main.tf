provider "aws" {
  region = local.region
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"

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

  enable_nat_gateway = true

  # create two secondary EIPs for the NAT gateway
  external_nat_secondary_ip_count = [2]

  # or, if you want to specify the EIPs to use
  # reuse_external_nat_secondary_ips = true
  # external_nat_secondary_ip_ids = [
  #   ["eip-12345678", "eip-87654321"]
  # ]

  tags = local.tags
}
