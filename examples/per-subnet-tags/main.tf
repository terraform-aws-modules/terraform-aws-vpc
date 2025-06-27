provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnet_names = [
    "puba", "pubb", "pubc",
  ]
  public_subnet_tags_by_name = {
    "puba" = { "test" = "puba", "custom" = "foobar" },
    "pubb" = { "test" = "pubb" },
    "pubc" = { "test" = "pubc" },
  }

  private_subnet_names = [
    "priva", "privb", "privc",
    "privd", "prive", "privf",
  ]
  private_subnet_tags_by_name = {
    "priva" = { "test" = "priva" },
    "privb" = { "test" = "privb", "custom" = "private-b-tag" },
    "privc" = { "test" = "privc" },
  }

  database_subnet_names = ["dba", "dbb", "dbc"]
  database_subnet_tags_by_name = {
    "dba" = { "test" = "dba" }
    "dbb" = { "test" = "dbb" }
    "dbc" = { "test" = "dbc", "custom" = "more-tests" }
  }

  elasticache_subnet_names = ["eca", "ecb", "ecc", "ecd", "ece", "ecf"]
  elasticache_subnet_tags_by_name = {
    "eca" = { "test" = "eca" },
    "ecb" = { "test" = "ecb" },
    "ecc" = { "test" = "ecc", "custom" = "elasticache-test" },
  }

  intra_subnet_names = ["inta", "intb", "intc"]
  intra_subnet_tags_by_name = {
    "inta" = { "test" = "inta", "custom" = "intra-subnet-tag" },
    "intb" = { "test" = "intb" },
    "intc" = { "test" = "intc" },
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
  cidr = local.vpc_cidr

  azs = local.azs

  private_subnet_names        = local.private_subnet_names
  private_subnets             = [for k, v in local.private_subnet_names : cidrsubnet(local.vpc_cidr, 4, k)]
  private_subnet_tags_by_name = local.private_subnet_tags_by_name

  public_subnet_names        = local.public_subnet_names
  public_subnets             = [for k, v in local.public_subnet_names : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnet_tags_by_name = local.public_subnet_tags_by_name

  database_subnet_names        = local.database_subnet_names
  database_subnets             = [for k, v in local.database_subnet_names : cidrsubnet(local.vpc_cidr, 4, k)]
  database_subnet_tags_by_name = local.database_subnet_tags_by_name

  elasticache_subnet_names        = local.elasticache_subnet_names
  elasticache_subnets             = [for k, v in local.elasticache_subnet_names : cidrsubnet(local.vpc_cidr, 4, k)]
  elasticache_subnet_tags_by_name = local.elasticache_subnet_tags_by_name

  intra_subnet_names        = local.intra_subnet_names
  intra_subnets             = [for k, v in local.intra_subnet_names : cidrsubnet(local.vpc_cidr, 4, k)]
  intra_subnet_tags_by_name = local.intra_subnet_tags_by_name

  tags = local.tags
}
