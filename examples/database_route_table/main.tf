provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

locals {
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["${var.vpc_cidr_prefix}.0.0/20", "${var.vpc_cidr_prefix}.16.0/20", "${var.vpc_cidr_prefix}.32.0/20"]
  database_subnets = ["${var.vpc_cidr_prefix}.48.0/24", "${var.vpc_cidr_prefix}.50.0/24"]
  public_subnets = ["${var.vpc_cidr_prefix}.128.0/20", "${var.vpc_cidr_prefix}.144.0/20", "${var.vpc_cidr_prefix}.160.0/20"]
}

module "vpc" {
  #  source  = "terraform-aws-modules/vpc/aws"
  # version = "2.0"
  source  = "../.."

  name = "${var.region_prefix}-${var.environment}-${var.application_name}-VPC"
  cidr = "${var.vpc_cidr_prefix}.0.0/16"

  azs             = local.availability_zones
  private_subnets = local.private_subnets
  private_subnet_tags = {
    Name = "${var.region_prefix}-${var.environment}-${var.application_name}-VPC-PrivateSubnet"
    Application_Role = "Private Subnet"
  }
  public_subnets  = local.public_subnets
  public_subnet_tags = {
    Name = "${var.region_prefix}-${var.environment}-${var.application_name}-VPC-PublicSubnet"
    Application_Role = "Public Subnet"
  }

  database_subnet_suffix = "Database"
  database_subnets = local.database_subnets
  database_subnet_tags = {
    Name = "${var.region_prefix}-${var.environment}-${var.application_name}-VPC-DatabaseSubnet"
    Application_Role = "Database Subnet"
  }
  create_database_subnet_route_table = true
  create_database_subnet_group = false
  create_database_nat_gateway_route = true
  database_route_table_tags = {
    Name = "${var.region_prefix}-${var.environment}-${var.application_name}-RT-Database"
    Application_Role = "Database Route Table"
  }

  enable_nat_gateway = true
  # this means we use 1 NAT gateway which is cheaper but not HA if an AZ goes down
  # we need to determine if multiple NAT gateways are needed (especially in a dev environment)
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support = true
  enable_dhcp_options = true

  enable_s3_endpoint = false
  enable_dynamodb_endpoint = false

  tags = {
    Name = "${var.region_prefix}-${var.environment}-${var.application_name}-VPC"
    Application_Role = "Network"
    Terraform = "true"
  }
}
