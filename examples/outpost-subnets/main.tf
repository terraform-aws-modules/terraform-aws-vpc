provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "../../../terraform-aws-vpc"

  name = "outpost-example"

  cidr = "10.0.0.0/16"

  azs                   = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets        = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  outpost_subnets       = ["10.0.50.0/24", "10.0.51.0/24"]
  create_outpost_subnet = true
  outpost_arn = "arn:aws:outposts:us-west-2:116668991109:outpost/op-0a8c1ab53b023a5a4"
  outpost_az  = "us-west-2a"

  enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overridden-name-public"
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-name"
  }
}
