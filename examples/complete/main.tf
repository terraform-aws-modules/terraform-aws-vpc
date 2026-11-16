provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

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
  source = "../../"

  name = local.name
  cidr = local.vpc_cidr

  azs                 = local.azs
  private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]
  elasticache_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 12)]
  redshift_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 16)]
  intra_subnets       = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 20)]

  private_subnet_names = ["Private Subnet One", "Private Subnet Two"]
  # public_subnet_names omitted to show default name generation for all three subnets
  database_subnet_names    = ["DB Subnet One"]
  elasticache_subnet_names = ["Elasticache Subnet One", "Elasticache Subnet Two"]
  redshift_subnet_names    = ["Redshift Subnet One", "Redshift Subnet Two", "Redshift Subnet Three"]
  intra_subnet_names       = []

  # Subnet naming: `*_subnet_suffix` feeds the generated Name tag for tiers without
  # an explicit `*_subnet_names`
  private_subnet_suffix     = "private"
  public_subnet_suffix      = "public"
  database_subnet_suffix    = "db"
  elasticache_subnet_suffix = "elasticache"
  redshift_subnet_suffix    = "redshift"
  intra_subnet_suffix       = "intra"

  create_database_subnet_group    = true
  database_subnet_group_name      = "${local.name}-db"
  database_subnet_group_tags      = { Tier = "database" }
  create_elasticache_subnet_group = true
  elasticache_subnet_group_name   = "${local.name}-elasticache"
  elasticache_subnet_group_tags   = { Tier = "elasticache" }
  create_redshift_subnet_group    = true
  redshift_subnet_group_name      = "${local.name}-redshift"
  redshift_subnet_group_tags      = { Tier = "redshift" }
  enable_public_redshift          = false

  private_subnet_tags     = { Tier = "private" }
  public_subnet_tags      = { Tier = "public" }
  database_subnet_tags    = { Tier = "database" }
  elasticache_subnet_tags = { Tier = "elasticache" }
  redshift_subnet_tags    = { Tier = "redshift" }
  intra_subnet_tags       = { Tier = "intra" }

  private_subnet_tags_per_az = { "${local.region}a" = { PerAZ = "private-a" } }
  public_subnet_tags_per_az  = { "${local.region}a" = { PerAZ = "public-a" } }

  private_route_table_tags     = { Tier = "private" }
  public_route_table_tags      = { Tier = "public" }
  database_route_table_tags    = { Tier = "database" }
  elasticache_route_table_tags = { Tier = "elasticache" }
  redshift_route_table_tags    = { Tier = "redshift" }
  intra_route_table_tags       = { Tier = "intra" }

  igw_tags              = { Name = "${local.name}-igw" }
  nat_gateway_tags      = { Name = "${local.name}-nat" }
  nat_eip_tags          = { Name = "${local.name}-nat-eip" }
  vpn_gateway_tags      = { Name = "${local.name}-vgw" }
  customer_gateway_tags = { Name = "${local.name}-cgw" }
  dhcp_options_tags     = { Name = "${local.name}-dhcp" }

  # Adopting the VPC's default network ACL, route table and security group is what lets
  # them be locked down; left unmanaged they keep the permissive AWS defaults
  manage_default_network_acl = true
  default_network_acl_name   = "${local.name}-default"
  default_network_acl_tags   = { Name = "${local.name}-default" }
  default_network_acl_ingress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "10.0.0.0/16"
    },
  ]
  default_network_acl_egress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
  ]

  manage_default_route_table           = true
  default_route_table_name             = "${local.name}-default"
  default_route_table_tags             = { Name = "${local.name}-default" }
  default_route_table_routes           = []
  default_route_table_propagating_vgws = []

  # No rules at all: the default security group should deny everything
  manage_default_security_group  = true
  default_security_group_name    = "${local.name}-default"
  default_security_group_tags    = { Name = "${local.name}-default" }
  default_security_group_ingress = []
  default_security_group_egress  = []

  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_network_address_usage_metrics = true
  instance_tenancy                     = "default"
  map_public_ip_on_launch              = false

  create_igw                          = true
  create_multiple_public_route_tables = false
  create_multiple_intra_route_tables  = false
  create_private_nat_gateway_route    = true
  create_database_nat_gateway_route   = true
  nat_gateway_destination_cidr_block  = "0.0.0.0/0"

  propagate_public_route_tables_vgw  = false
  propagate_private_route_tables_vgw = false
  propagate_intra_route_tables_vgw   = false

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  customer_gateways = {
    IP1 = {
      bgp_asn     = 65112
      ip_address  = "1.2.3.4"
      device_name = "some_name"
    },
    IP2 = {
      bgp_asn    = 65112
      ip_address = "5.6.7.8"
    }
    IP3 = {
      bgp_asn_extended = 2147483648
      ip_address       = "5.6.7.8"
    }
  }

  enable_vpn_gateway = true
  vpn_gateway_az     = local.azs[0]
  # `vpn_gateway_id` attaches a gateway created elsewhere, and is mutually exclusive with
  # `enable_vpn_gateway` above
  vpn_gateway_id = ""

  enable_dhcp_options                            = true
  dhcp_options_domain_name                       = "service.consul"
  dhcp_options_domain_name_servers               = ["127.0.0.1", "10.10.0.2"]
  dhcp_options_ntp_servers                       = ["127.0.0.1"]
  dhcp_options_netbios_name_servers              = ["127.0.0.1"]
  dhcp_options_netbios_node_type                 = "2"
  dhcp_options_ipv6_address_preferred_lease_time = 1440

  amazon_side_asn = "64512"

  tags = local.tags
}

################################################################################
# VPC Endpoints Module
################################################################################

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.private_subnets

  create_security_group      = true
  security_group_name_prefix = "${local.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_tags        = { Purpose = "vpc-endpoints" }

  timeouts = {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  endpoints = {
    s3 = {
      service             = "s3"
      private_dns_enabled = true
      dns_options = {
        private_dns_only_for_inbound_resolver_endpoint = false
      }
      tags = { Name = "s3-vpc-endpoint" }
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
      tags            = { Name = "dynamodb-vpc-endpoint" }
    },
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      subnet_configurations = [
        for v in module.vpc.private_subnet_objects :
        {
          ipv4      = cidrhost(v.cidr_block, 10)
          subnet_id = v.id
        }
      ]
    },
    ecs_telemetry = {
      create              = false
      service             = "ecs-telemetry"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
    rds = {
      service             = "rds"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [module.rds_security_group.id]
    },
  }

  tags = merge(local.tags, {
    Project  = "Secret"
    Endpoint = "true"
  })
}

# A fixed security group name rather than a prefix, plus an existing group attached
# alongside the one this module creates
module "vpc_endpoints_existing_sg" {
  source = "../../modules/vpc-endpoints"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_security_group = true
  security_group_name   = "${local.name}-vpc-endpoints-fixed"
  security_group_ids    = [module.rds_security_group.id]

  endpoints = {
    sts = {
      service             = "sts"
      private_dns_enabled = true
      tags                = { Name = "sts-vpc-endpoint" }
    }
  }

  tags = local.tags
}

module "vpc_endpoints_nocreate" {
  source = "../../modules/vpc-endpoints"

  create = false
}

################################################################################
# Disabled
################################################################################

module "disabled" {
  source = "../../"

  create_vpc = false
}

################################################################################
# Supporting Resources
################################################################################

data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name        = "${local.name}-rds"
  description = "Allow PostgreSQL inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    postgresql = {
      description = "TLS from VPC"
      from_port   = 5432
      to_port     = 5432
      ip_protocol = "tcp"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  tags = local.tags
}
