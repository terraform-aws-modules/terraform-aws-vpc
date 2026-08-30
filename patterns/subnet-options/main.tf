provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"

  # this pattern names its zones by ID rather than by name, so the two zone
  # lists are indexed together and only the IDs are handed to the subnets
  zone_ids = slice(data.aws_availability_zones.available.zone_ids, 0, 2)

  tags = {
    Pattern    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# Subnet with an externally allocated Elastic IP
#
# The NAT gateway is handed an allocation that was created outside the sub-module,
# which is what `create_eip = false` is for. Every timeout the sub-module accepts is
# set here, including one on a single route that overrides the map-wide default
################################################################################

module "external_eip_subnet" {
  source = "../../modules/subnet"

  name   = "${local.name}-external-eip"
  vpc_id = module.vpc.vpc_id

  # the zone is identified by ID, which is stable across accounts, rather than by
  # name, which is not. The two arguments are mutually exclusive
  availability_zone_id = local.zone_ids[0]

  ipv4_cidr_block = cidrsubnet(local.vpc_cidr, 8, 0)
  ipv6_cidr_block = cidrsubnet(module.vpc.vpc_ipv6_cidr_block, 8, 0)

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  # instance hostnames follow the instance ID rather than its IPv4 address, and both
  # record types answer for that name. The A and AAAA settings are only accepted
  # alongside the `resource-name` hostname type
  private_dns_hostname_type_on_launch            = "resource-name"
  enable_resource_name_dns_a_record_on_launch    = true
  enable_resource_name_dns_aaaa_record_on_launch = true

  # ranges held back from automatic assignment. An explicit reservation is handed out
  # only when asked for by address, a prefix reservation backs ENI prefix delegation
  cidr_reservations = {
    explicit = {
      cidr_block       = cidrsubnet(cidrsubnet(local.vpc_cidr, 8, 0), 4, 1)
      description      = "Held for statically addressed appliances"
      reservation_type = "explicit"
    }
    prefix = {
      cidr_block       = cidrsubnet(cidrsubnet(local.vpc_cidr, 8, 0), 4, 2)
      description      = "Held for ENI prefix delegation"
      reservation_type = "prefix"
    }
  }

  # the address is allocated below rather than by the sub-module, so the allocation ID
  # has to be passed in. `create_eip = false` without it fails at apply
  create_nat_gateway        = true
  create_eip                = false
  nat_gateway_allocation_id = aws_eip.nat.id
  nat_gateway_tags          = { Tier = "external-eip" }

  # routes the virtual private gateway learns are copied into this table
  route_table_propagating_vgws = [aws_vpn_gateway.this.id]

  routes = {
    ipv4 = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      gateway_id                  = module.vpc.igw_id

      # a route carrying its own timeouts ignores `route_timeouts` below
      timeouts = {
        create = "6m"
        update = "3m"
        delete = "6m"
      }
    }
    # no timeouts of its own, so this route falls back to `route_timeouts`
    ipv6 = {
      destination_ipv6_cidr_block = "::/0"
      gateway_id                  = module.vpc.igw_id
    }
  }

  timeouts = {
    create = "12m"
    delete = "25m"
  }

  route_table_timeouts = {
    create = "6m"
    update = "3m"
    delete = "6m"
  }

  route_timeouts = {
    create = "4m"
    update = "3m"
    delete = "4m"
  }

  route_table_association_timeouts = {
    create = "6m"
    update = "3m"
    delete = "6m"
  }

  tags = local.tags
}

################################################################################
# Subnet with a sub-module managed Elastic IP
#
# The counterpart to the subnet above: the sub-module allocates the address itself,
# which is the only arrangement in which `eip_tags` has anything to tag. It also joins
# an existing network ACL rather than staying on the VPC default
################################################################################

module "managed_eip_subnet" {
  source = "../../modules/subnet"

  name   = "${local.name}-managed-eip"
  vpc_id = module.vpc.vpc_id

  availability_zone_id = local.zone_ids[1]

  ipv4_cidr_block = cidrsubnet(local.vpc_cidr, 8, 1)
  ipv6_cidr_block = cidrsubnet(module.vpc.vpc_ipv6_cidr_block, 8, 1)

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  # `create_eip` defaults to true, so the address and its tags belong to the sub-module
  create_nat_gateway = true
  eip_tags           = { Tier = "managed-eip" }
  nat_gateway_tags   = { Tier = "managed-eip" }

