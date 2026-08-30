################################################################################
# Route Table
################################################################################

resource "aws_route_table" "this" {
  count = var.create ? 1 : 0

  region = var.region

  vpc_id = var.vpc_id

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(
    var.tags,
    { for k, v in { Name = var.name } : k => v if v != "" },
    var.route_table_tags,
  )
}

################################################################################
# Routes
################################################################################

resource "aws_route" "this" {
  for_each = { for k, v in var.routes : k => v if var.create }

  region = var.region

  route_table_id = aws_route_table.this[0].id

  destination_cidr_block      = each.value.destination_ipv4_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  destination_prefix_list_id  = each.value.destination_prefix_list_id

  # One of the following target arguments must be supplied:
  carrier_gateway_id        = each.value.carrier_gateway_id
  core_network_arn          = each.value.core_network_arn
  egress_only_gateway_id    = each.value.egress_only_gateway_id
  gateway_id                = each.value.gateway_id
  local_gateway_id          = each.value.local_gateway_id
  nat_gateway_id            = each.value.nat_gateway_id
  odb_network_arn           = each.value.odb_network_arn
  network_interface_id      = each.value.network_interface_id
  transit_gateway_id        = each.value.transit_gateway_id
  vpc_endpoint_id           = each.value.vpc_endpoint_id
  vpc_peering_connection_id = each.value.vpc_peering_connection_id

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : var.route_timeouts != null ? [var.route_timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

################################################################################
# Gateway Association
################################################################################

# Only when a gateway is given. A route table with no gateway is a plain route table,
# which callers share across subnets by passing its ID to the subnet sub-module.
#
# A gateway route table must be dedicated to the gateway and associated with no subnet:
# https://docs.aws.amazon.com/vpc/latest/userguide/igw-ingress-routing.html
resource "aws_route_table_association" "this" {
  count = var.create && var.create_gateway_association ? 1 : 0

  region = var.region

  gateway_id     = var.gateway_id
  route_table_id = aws_route_table.this[0].id

  lifecycle {
    precondition {
      condition     = var.gateway_id != null
      error_message = "`gateway_id` is required when `create_gateway_association` is `true`."
    }
  }

  dynamic "timeouts" {
    for_each = var.route_table_association_timeouts != null ? [var.route_table_association_timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
