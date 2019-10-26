provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../"

  name = "route-already-exists"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.254.240/28", "10.0.254.224/28", "10.0.254.208/28"]

  single_nat_gateway = true
  enable_nat_gateway = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
}
