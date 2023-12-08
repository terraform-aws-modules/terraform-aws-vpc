locals {
  create_firewall = var.create_firewall && local.create_vpc
}
resource "aws_subnet" "firewall" {
  count = local.create_firewall ? local.nat_gateway_count : 0

  assign_ipv6_address_on_creation                = var.enable_ipv6 && var.firewall_subnet_ipv6_native ? true : var.firewall_subnet_assign_ipv6_address_on_creation
  availability_zone                              = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id                           = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block                                     = var.firewall_subnet_ipv6_native ? null : element(concat(var.firewall_subnets, [""]), count.index)
  enable_dns64                                   = var.enable_ipv6 && var.firewall_subnet_enable_dns64
  enable_resource_name_dns_aaaa_record_on_launch = var.enable_ipv6 && var.firewall_subnet_enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = !var.firewall_subnet_ipv6_native && var.firewall_subnet_enable_resource_name_dns_a_record_on_launch
  ipv6_cidr_block                                = var.enable_ipv6 && length(var.firewall_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, var.firewall_subnet_ipv6_prefixes[count.index]) : null
  ipv6_native                                    = var.enable_ipv6 && var.firewall_subnet_ipv6_native
  private_dns_hostname_type_on_launch            = var.firewall_subnet_private_dns_hostname_type_on_launch
  vpc_id                                         = local.vpc_id

  tags = merge(
    {
      Name = try(
        var.firewall_subnet_names[count.index],
        format("${var.name}-${var.firewall_subnet_suffix}-%s", element(var.azs, count.index), )
      )
      Firewall = "true"
    },
    var.tags,
    var.firewall_subnet_tags,
  )
}

resource "aws_route_table" "firewall" {
  count = local.create_firewall ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = var.single_nat_gateway ? "${var.name}-${var.firewall_subnet_suffix}" : format(
        "${var.name}-${var.firewall_subnet_suffix}-%s",
        element(var.azs, count.index),
      )
    },
    var.tags,
    var.firewall_route_table_tags,
  )
}

resource "aws_route_table_association" "firewall" {
  count = local.create_firewall ? local.nat_gateway_count : 0

  subnet_id = element(aws_subnet.firewall[*].id, count.index)
  route_table_id = element(
    aws_route_table.firewall[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_route" "firewall_nat_gateway" {
  count = local.create_firewall && var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.firewall[*].id, count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

// Ugly, but I did not found a way to do it better
locals {
  firewall_endpoint = [for v in aws_networkfirewall_firewall.this[0].firewall_status[0].sync_states[*].attachment : v[0].endpoint_id]
  firewall_subnet   = [for v in aws_networkfirewall_firewall.this[0].firewall_status[0].sync_states[*].attachment : v[0].subnet_id]
  firewall_subnet_2 = [for v in local.firewall_subnet : [for x in aws_subnet.firewall : x if x.id == v][0]]
  private_subnet    = [for v in local.firewall_subnet_2 : [for x in aws_subnet.private : x if x.availability_zone == v.availability_zone][0]]
  association       = [for v in local.private_subnet : [for x in aws_route_table_association.private : x if x.subnet_id == v.id][0]]
  private_route     = [for v in local.association : [for x in aws_route_table.private : x if x.id == v.route_table_id][0]]
}

resource "aws_route" "private_firewall" {
  count                  = local.create_firewall ? local.nat_gateway_count : 0
  route_table_id         = local.private_route[count.index].id
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  vpc_endpoint_id        = local.firewall_endpoint[count.index]
}

resource "aws_networkfirewall_firewall" "this" {
  count = local.create_firewall ? 1 : 0

  description = "Firewall for ${var.name}"

  firewall_policy_arn               = var.firewall_policy_arn
  firewall_policy_change_protection = false
  subnet_change_protection          = false
  name                              = var.name

  dynamic "subnet_mapping" {
    for_each = aws_subnet.firewall

    content {
      ip_address_type = var.enable_ipv6 ? "DUALSTACK" : "IPV4"
      subnet_id       = subnet_mapping.value.id
    }
  }

  vpc_id = aws_vpc.this[0].id

  tags = var.tags
}
