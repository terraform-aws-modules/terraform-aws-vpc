provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

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
  source = "../.."

  name = local.name
  cidr = local.vpc_cidr

  azs                 = local.azs
  private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]
  elasticache_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 12)]
  redshift_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 16)]
  intra_subnets       = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 20)]

  enable_nat_gateway = true

  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_ipv6 = true

  public_subnet_ipv6_prefixes      = [0, 1, 2]
  private_subnet_ipv6_prefixes     = [3, 4, 5]
  database_subnet_ipv6_prefixes    = [6, 7, 8]
  elasticache_subnet_ipv6_prefixes = [9, 10, 11]
  redshift_subnet_ipv6_prefixes    = [12, 13, 14]
  intra_subnet_ipv6_prefixes       = [15, 16, 17]

  public_subnet_assign_ipv6_address_on_creation      = true
  private_subnet_assign_ipv6_address_on_creation     = true
  database_subnet_assign_ipv6_address_on_creation    = true
  elasticache_subnet_assign_ipv6_address_on_creation = true
  redshift_subnet_assign_ipv6_address_on_creation    = true
  intra_subnet_assign_ipv6_address_on_creation       = true

  # Dual-stack subnets keep their IPv4 CIDR, so none of them is IPv6 native
  public_subnet_ipv6_native      = false
  private_subnet_ipv6_native     = false
  database_subnet_ipv6_native    = false
  elasticache_subnet_ipv6_native = false
  redshift_subnet_ipv6_native    = false
  intra_subnet_ipv6_native       = false

  # DNS64 lets IPv6-only clients reach IPv4-only destinations through NAT64
  public_subnet_enable_dns64      = true
  private_subnet_enable_dns64     = true
  database_subnet_enable_dns64    = true
  elasticache_subnet_enable_dns64 = true
  redshift_subnet_enable_dns64    = true
  intra_subnet_enable_dns64       = true

  # AAAA records on launch require the resource-name hostname type
  public_subnet_private_dns_hostname_type_on_launch      = "resource-name"
  private_subnet_private_dns_hostname_type_on_launch     = "resource-name"
  database_subnet_private_dns_hostname_type_on_launch    = "resource-name"
  elasticache_subnet_private_dns_hostname_type_on_launch = "resource-name"
  redshift_subnet_private_dns_hostname_type_on_launch    = "resource-name"
  intra_subnet_private_dns_hostname_type_on_launch       = "resource-name"

  public_subnet_enable_resource_name_dns_a_record_on_launch      = true
  private_subnet_enable_resource_name_dns_a_record_on_launch     = true
  database_subnet_enable_resource_name_dns_a_record_on_launch    = true
  elasticache_subnet_enable_resource_name_dns_a_record_on_launch = true
  redshift_subnet_enable_resource_name_dns_a_record_on_launch    = true
  intra_subnet_enable_resource_name_dns_a_record_on_launch       = true

  public_subnet_enable_resource_name_dns_aaaa_record_on_launch      = true
  private_subnet_enable_resource_name_dns_aaaa_record_on_launch     = true
  database_subnet_enable_resource_name_dns_aaaa_record_on_launch    = true
  elasticache_subnet_enable_resource_name_dns_aaaa_record_on_launch = true
  redshift_subnet_enable_resource_name_dns_aaaa_record_on_launch    = true
  intra_subnet_enable_resource_name_dns_aaaa_record_on_launch       = true

  tags = local.tags
}

################################################################################
# Disabled
################################################################################

module "disabled" {
  source = "../.."

  create_vpc = false
}
