module "wrapper" {
  source = "../../modules/subnets"

  for_each = var.items

  assign_ipv6_address_on_creation                = try(each.value.assign_ipv6_address_on_creation, var.defaults.assign_ipv6_address_on_creation, null)
  create                                         = try(each.value.create, var.defaults.create, true)
  create_eip                                     = try(each.value.create_eip, var.defaults.create_eip, true)
  create_nat_gateway                             = try(each.value.create_nat_gateway, var.defaults.create_nat_gateway, false)
  create_network_acl                             = try(each.value.create_network_acl, var.defaults.create_network_acl, false)
  create_route_table                             = try(each.value.create_route_table, var.defaults.create_route_table, true)
  enable_dns64                                   = try(each.value.enable_dns64, var.defaults.enable_dns64, null)
  enable_resource_name_dns_a_record_on_launch    = try(each.value.enable_resource_name_dns_a_record_on_launch, var.defaults.enable_resource_name_dns_a_record_on_launch, null)
  enable_resource_name_dns_aaaa_record_on_launch = try(each.value.enable_resource_name_dns_aaaa_record_on_launch, var.defaults.enable_resource_name_dns_aaaa_record_on_launch, null)
  map_public_ip_on_launch                        = try(each.value.map_public_ip_on_launch, var.defaults.map_public_ip_on_launch, null)
  name                                           = try(each.value.name, var.defaults.name, "")
  nat_gateway_connectivity_type                  = try(each.value.nat_gateway_connectivity_type, var.defaults.nat_gateway_connectivity_type, null)
  nat_gateway_tags                               = try(each.value.nat_gateway_tags, var.defaults.nat_gateway_tags, {})
  network_acl_id                                 = try(each.value.network_acl_id, var.defaults.network_acl_id, null)
  network_acl_rules                              = try(each.value.network_acl_rules, var.defaults.network_acl_rules, {})
  network_acl_tags                               = try(each.value.network_acl_tags, var.defaults.network_acl_tags, {})
  private_dns_hostname_type_on_launch            = try(each.value.private_dns_hostname_type_on_launch, var.defaults.private_dns_hostname_type_on_launch, null)
  region                                         = try(each.value.region, var.defaults.region, null)
  resource_share_arn                             = try(each.value.resource_share_arn, var.defaults.resource_share_arn, null)
  route_table_id                                 = try(each.value.route_table_id, var.defaults.route_table_id, null)
  route_table_tags                               = try(each.value.route_table_tags, var.defaults.route_table_tags, {})
  routes                                         = try(each.value.routes, var.defaults.routes, {})
  share_subnet                                   = try(each.value.share_subnet, var.defaults.share_subnet, false)
  subnets                                        = try(each.value.subnets, var.defaults.subnets, {})
  tags                                           = try(each.value.tags, var.defaults.tags, {})
  vpc_id                                         = try(each.value.vpc_id, var.defaults.vpc_id, null)
}
