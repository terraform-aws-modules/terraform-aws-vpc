provider "aws" {
  region = "eu-west-1"
}

module "vpc-1" {
  source = "../../"

  name = "VPC-1"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  assign_generated_ipv6_cidr_block = false

  enable_nat_gateway = true
  single_nat_gateway = true

  create_tgw                 = true
  subnet_type_tgw_attachment = "public"
  cidr_tgw                   = ["10.1.0.0/16"]

  public_subnet_tags = {
    Name = "public"
  }

  private_subnet_tags = {
    Name = "private"
  }

  tags = {
    Owner       = "user"
    Environment = "dev1"
  }

  vpc_tags = {
    Name = "transit-tgw"
  }

  tgw_tags = {
    Name = "tgw"
  }
}

module "vpc-2" {
  source = "../../"

  name = "VPC-2"

  cidr = "10.1.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  assign_generated_ipv6_cidr_block = false

  enable_nat_gateway = true
  single_nat_gateway = true

  attach_tgw           = true
  attach_tgw_id        = "${element(module.vpc-1.tgw_id, 0)}"
  attach_tgw_route_vpc = true
  tgw_rt_id            = "${element(module.vpc-1.tgw_rt_id, 0)}"

  subnet_type_tgw_attachment = "public"
  cidr_tgw                   = ["10.0.0.0/16"]

  public_subnet_tags = {
    Name = "public"
  }

  private_subnet_tags = {
    Name = "private"
  }

  tags = {
    Owner       = "user"
    Environment = "dev2"
  }

  vpc_tags = {
    Name = "transit-tgw"
  }

  tgw_tags = {
    Name = "tgw"
  }
}
