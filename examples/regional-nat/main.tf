provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  region = "ap-south-1"
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example = local.name
  }
}

module "vpc" {
  source = "../../"
  name   = local.name
  cidr   = local.vpc_cidr

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Regional NAT Gateway Configuration
  # Requires Terraform AWS provider >= 6.24.0
  enable_nat_gateway = true
  nat_gateway_connectivity_type = {
    availability_mode = "regional" # "regional" or "zonal"
    eip_allocation    = "auto"     # "auto" or "manual", for availablility_mode = "zonal", eip_allocation won't be used
  }
  tags = local.tags
}
