# There are no private subnets in this VPC setup.
#
# Github issue: https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/46
module "vpc" {
  source = "../../"

  name = "no-private-subnets"

  cidr = "10.0.0.0/16"

  public_subnets = {
    "subnet-1" = {
      cidr = "10.0.0.0/22",
      az   = "eu-west-1a"
    },
    "subnet-2" = {
      cidr = "10.0.4.0/22",
      az   = "eu-west-1b"
    },
    "subnet-3" = {
      cidr = "10.0.8.0/22",
      az   = "eu-west-1c"
    }
  }
  database_subnets = {
    "subnet-4" = {
      cidr = "10.0.128.0/24",
      az   = "eu-west-1a"
    },
    "subnet-5" = {
      cidr = "10.0.129.0/24",
      az   = "eu-west-1b"
    }
  }
  elasticache_subnets = {
    "subnet-6" = {
      cidr = "10.0.131.0/24",
      az   = "eu-west-1a"
    },
    "subnet-7" = {
      cidr = "10.0.132.0/24",
      az   = "eu-west-1b"
    },
    "subnet-8" = {
      cidr = "10.0.133.0/24",
      az   = "eu-west-1c"
    }
  }

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = false

  tags = {
    Issue = "46"
    Name  = "no-private-subnets"
  }
}

