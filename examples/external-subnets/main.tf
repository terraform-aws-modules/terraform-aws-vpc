provider "aws" {
  region = local.region
}

locals {
  name   = "ex-${replace(basename(path.cwd), "_", "-")}"
  region = "eu-west-1"

  external_subnets = {
    example = {
      subnets = {
        eu-central-1a = "10.0.201.0/24"
        eu-central-1b = "10.0.202.0/24"
        eu-central-1c = "10.0.203.0/24"
      }
      acls = {
        inbound  = []
        outbound = []
      }
    }
  }


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
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_ipv6 = true

  enable_nat_gateway = false
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overridden-name-public"
  }

  tags = local.tags

  vpc_tags = {
    Name = "vpc-name"
  }
}

################################################################################
# VPC Module External Subnets
################################################################################

module "external_subnets" {
  source = "../../modules/external-subnets"

  name = local.name

  vpc_id = module.vpc.vpc_id
  vgw_id = module.vpc.vgw_id

  external_subnets = local.external_subnets

  tags = local.tags

  depends_on = [
    module.vpc
  ]
}

################################################################################
# VPC Module Network ACLs
################################################################################

module "network_acls" {
  source = "../../modules/network-acls"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.external_subnets.external_subnets

  acl_name = "example"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  depends_on = [
    module.vpc
  ]
}
