################################################################################
# TGW Subnets
################################################################################

locals {
  len_tgw_subnets    = max(length(var.tgw_subnets), length(var.tgw_subnet_ipv6_prefixes))
  create_tgw_subnets = local.create_vpc && local.len_tgw_subnets > 0

  # support variables for transit_gateway_routes
  subnets_tgw_routed = keys(var.transit_gateway_routes)
}

resource "aws_subnet" "tgw" {
  count = local.create_tgw_subnets ? local.len_tgw_subnets : 0 # TODO: Maybe add condition to have at least as many as AZs

  assign_ipv6_address_on_creation                = var.enable_ipv6 && var.tgw_subnet_ipv6_native ? true : var.tgw_subnet_assign_ipv6_address_on_creation
  availability_zone                              = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id                           = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block                                     = var.tgw_subnet_ipv6_native ? null : element(concat(var.tgw_subnets, [""]), count.index)
  enable_dns64                                   = var.enable_ipv6 && var.tgw_subnet_enable_dns64
  enable_resource_name_dns_aaaa_record_on_launch = var.enable_ipv6 && var.tgw_subnet_enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = !var.tgw_subnet_ipv6_native && var.tgw_subnet_enable_resource_name_dns_a_record_on_launch
  ipv6_cidr_block                                = var.enable_ipv6 && length(var.tgw_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.tgw_subnet_ipv6_prefixes[count.index]) : null
  ipv6_native                                    = var.enable_ipv6 && var.tgw_subnet_ipv6_native
  private_dns_hostname_type_on_launch            = var.tgw_subnet_private_dns_hostname_type_on_launch
  vpc_id                                         = local.vpc_id

  tags = merge(
    {
      Name = try(
        var.tgw_subnet_names[count.index],
        format(
          "%s-%s%s-%s-sub-%s",
          var.name_prefix,
          var.short_aws_region,
          substr(element(var.azs, count.index), -1, 1),                    # Get last letter of az code
          lookup(var.az_name_to_az_id, element(var.azs, count.index), ""), # Lookup az-id based on name
          var.tgw_subnet_suffix
        )
      )
    },
    var.tags,
    var.tgw_subnet_tags,
    lookup(var.tgw_subnet_tags_per_az, element(var.azs, count.index), {})
  )
}

locals {
  num_tgw_route_tables = var.create_multiple_tgw_route_tables ? local.len_tgw_subnets : 1
}

resource "aws_route_table" "tgw" {
  count = local.create_tgw_subnets ? local.num_tgw_route_tables : 0

  vpc_id = local.vpc_id
  tags = merge(
    {
      "Name" = var.create_multiple_tgw_route_tables ? format(
        "%s-%s%s-rtb-%s",
        var.name_prefix,
        var.short_aws_region,
        substr(element(var.azs, count.index), -1, 1),
        var.tgw_subnet_suffix
        ) : format(
        "%s-%s-rtb-%s",
        var.name_prefix,
        var.short_aws_region,
        var.tgw_subnet_suffix
      )
    },
    var.tags,
    var.tgw_route_table_tags
  )
}

resource "aws_route_table_association" "tgw" {
  count = local.create_tgw_subnets ? local.len_tgw_subnets : 0

  subnet_id = element(aws_subnet.tgw[*].id, count.index)
  route_table_id = element(
    aws_route_table.tgw[*].id,
    var.create_multiple_tgw_route_tables ? count.index : 0
  )
}

################################################################################
# TGW Network ACLs
################################################################################

locals {
  tgw_network_acl = local.create_tgw_subnets && var.tgw_dedicated_network_acl
}

resource "aws_network_acl" "tgw" {
  count = local.tgw_network_acl ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.tgw[*].id

  tags = merge(
    {
      "Name" = format("%s-%s-nacl-%s", var.name_prefix, var.short_aws_region, var.tgw_subnet_suffix)
    },
    var.tags,
    var.tgw_acl_tags,
  )
}

resource "aws_network_acl_rule" "tgw_inbound" {
  count = local.tgw_network_acl ? length(var.tgw_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.tgw[0].id # TODO: Fixed

  egress          = false
  rule_number     = var.tgw_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.tgw_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.tgw_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.tgw_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.tgw_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.tgw_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.tgw_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.tgw_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.tgw_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "tgw_outbound" {
  count = local.tgw_network_acl ? length(var.tgw_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.tgw[0].id

  egress          = true
  rule_number     = var.tgw_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.tgw_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.tgw_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.tgw_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.tgw_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.tgw_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.tgw_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.tgw_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.tgw_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

# Transit Gateway VPC attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw" {
  count = var.enable_tgw_attachment ? 1 : 0

  subnet_ids         = aws_subnet.tgw[*].id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = local.vpc_id

  tags = merge(
    { Name = "${var.name_prefix}-${var.short_aws_region}-tgw-att" }
  )
}

resource "aws_route" "tgw_nat_gateway" {
  count = local.create_vpc && var.enable_tgw_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.tgw[*].id, count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw]
}

resource "aws_route" "tgw_dns64_nat_gateway" {
  count = local.create_vpc && var.enable_tgw_nat_gateway && var.enable_ipv6 && var.tgw_subnet_enable_dns64 ? local.nat_gateway_count : 0

  route_table_id              = element(aws_route_table.tgw[*].id, count.index)
  destination_ipv6_cidr_block = "64:ff9b::/96"
  nat_gateway_id              = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw]
}

locals {
  create_public_to_tgw = (local.create_public_subnets && contains(local.subnets_tgw_routed, "public"))
  public_to_tgw_cidr_pairs = local.create_public_to_tgw ? flatten([
    for public_rtb in aws_route_table.public : [
      for cidr in var.transit_gateway_routes["public"]: {
        rtb_id = public_rtb.id
        cidr   = cidr
      }
    ]
  ]) : []
}

resource "aws_route" "public_to_tgw" {
  for_each = local.create_public_to_tgw ? {for i, v in local.public_to_tgw_cidr_pairs : "${i}-${v.cidr}" => v} : {}

  destination_cidr_block     = can(regex("^pl-", each.value.cidr)) ? null : each.value.cidr
  destination_prefix_list_id = can(regex("^pl-", each.value.cidr)) ? each.value.cidr : null

  transit_gateway_id = var.transit_gateway_id
  route_table_id     = each.value.rtb_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw]
}

# Route: IPv4 routes from private subnets to the Transit Gateway (if configured in var.transit_gateway_routes)
locals {
  create_private_to_tgw = (local.create_private_subnets && contains(local.subnets_tgw_routed, "private"))
  private_to_tgw_cidr_pairs = local.create_private_to_tgw ? flatten([
    for private_rtb in aws_route_table.private : [
      for cidr in var.transit_gateway_routes["private"]: {
        rtb_id = private_rtb.id
        cidr   = cidr
      }
    ]
  ]) : []
}

resource "aws_route" "private_to_tgw" {
  for_each = local.create_private_to_tgw ? {for i, v in local.private_to_tgw_cidr_pairs : "${i}-${v.cidr}" => v} : {}

  destination_cidr_block     = can(regex("^pl-", each.value.cidr)) ? null : each.value.cidr
  destination_prefix_list_id = can(regex("^pl-", each.value.cidr)) ? each.value.cidr : null

  transit_gateway_id = var.transit_gateway_id
  route_table_id     = each.value.rtb_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw]
}
