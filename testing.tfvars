name = "vpc-module-test"
tags = {
  GithubRepo = "terraform-aws-vpc"
  GithubOrg  = "terraform-aws-modules"
}

################################################################################
# VPC Module
################################################################################

cidr                  = "10.0.0.0/16"
secondary_cidr_blocks = ["100.64.0.0/16"]

azs                 = ["us-west-2a", "us-west-2b", "us-west-2c"]
private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets      = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
vpc_private_subnets = ["100.64.0.0/24", "100.64.1.0/24", "100.64.2.0/24"]

enable_ipv6 = false

enable_nat_gateway = true
single_nat_gateway = false

enable_vpc_private_nat_gateway = true
single_vpc_private_nat_gateway = false

public_subnet_tags = {
  Name = "Public Subnets VPC Module"
}

private_subnet_tags = {
  Name = "Private Subnets VPC Module"
}

vpc_private_subnet_tags = {
  Name = "VPC Private VPC Module"
}

vpc_tags = {
  Name = "VPC Module"
}
