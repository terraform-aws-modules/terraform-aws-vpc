provider "aws" {
  region = "eu-west-1"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "../../"

  name = "flow-log-provided-cloudwatch-log-group"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_flow_log = true
  create_flow_log_cloudwatch_log_group = false
  flow_log_destination_arn = aws_cloudwatch_log_group.vpc_flow_log.arn

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name = "aws-vpc-module-test-flow-logs"
}
