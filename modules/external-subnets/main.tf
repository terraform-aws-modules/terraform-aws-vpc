locals {

  subnets = {
    for key, value in var.external_subnets : key => value.subnets
  }

  list = flatten([
    for subnet_name, subnet_value in local.subnets : [
      for subnet_az, subnet_cidr in subnet_value : {
        subnet_name = subnet_name
        subnet_az   = subnet_az
        subnet_cidr = subnet_cidr
  }]])

  route_list = (var.single_nat_external) ? {
    for entry in local.list : entry.subnet_name => entry.subnet_az... if entry.subnet_az == "eu-central-1a"
    } : {
    for entry in local.list : "${entry.subnet_name}-${entry.subnet_az}" => entry.subnet_az...
  }

  subnet_list = {
    for entry in local.list : "${entry.subnet_name}-${entry.subnet_az}" => entry
  }
}


################################################################################
# Route(s)
################################################################################
resource "aws_route_table" "external_subnets" {
  for_each = var.create ? local.route_list : {}

  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, each.key)
    },
    var.tags
  )
}


################################################################################
# Default route(s)
# There are as many routing tables as the number of NAT gateways
################################################################################
data "aws_nat_gateway" "external_subnets" {
  for_each = var.create && length(aws_route_table.external_subnets) > 0 ? {
    for k, v in local.route_list : k => v if k != "shared"
  } : {}

  tags = merge(
    {
      Name = format("%s-${each.value[0]}", var.name)
    },
    var.tags
  )
}

resource "aws_route" "external_subnets" {
  for_each = var.create && length(aws_route_table.external_subnets) > 0 ? {
    for k, v in local.route_list : k => v if k != "shared"
  } : {}

  route_table_id         = aws_route_table.external_subnets[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = data.aws_nat_gateway.external_subnets[each.key].id

  timeouts {
    create = "5m"
  }
}


################################################################################
# Route table association with subnets
################################################################################
resource "aws_route_table_association" "external_subnets" {
  for_each = var.create && length(aws_subnet.external_subnets) > 0 ? local.subnet_list : {}

  subnet_id      = aws_subnet.external_subnets[each.key].id
  route_table_id = (var.single_nat_external) ? aws_route_table.external_subnets[each.value.subnet_name].id : aws_route_table.external_subnets[each.key].id

  depends_on = [
    aws_subnet.external_subnets,
    aws_route_table.external_subnets
  ]
}


################################################################################
# Subnets
################################################################################
resource "aws_subnet" "external_subnets" {
  for_each = var.create ? local.subnet_list : {}

  vpc_id               = var.vpc_id
  cidr_block           = each.value.subnet_cidr
  availability_zone    = length(regexall("^[a-z]{2}-", each.value.subnet_az)) > 0 ? each.value.subnet_az : null
  availability_zone_id = length(regexall("^[a-z]{2}-", each.value.subnet_az)) == 0 ? each.value.subnet_az : null

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, each.key)
    },
    var.tags
  )
}

################################################################################
# Route table association with VGW
################################################################################
resource "aws_vpn_gateway_route_propagation" "external_subnets" {
  for_each = var.create && var.propagate_external_route_tables_vgw ? local.route_list : {}

  route_table_id = aws_route_table.external_subnets[each.key].id
  vpn_gateway_id = var.vgw_id
}
