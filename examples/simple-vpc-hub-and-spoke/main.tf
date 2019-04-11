provider "aws" {
  region = "eu-west-1"
}

module "hub" {
  source = "../../"

  name = "hub-example"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  assign_generated_ipv6_cidr_block = false

  enable_nat_gateway = true
  single_nat_gateway = true

  create_tgw                 = true
  tgw_auto_accept_shared_attachments = "enable"

  subnet_type_tgw_attachment = "private"
  cidr_tgw                   = ["10.0.0.0/8"]

  public_subnet_tags = {
    Name = "public"
  }

  private_subnet_tags = {
    Name = "private"
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "transit-tgw"
  }

  tgw_tags = {
    Name = "tgw"
  }
}

module "spoke" {
  source = "../../"

  name = "spoke-example"

  cidr = "10.1.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

  assign_generated_ipv6_cidr_block = false

  enable_nat_gateway = false
  single_nat_gateway = false

  attach_tgw = true
  attach_tgw_id = "${element(module.hub.tgw_id, 0)}"

  subnet_type_tgw_attachment = "private"
  cidr_tgw                   = ["10.0.0.0/8", "0.0.0.0/0"]

  private_subnet_tags = {
    Name = "private"
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "spoke-tgw"
  }
}
