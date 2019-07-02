# There are no private subnets in this VPC setup.
#
# Github issue: https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/46
module "vpc" {
  source = "../../"

  name = "no-private-subnets"

  cidr = "10.0.0.0/16"

  azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets      = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  private_subnets     = []
  database_subnets    = ["10.0.128.0/24", "10.0.129.0/24"]
  elasticache_subnets = ["10.0.131.0/24", "10.0.132.0/24", "10.0.133.0/24"]

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = false

  tags = {
    Issue = "46"
    Name  = "no-private-subnets"
  }
}

