provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"

  network_acls = {
    default_inbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    default_outbound = [
      {
        rule_number = 900
        rule_action = "allow"
        from_port   = 32768
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number     = 140
        rule_action     = "allow"
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        ipv6_cidr_block = "::/0"
      },
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 1433
        to_port     = 1433
        protocol    = "tcp"
        cidr_block  = "10.0.100.0/22"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "10.0.100.0/22"
      },
      {
        rule_number = 140
        rule_action = "allow"
        icmp_code   = -1
        icmp_type   = 8
        protocol    = "icmp"
        cidr_block  = "10.0.0.0/22"
      },
      {
        rule_number     = 150
        rule_action     = "allow"
        from_port       = 90
        to_port         = 90
        protocol        = "tcp"
        ipv6_cidr_block = "::/0"
      },
    ]
    elasticache_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 140
        rule_action = "allow"
        icmp_code   = -1
        icmp_type   = 12
        protocol    = "icmp"
        cidr_block  = "10.0.0.0/22"
      },
      {
        rule_number     = 150
        rule_action     = "allow"
        from_port       = 90
        to_port         = 90
        protocol        = "tcp"
        ipv6_cidr_block = "::/0"
      },
    ]
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../"

  name = "network-acls-example"
  cidr = "10.0.0.0/16"

  azs                 = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets      = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  elasticache_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  public_dedicated_network_acl   = true
  public_inbound_acl_rules       = concat(local.network_acls["default_inbound"], local.network_acls["public_inbound"])
  public_outbound_acl_rules      = concat(local.network_acls["default_outbound"], local.network_acls["public_outbound"])
  elasticache_outbound_acl_rules = concat(local.network_acls["default_outbound"], local.network_acls["elasticache_outbound"])

  private_dedicated_network_acl     = false
  elasticache_dedicated_network_acl = true

  manage_default_network_acl = true

  enable_ipv6 = true

  enable_nat_gateway = false
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
