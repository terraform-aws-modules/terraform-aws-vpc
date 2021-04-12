provider "aws" {
  region  = "us-east-1"
  profile = "ng-operations"
}

module "vpc" {
  source = "../../"

  name = "for-each-example"

  cidr = "10.0.0.0/16"

  azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  database_subnets    = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
  redshift_subnets    = ["10.0.9.0/24", "10.0.10.0/24", "10.0.11.0/24"]
  elasticache_subnets = ["10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24"]
  intra_subnets       = ["10.0.15.0/24", "10.0.16.0/24", "10.0.17.0/24"]
  public_subnets      = ["10.0.254.240/28", "10.0.254.224/28", "10.0.254.208/28"]

  single_nat_gateway = true
  enable_nat_gateway = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
}

resource "aws_ram_resource_share" "private_subnets" {
  for_each                  = module.vpc.private_subnets_map
  name                      = "for-each-example-private-subnets"
  allow_external_principals = false
}
resource "aws_ram_resource_share" "database_subnets" {
  for_each                  = module.vpc.database_subnets_map
  name                      = "for-each-example-database-subnets"
  allow_external_principals = false
}
resource "aws_ram_resource_share" "redshift_subnets" {
  for_each                  = module.vpc.redshift_subnets_map
  name                      = "for-each-example-redshift-subnets"
  allow_external_principals = false
}
resource "aws_ram_resource_share" "elasticache_subnets" {
  for_each                  = module.vpc.elasticache_subnets_map
  name                      = "for-each-example-elasticache-subnets"
  allow_external_principals = false
}
resource "aws_ram_resource_share" "intra_subnets" {
  for_each                  = module.vpc.intra_subnets_map
  name                      = "for-each-example-intra-subnets"
  allow_external_principals = false
}
resource "aws_ram_resource_share" "public_subnets" {
  for_each                  = module.vpc.public_subnets_map
  name                      = "for-each-example-public-subnets"
  allow_external_principals = false
}
