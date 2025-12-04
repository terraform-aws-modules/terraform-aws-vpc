variable "region" {
  default = "ap-south-1"
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
  }
}

module "vpc" {
  source = "../../"
  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Regional NAT Gateway Configuration
  # Requires Terraform AWS provider >= 6.24.0
  enable_nat_gateway            = true
  nat_gateway_connectivity_type = "regional"
  tags = local.tags
}
