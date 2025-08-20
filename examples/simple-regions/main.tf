provider "aws" {}

locals {
  name = "ex-${basename(path.cwd)}"

  regions = toset([
    "us-east-1",
    "eu-west-1",
    "eu-central-1",
  ])

  vpc_cidrs = {
    "us-east-1"    = "10.0.0.0/16"
    "eu-west-1"    = "10.1.0.0/16"
    "eu-central-1" = "10.2.0.0/16"
  }
  azs = { for k, v in local.vpc_cidrs :
    k => slice(data.aws_availability_zones.available[k].names, 0, 3)
  }

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

data "aws_availability_zones" "available" {
  for_each = local.regions
  region   = each.value

  state = "available"
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../"

  for_each = local.regions
  region   = each.value

  name = local.name
  cidr = local.vpc_cidrs[each.value]

  azs = local.azs[each.value]
  private_subnets = [for k, v in local.azs[each.value] :
    cidrsubnet(local.vpc_cidrs[each.value], 4, k)
  ]

  tags = local.tags
}