  # the two timeout blocks the other subnet cannot reach: it brings its own address, so
  # the sub-module creates no Elastic IP there to carry them
  eip_timeouts = {
    read   = "16m"
    update = "6m"
    delete = "4m"
  }

  nat_gateway_timeouts = {
    create = "12m"
    update = "12m"
    delete = "35m"
  }

  # a network ACL is normally shared by several subnets, so the subnet joins one
  create_network_acl_association = true
  network_acl_id                 = aws_network_acl.this.id

  routes = {
    ipv4 = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      gateway_id                  = module.vpc.igw_id
    }
  }

  tags = local.tags
}

################################################################################
# A group carrying its own network ACL
#
# The network ACL belongs to the group sub-module rather than to a subnet, because one
# ACL covers several subnets. Nothing else sets `network_acl_rules`, and a rule resource
# that is never created is a rule resource that can regress silently
################################################################################

module "acl_group" {
  source = "../../modules/subnets"

  name   = "${local.name}-acl"
  vpc_id = module.vpc.vpc_id

  subnets = {
    a = {
      availability_zone_id = local.zone_ids[0]
      ipv4_cidr_block      = cidrsubnet(local.vpc_cidr, 8, 10)
    }
    b = {
      availability_zone_id = local.zone_ids[1]
      ipv4_cidr_block      = cidrsubnet(local.vpc_cidr, 8, 11)
    }
  }

  create_network_acl = true
  network_acl_tags   = { Tier = "acl-group" }

  # a network ACL denies everything it is not told to allow, and the two directions are
  # separate because it is stateless: the reply to an allowed inbound packet needs an
  # outbound rule of its own
  network_acl_rules = {
    inbound_https = {
      rule_number = 100
      rule_action = "allow"
      protocol    = "tcp"
      cidr_block  = local.vpc_cidr
      from_port   = 443
      to_port     = 443
    }
    inbound_ephemeral = {
      rule_number = 110
      rule_action = "allow"
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      from_port   = 1024
      to_port     = 65535
    }
    # an ICMP rule carries a type and a code where a TCP rule carries ports
    inbound_icmp = {
      rule_number = 120
      rule_action = "allow"
      protocol    = "icmp"
      cidr_block  = local.vpc_cidr
      icmp_type   = -1
      icmp_code   = -1
    }
    deny_ipv6 = {
      rule_number     = 130
      rule_action     = "deny"
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    }
    outbound_all = {
      egress      = true
      rule_number = 100
      rule_action = "allow"
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  }

  tags = local.tags
}

################################################################################
# Disabled
#
# Creates nothing. Every output falls back to null rather than failing to evaluate
################################################################################

module "disabled" {
  source = "../../modules/subnet"

  create = false
}

module "disabled_group" {
  source = "../../modules/subnets"

  create = false

  # everything the group would build is described, and none of it is created
  subnets = {
    a = {
      availability_zone_id = local.zone_ids[0]
      ipv4_cidr_block      = cidrsubnet(local.vpc_cidr, 8, 100)
    }
  }

  create_network_acl = true
  create_nat_gateway = true

  routes = {
    igw = { destination_ipv4_cidr_block = "0.0.0.0/0", gateway_id = module.vpc.igw_id }
  }
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source = "../../"

  name = local.name
  cidr = local.vpc_cidr

  enable_ipv6 = true
  create_igw  = true

  tags = local.tags
}

# The address the first subnet's NAT gateway is built on. Allocated here rather than by
# the sub-module, which is the point of `nat_gateway_allocation_id`
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(local.tags, { Name = "${local.name}-external-eip" })
}

# Attached to the VPC so that the first subnet's route table has something to propagate
# routes from. A gateway on its own carries no charge, a VPN connection does
resource "aws_vpn_gateway" "this" {
  vpc_id = module.vpc.vpc_id

  tags = merge(local.tags, { Name = local.name })
}

# Joined by the second subnet. Deliberately does not list the subnet in `subnet_ids`,
# because the association resource and this argument overwrite each other
resource "aws_network_acl" "this" {
  vpc_id = module.vpc.vpc_id

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = merge(local.tags, { Name = local.name })
}
