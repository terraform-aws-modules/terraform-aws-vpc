provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# Issue 44 - https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/44
################################################################################

module "vpc_issue_44" {
  source = "../../"

  name = "asymmetrical"
  cidr = "10.0.0.0/16"

  azs              = local.azs
  private_subnets  = ["10.0.1.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  create_database_subnet_group = true
  enable_nat_gateway           = true

  tags = merge({
    Issue = "44"
    Name  = "asymmetrical"
  }, local.tags)
}

################################################################################
# Issue 46 - https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/46
################################################################################

module "vpc_issue_46" {
  source = "../../"

  name = "no-private-subnets"
  cidr = "10.0.0.0/16"

  azs                 = local.azs
  public_subnets      = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  private_subnets     = []
  database_subnets    = ["10.0.128.0/24", "10.0.129.0/24"]
  elasticache_subnets = ["10.0.131.0/24", "10.0.132.0/24", "10.0.133.0/24"]

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = false

  tags = merge({
    Issue = "46"
    Name  = "no-private-subnets"
  }, local.tags)
}

################################################################################
# Issue 108 - https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/108
################################################################################

module "vpc_issue_108" {
  source = "../../"

  name = "route-already-exists"
  cidr = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.254.240/28", "10.0.254.224/28", "10.0.254.208/28"]

  single_nat_gateway = true
  enable_nat_gateway = true

  tags = merge({
    Issue = "108"
    Name  = "route-already-exists"
  }, local.tags)
}

################################################################################
# Issue 1182 - https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1182
################################################################################

module "vpc_issue_1182" {
  source = "../../"

  name = "route-table"
  cidr = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  enable_vpn_gateway = true

  tags = merge({
    Issue = "1182"
    Name  = "route-table"
  }, local.tags)
}
