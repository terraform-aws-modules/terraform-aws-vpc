provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "ex-${basename(path.cwd)}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

module "vpc" {
  source = "../.."

  name = local.name
  cidr = "10.42.0.0/16"
  azs  = local.azs

  public_subnets              = ["10.42.0.0/24", "10.42.1.0/24"]
  public_subnet_ipv6_prefixes = ["0", "1"]

  enable_ipv6       = true
  ipv6_ipam_pool_id = var.ipv6_ipam_pool_id
  ipv6_cidr         = var.ipv6_cidr

  tags = local.tags
}
