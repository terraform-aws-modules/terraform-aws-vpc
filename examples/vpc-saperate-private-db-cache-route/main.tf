provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "./terraform-aws-vpc"

  name = "sandbox"

  cidr = "10.10.0.0/16"

  azs                 = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets     = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets      = ["10.10.11.0/24", "10.10.12.0/24"]
  database_subnets    = ["10.10.21.0/24", "10.10.22.0/24"]
  elasticache_subnets = ["10.10.31.0/24", "10.10.32.0/24"]
  redshift_subnets    = ["10.10.41.0/24", "10.10.42.0/24"]

  create_database_subnet_group   = false
  create_database_route_table    = true
  create_elasticache_route_table = true
  enable_nat_gateway             = true

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "complete"
  }
}
