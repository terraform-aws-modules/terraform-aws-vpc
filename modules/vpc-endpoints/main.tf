################################################################################
# Endpoint(s)
################################################################################

locals {
  endpoints = { for k, v in var.endpoints : k => v if var.create && v.create }

  security_group_ids = var.create && var.create_security_group ? concat(var.security_group_ids, [aws_security_group.this[0].id]) : var.security_group_ids
}

data "aws_vpc_endpoint_service" "this" {
  # This data source is sort of useless without the following
  # https://github.com/hashicorp/terraform-provider-aws/issues/42462
  # It only works in the same region as the provider, regardless of the arguments provided (service, service_name, service_regions, etc.)
  for_each = { for k, v in local.endpoints : k => v if var.region == null }

  service         = each.value.service
  service_name    = each.value.service_name
  service_regions = each.value.service_region != null ? [each.value.service_region] : null

  filter {
    name   = "service-type"
    values = [each.value.service_type]
  }
}

resource "aws_vpc_endpoint" "this" {
  for_each = local.endpoints

  region = var.region

  vpc_id            = var.vpc_id
  service_name      = each.value.service_endpoint != null ? each.value.service_endpoint : data.aws_vpc_endpoint_service.this[each.key].service_name
  service_region    = each.value.service_region
  vpc_endpoint_type = each.value.service_type
  auto_accept       = each.value.auto_accept

  security_group_ids  = each.value.service_type == "Interface" ? length(distinct(concat(local.security_group_ids, each.value.security_group_ids))) > 0 ? distinct(concat(local.security_group_ids, each.value.security_group_ids)) : null : null
  subnet_ids          = each.value.service_type == "Interface" ? distinct(concat(var.subnet_ids, each.value.subnet_ids)) : null
  route_table_ids     = each.value.service_type == "Gateway" ? each.value.route_table_ids : null
  policy              = each.value.policy
  private_dns_enabled = each.value.service_type == "Interface" ? each.value.private_dns_enabled : null
  ip_address_type     = each.value.ip_address_type

  dynamic "dns_options" {
    for_each = each.value.dns_options != null ? [each.value.dns_options] : []

    content {
      dns_record_ip_type                             = dns_options.value.dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = dns_options.value.private_dns_only_for_inbound_resolver_endpoint
    }
  }

  dynamic "subnet_configuration" {
    for_each = each.value.subnet_configurations

    content {
      ipv4      = subnet_configuration.value.ipv4
      ipv6      = subnet_configuration.value.ipv6
      subnet_id = subnet_configuration.value.subnet_id
    }
  }

  tags = merge(
    var.tags,
    { "Name" = replace(each.key, ".", "-") },
    each.value.tags,
  )

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  count = var.create && var.create_security_group ? 1 : 0

  region = var.region

  name        = var.security_group_name
  name_prefix = var.security_group_name_prefix
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = try(coalesce(var.security_group_name, var.security_group_name_prefix), "") },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in var.security_group_rules : k => v if var.create && var.create_security_group }

  region = var.region

  # Required
  security_group_id = aws_security_group.this[0].id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  # Optional
  description              = each.value.description
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  self                     = each.value.self
  source_security_group_id = each.value.source_security_group_id
}
