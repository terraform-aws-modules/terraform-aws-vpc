locals {
  subnets = { for k, v in var.subnets : k => v if var.create }

  # A subnet that declares its own routes needs its own route table. If none of them do,
  # every subnet in the group routes identically and one shared table serves them all.
  #
  # This is read from where the routes are declared, not from their values, so it is known
  # at plan time. Route targets are almost always computed, and deciding resource counts
  # from them fails with `Invalid count argument`
  any_subnet_has_routes = anytrue([for k, v in local.subnets : v.routes != null])
  create_shared_table   = var.create && var.create_route_table && !local.any_subnet_has_routes
}

################################################################################
# Shared Route Table
#
# Created only when every subnet in the group routes identically
################################################################################

module "route_table" {
  source = "../route-table"

  create = local.create_shared_table
  region = var.region

  name   = var.name
  vpc_id = var.vpc_id

  routes = var.routes

  route_table_tags = var.route_table_tags
  tags             = var.tags
}

################################################################################
# Subnets
################################################################################

module "subnet" {
  source = "../subnet"

  for_each = local.subnets

  region = var.region

  name   = coalesce(each.value.name, "${var.name}-${each.key}")
  vpc_id = var.vpc_id

  availability_zone    = each.value.availability_zone
  availability_zone_id = each.value.availability_zone_id
  ipv4_cidr_block      = each.value.ipv4_cidr_block
  ipv6_cidr_block      = each.value.ipv6_cidr_block
  ipv6_native          = each.value.ipv6_native

  assign_ipv6_address_on_creation                = var.assign_ipv6_address_on_creation
  enable_dns64                                   = var.enable_dns64
  enable_resource_name_dns_a_record_on_launch    = var.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = var.enable_resource_name_dns_aaaa_record_on_launch
  map_public_ip_on_launch                        = var.map_public_ip_on_launch
  private_dns_hostname_type_on_launch            = var.private_dns_hostname_type_on_launch

  # Own a table when this subnet's routes differ from the group's, otherwise join the
  # shared one. `route_table_id` is also how a caller brings a table of their own
  create_route_table = var.create_route_table && local.any_subnet_has_routes
  route_table_id     = local.create_shared_table ? module.route_table.id : var.route_table_id
  routes             = coalesce(each.value.routes, var.routes)

  create_nat_gateway            = coalesce(each.value.create_nat_gateway, var.create_nat_gateway)
  create_eip                    = coalesce(each.value.create_eip, var.create_eip)
  eip_network_border_group      = each.value.eip_network_border_group
  nat_gateway_allocation_id     = each.value.nat_gateway_allocation_id
  nat_gateway_connectivity_type = each.value.nat_gateway_connectivity_type != null ? each.value.nat_gateway_connectivity_type : var.nat_gateway_connectivity_type

  share_subnet       = coalesce(each.value.share_subnet, var.share_subnet)
  resource_share_arn = each.value.resource_share_arn != null ? each.value.resource_share_arn : var.resource_share_arn

  create_network_acl_association = var.create_network_acl
  network_acl_id                 = var.create_network_acl ? aws_network_acl.this[0].id : var.network_acl_id

  subnet_tags      = each.value.tags
  route_table_tags = merge(var.route_table_tags, each.value.route_table_tags)
  nat_gateway_tags = var.nat_gateway_tags
  tags             = var.tags
}

################################################################################
# Network ACL
#
# One network ACL for the group. A network ACL is associated with many subnets, so it has
# no single subnet to own it, which is the reason this layer exists at all
################################################################################

resource "aws_network_acl" "this" {
  count = var.create && var.create_network_acl ? 1 : 0

  region = var.region

  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    { for k, v in { Name = var.name } : k => v if v != "" },
    var.network_acl_tags,
  )
}

resource "aws_network_acl_rule" "this" {
  for_each = { for k, v in var.network_acl_rules : k => v if var.create && var.create_network_acl }

  region = var.region

  network_acl_id = aws_network_acl.this[0].id

  egress          = each.value.egress
  rule_number     = each.value.rule_number
  rule_action     = each.value.rule_action
  protocol        = each.value.protocol
  from_port       = each.value.from_port
  to_port         = each.value.to_port
  icmp_code       = each.value.icmp_code
  icmp_type       = each.value.icmp_type
  cidr_block      = each.value.cidr_block
  ipv6_cidr_block = each.value.ipv6_cidr_block
}
