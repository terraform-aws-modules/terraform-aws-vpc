################################################################################
# Provider Configuration
################################################################################

provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

################################################################################
# Locals
################################################################################

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-east-1"

  # Get the first 2 availability zones for simplicity
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Base VPC CIDR
  vpc_cidr = "10.0.0.0/16"

  # Calculate subnet CIDRs automatically based on AZ count
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 10)]

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../.."

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  # EC2 Instance Connect Endpoint Configuration
  create_instance_connect_endpoint    = true
  instance_connect_preserve_client_ip = true
  instance_connect_security_group_ids = [aws_security_group.allow_ssh.id]
  instance_connect_tags = {
    Environment = "example"
  }

  tags = merge(local.tags, {
    Name = local.name
  })
}

################################################################################
# Security Group for EC2 Instance Connect
################################################################################

resource "aws_security_group" "allow_ssh" {
  name        = "${local.name}-allow-ssh"
  description = "Allow SSH for EC2 Instance Connect"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name}-allow-ssh"
  })
}
