provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../"

  name = "example-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  create_instance_connect_endpoint      = true
  instance_connect_subnet_id            = element(module.vpc.private_subnets, 0)
  instance_connect_security_group_ids   = [aws_security_group.allow_ssh.id]
  instance_connect_preserve_client_ip   = false
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH access for EC2 Instance Connect"
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
}
