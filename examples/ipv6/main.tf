provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "../.."

  name = "ipv6"

  cidr = "10.0.0.0/16"

  private_subnets = {
    "subnet-1" = {
      cidr = "10.0.1.0/24",
      az   = data.aws_availability_zones.available.names[0]
    },
    "subnet-2" = {
      cidr = "10.0.2.0/24",
      az   = data.aws_availability_zones.available.names[1]
    }
  }
  public_subnets = {
    "subnet-3" = {
      cidr = "10.0.101.0/24",
      az   = data.aws_availability_zones.available.names[0]
    },
    "subnet-4" = {
      cidr = "10.0.102.0/24",
      az   = data.aws_availability_zones.available.names[1]
    }
  }
  database_subnets = {
    "subnet-5" = {
      cidr = "10.0.103.0/24",
      az   = data.aws_availability_zones.available.names[0]
    },
    "subnet-6" = {
      cidr = "10.0.104.0/24",
      az   = data.aws_availability_zones.available.names[1]
    }
  }

  enable_nat_gateway = false

  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true

  private_subnet_assign_ipv6_address_on_creation = false

  public_subnet_ipv6_prefixes   = [0, 1]
  private_subnet_ipv6_prefixes  = [2, 3]
  database_subnet_ipv6_prefixes = [4, 5]

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
