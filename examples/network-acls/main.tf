provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "../../"

  name = "network-acls-example"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  public_inbound_acls = [
    "100", "allow", 80,    80,    "tcp", "0.0.0.0/0",       "Allows inbound HTTP traffic from any IPv4 address",
    "110", "allow", 443,   443,   "tcp", "0.0.0.0/0",       "Allows inbound HTTPS traffic from any IPv4 address",
    "120", "allow", 22,    22,    "tcp", "0.0.0.0/0",       "Allows inbound SSH traffic from any IPv4 address",
    "130", "allow", 3389,  3389,  "tcp", "0.0.0.0/0",       "Allows inbound RDP traffic from any IPv4 address",
    "140", "allow", 1024,  65535, "tcp", "0.0.0.0/0",       "Allows inbound return traffic from hosts"
  ]

  public_outbound_acls = [
    "100", "allow", 80,    80,    "tcp", "0.0.0.0/0",       "Allows outbound HTTP traffic from the subnet to the Internet",
    "110", "allow", 443,   443,   "tcp", "0.0.0.0/0",       "Allows outbound HTTPS traffic from the subnet to the Internet",
    "120", "allow", 1433,  1433,  "tcp", "10.0.100.0/22",   "Allows outbound MS SQL access to database servers in the private subnet",
    "140", "allow", 32768, 65535, "tcp", "0.0.0.0/0",       "Allows outbound responses to clients on the Internet",
    "150", "allow", 22,    22,    "tcp", "10.0.100.0/22",   "Allows outbound SSH access to instances in your private subnet"
  ]

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overridden-name-public"
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-name"
  }
}
