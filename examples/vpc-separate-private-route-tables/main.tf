provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../../"

  name = "vpc-separate-private-route-tables"

  cidr = "10.10.0.0/16"

  private_subnets = {
    "subnet-1" = {
      cidr = "10.10.1.0/24",
      az   = "eu-west-1a"
    },
    "subnet-2" = {
      cidr = "10.10.2.0/24",
      az   = "eu-west-1b"
    },
    "subnet-3" = {
      cidr = "10.10.3.0/24",
      az   = "eu-west-1c"
    }
  }
  public_subnets = {
    "subnet-4" = {
      cidr = "10.10.11.0/24",
      az   = "eu-west-1a"
    },
    "subnet-5" = {
      cidr = "10.10.12.0/24",
      az   = "eu-west-1b"
    },
    "subnet-6" = {
      cidr = "10.10.13.0/24",
      az   = "eu-west-1c"
    }
  }
  database_subnets = {
    "subnet-7" = {
      cidr = "10.10.21.0/24",
      az   = "eu-west-1a"
    },
    "subnet-8" = {
      cidr = "10.10.22.0/24",
      az   = "eu-west-1b"
    },
    "subnet-9" = {
      cidr = "10.10.23.0/24",
      az   = "eu-west-1c"
    }
  }
  elasticache_subnets = {
    "subnet-10" = {
      cidr = "10.10.31.0/24",
      az   = "eu-west-1a"
    },
    "subnet-11" = {
      cidr = "10.10.32.0/24",
      az   = "eu-west-1b"
    },
    "subnet-12" = {
      cidr = "10.10.33.0/24",
      az   = "eu-west-1c"
    }
  }
  redshift_subnets = {
    "subnet-13" = {
      cidr = "10.10.41.0/24",
      az   = "eu-west-1a"
    },
    "subnet-14" = {
      cidr = "10.10.42.0/24",
      az   = "eu-west-1b"
    },
    "subnet-15" = {
      cidr = "10.10.43.0/24",
      az   = "eu-west-1c"
    }
  }

  create_database_subnet_route_table    = true
  create_elasticache_subnet_route_table = true
  create_redshift_subnet_route_table    = true

  single_nat_gateway = true
  enable_nat_gateway = true

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "separate-private-route-tables"
  }
}

