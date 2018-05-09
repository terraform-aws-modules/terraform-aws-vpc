# List of AZs and private subnets are not of equal length
#
# This example creates resources which are not present in all AZs.
# This should be seldomly needed from architectural point of view,
# and it can also lead this module to some edge cases.
#
# Github issue: https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/44
module "vpc" {
  source = "../../"

  name = "asymmetrical"

  cidr = "10.0.0.0/16"

  azs              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets  = ["10.0.1.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  create_database_subnet_group = true
  enable_nat_gateway           = true

  tags = {
    Issue = "44"
    Name  = "asymmetrical"
  }
}
