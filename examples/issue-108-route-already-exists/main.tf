provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../"

  name = "route-already-exists"

  cidr = "10.0.0.0/16"

  private_subnets = {
    "subnet-1" = {
      cidr = "10.0.0.0/24",
      az   = "eu-west-1a"
    },
    "subnet-2" = {
      cidr = "10.0.1.0/24",
      az   = "eu-west-1b"
    },
    "subnet-3" = {
      cidr = "10.0.2.0/24",
      az   = "eu-west-1c"
    }
  }
  public_subnets = {
    "subnet-4" = {
      cidr = "10.0.254.240/28",
      az   = "eu-west-1a"
    },
    "subnet-5" = {
      cidr = "10.0.254.224/28",
      az   = "eu-west-1b"
    },
    "subnet-6" = {
      cidr = "10.0.254.208/28",
      az   = "eu-west-1c"
    }
  }

  single_nat_gateway = true
  enable_nat_gateway = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
}
