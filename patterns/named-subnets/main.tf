provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  # tags that mean something for the workload, carried per subnet
  eks_tags = { "kubernetes.io/role/internal-elb" = "1" }

  # Named by what they are for, sized by what they hold, placed where they are needed.
  # Note the asymmetry: pods and nodes in two zones, cache in one, transit in one
  subnets = {
    eks-pods-a = { availability_zone = local.azs[0], ipv4_cidr_block = cidrsubnet(local.vpc_cidr, 2, 2), tags = local.eks_tags }
    eks-pods-b = { availability_zone = local.azs[1], ipv4_cidr_block = cidrsubnet(local.vpc_cidr, 2, 3), tags = local.eks_tags }

    eks-nodes-a = { availability_zone = local.azs[0], ipv4_cidr_block = cidrsubnet(local.vpc_cidr, 8, 0), tags = local.eks_tags }
    eks-nodes-b = { availability_zone = local.azs[1], ipv4_cidr_block = cidrsubnet(local.vpc_cidr, 8, 1), tags = local.eks_tags }

    cache-public = { availability_zone = local.azs[2], ipv4_cidr_block = cidrsubnet(local.vpc_cidr, 8, 2) }

    transit = { availability_zone = local.azs[0], ipv4_cidr_block = cidrsubnet(local.vpc_cidr, 12, 48) }
  }

  tags = {
    Pattern    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

module "vpc" {
  source = "../../"

  name = local.name
  cidr = local.vpc_cidr
  azs  = local.azs

  # composing subnets outside the module, so ask for the gateway explicitly
  create_igw = true

  tags = local.tags
}

################################################################################
# Subnets
#
# Every subnet routes to the same internet gateway, so the routes are declared once for
# the group and one route table serves all six
################################################################################

module "subnets" {
  source = "../../modules/subnets"

  name   = local.name
  vpc_id = module.vpc.vpc_id

  # the key names the subnet and is also its Terraform address
  subnets = local.subnets

  routes = {
    igw = { destination_ipv4_cidr_block = "0.0.0.0/0", gateway_id = module.vpc.igw_id }
  }

  tags = local.tags
}
