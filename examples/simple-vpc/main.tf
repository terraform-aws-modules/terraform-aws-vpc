provider "aws" {
  region  = "us-east-1"
  version = "~> 2.6"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "../../"

  name = "simple-example"

  enable_ram_share = true
  principal_id     = "arn:aws:organizations::880141098094:ou/o-45gl6wapoa/ou-24vr-k9bsbjlu"

  cidr = "10.0.0.0/16"

  azs              = ["use1-az1", "use1-az2", "use1-az3"]
  public_subnets   = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  private_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # enable_ipv6 = true

  enable_nat_gateway                 = true
  create_database_subnet_route_table = true

  public_subnet_tags = {
    Name = "tftestpublic"
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "tfmodtest"
  }
}

