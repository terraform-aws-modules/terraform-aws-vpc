provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../../"

  name = "vpc-shared-subnets"

  cidr = "10.10.0.0/16"

  azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets      = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
  database_subnets    = ["10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24"]
  elasticache_subnets = ["10.10.31.0/24", "10.10.32.0/24", "10.10.33.0/24"]
  redshift_subnets    = ["10.10.41.0/24", "10.10.42.0/24", "10.10.43.0/24"]
  shared_subnets      = ["10.10.51.0/24", "10.10.52.0/24", "10.10.53.0/24"]

  create_database_subnet_route_table    = true
  create_elasticache_subnet_route_table = true
  create_redshift_subnet_route_table    = true

  enable_vpn_gateway                 = true
  propagate_private_route_tables_vgw = false
  propagate_public_route_tables_vgw  = false
  propagate_shared_route_tables_vgw  = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  single_nat_gateway = true
  enable_nat_gateway = true

  tags = {
    Provisioner = "terraform"
    TFTemplate  = "vpc"
  }
}
