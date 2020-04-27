provider "aws" {
  access_key                  = "mock_access_key"
  region                      = var.region
  s3_force_path_style         = true
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localstack:4567"
    cloudformation = "http://localstack:4581"
    cloudwatch     = "http://localstack:4582"
    dynamodb       = "http://localstack:4569"
    es             = "http://localstack:4578"
    firehose       = "http://localstack:4573"
    iam            = "http://localstack:4593"
    kinesis        = "http://localstack:4568"
    lambda         = "http://localstack:4574"
    route53        = "http://localstack:4580"
    redshift       = "http://localstack:4577"
    s3             = "http://localstack:4572"
    secretsmanager = "http://localstack:4584"
    ses            = "http://localstack:4579"
    sns            = "http://localstack:4575"
    sqs            = "http://localstack:4576"
    ssm            = "http://localstack:4583"
    stepfunctions  = "http://localstack:4585"
    sts            = "http://localstack:4592"
    ec2            = "http://localstack:4597"
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "../../"

  name = var.vpc_name

  cidr = "10.120.0.0/16"

  azs                     = ["eu-west-1a", "eu-west-1c"]
  compute_public_subnets  = ["10.120.3.0/24", "10.120.4.0/24"]
  compute_private_subnets = ["10.120.0.0/24", "10.120.1.0/24"]
  lb_subnets              = ["10.120.5.0/24", "10.120.6.0/24"]
  database_subnets        = ["10.120.7.0/24", "10.120.8.0/24"]

  create_database_subnet_group = false
  enable_nat_gateway           = true
  single_nat_gateway           = true

  create_database_subnet_route_table = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

variable "vpc_name" {}
variable "region" {}
