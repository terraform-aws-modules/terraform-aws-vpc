provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../../"

  enabled = false

  manage_default_vpc               = true
  default_vpc_name                 = "default"
  default_vpc_enable_dns_hostnames = true
}

