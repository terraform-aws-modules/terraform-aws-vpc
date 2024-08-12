################################################################################
# TGW Subnets
################################################################################

locals {
  len_tgw_subnets         = max(length(var.tgw_subnets), length(var.private_subnet_ipv6_prefixes))
  create_tgw_subnets = local.create_vpc && local.len_tgw_subnets > 0

  # support variables for transit_gateway_routes
  subnets_tgw_routed = keys(var.transit_gateway_routes)
}

resource "aws_subnet" "tgw" {
  count = local.create_tgw_subnets ? local.len_tgw_subnets : 0

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

  #substr(var.input_string, local.string_length - 1, 1)

  tags = merge(
    {
      Name = try(
        var.tgw_subnet_names[count.index],
        format("${var.name_prefix}%s-sub-${var.tgw_subnet_suffix}", substr(element(var.azs, count.index),length(element(var.azs, count.index)) - 1 , 1)
        )
      )
    },
    var.tags,
    var.tgw_subnet_tags,
    lookup(var.tgw_subnet_tags_per_az, element(var.azs, count.index), {})
  )
}

# There are as many routing tables as the number of NAT gateways
resource "aws_route_table" "tgw" {
  count = local.create_tgw_subnets && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = var.single_nat_gateway ? "${var.name_prefix}-${var.tgw_subnet_suffix}" : format(
        "${var.name_prefix}%s-rtb-${var.tgw_subnet_suffix}",
        substr(element(var.azs, count.index), length(element(var.azs, count.index)) - 1, 1)
      )
    },
    var.tags,
    var.tgw_route_table_tags,
  )
}

resource "aws_route_table_association" "tgw" {
  count = local.create_tgw_subnets ? local.len_tgw_subnets : 0

  subnet_id = element(aws_subnet.tgw[*].id, count.index)
  route_table_id = element(
    aws_route_table.tgw[*].id,
      var.single_nat_gateway ? 0 : count.index,
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
    { "Name" = "${var.name_prefix}-nacl-${var.tgw_subnet_suffix}" },
    var.tags,
    var.tgw_acl_tags,
  )
}

resource "aws_network_acl_rule" "tgw_inbound" {
  count = local.tgw_network_acl ? length(var.tgw_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

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
    { Name = "${var.name_prefix}-tgw-att" }
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

# Route: IPv4 routes from public subnets to the Transit Gateway (if configured in var.transit_gateway_routes)
resource "aws_route" "public_to_tgw" {
  count = (local.create_public_subnets && contains(local.subnets_tgw_routed, "public")) ? (var.enable_nat_gateway ? length(var.azs) : 1) : 0

  destination_cidr_block     = can(regex("^pl-", var.transit_gateway_routes["public"])) ? null : var.transit_gateway_routes["public"]
  destination_prefix_list_id = can(regex("^pl-", var.transit_gateway_routes["public"])) ? var.transit_gateway_routes["public"] : null

  transit_gateway_id = var.transit_gateway_id
  route_table_id     = element(aws_route_table.public[*].id, count.index)

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw]
}

# Route: IPv4 routes from private subnets to the Transit Gateway (if configured in var.transit_gateway_routes)
resource "aws_route" "private_to_tgw" {
  count = (local.create_private_subnets && contains(local.subnets_tgw_routed, "private")) ? length(var.azs) : 0

  destination_cidr_block     = can(regex("^pl-", var.transit_gateway_routes["private"])) ? null : var.transit_gateway_routes["private"]
  destination_prefix_list_id = can(regex("^pl-", var.transit_gateway_routes["private"])) ? var.transit_gateway_routes["private"] : null

  transit_gateway_id = var.transit_gateway_id
  route_table_id     = element(aws_route_table.private[*].id, count.index)

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw]
}

# Route: IPv4 routes from intra subnets to the Transit Gateway (if configured in var.transit_gateway_routes)
resource "aws_route" "intra_to_tgw" {
  count = (local.create_intra_subnets && contains(local.subnets_tgw_routed, "intra")) ? length(var.azs) : 0

  destination_cidr_block     = can(regex("^pl-", var.transit_gateway_routes["intra"])) ? null : var.transit_gateway_routes["intra"]
  destination_prefix_list_id = can(regex("^pl-", var.transit_gateway_routes["intra"])) ? var.transit_gateway_routes["intra"] : null

  transit_gateway_id = var.transit_gateway_id
  route_table_id     = element(aws_route_table.intra[*].id, count.index)

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw]
}

# Route: IPv4 routes from public subnets to the Transit Gateway (if configured in var.transit_gateway_routes)
resource "aws_route" "database_to_tgw" {
  count = (local.create_database_subnets && contains(local.subnets_tgw_routed, "database")) ? length(var.azs) : 0

  destination_cidr_block     = can(regex("^pl-", var.transit_gateway_routes["database"])) ? null : var.transit_gateway_routes["database"]
  destination_prefix_list_id = can(regex("^pl-", var.transit_gateway_routes["database"])) ? var.transit_gateway_routes["database"] : null

  transit_gateway_id = var.transit_gateway_id
  route_table_id     = element(aws_route_table.database[*].id, count.index)

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw]
}
