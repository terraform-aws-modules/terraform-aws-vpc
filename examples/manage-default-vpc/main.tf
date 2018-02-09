provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../../"

  create_vpc = true
  cidr       = "10.0.0.0/20"

  manage_default_vpc               = true
  default_vpc_enable_dns_hostnames = true
}
