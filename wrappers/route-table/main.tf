module "wrapper" {
  source = "../../modules/route-table"

  for_each = var.items

  create                           = try(each.value.create, var.defaults.create, true)
  create_gateway_association       = try(each.value.create_gateway_association, var.defaults.create_gateway_association, false)
  gateway_id                       = try(each.value.gateway_id, var.defaults.gateway_id, null)
  name                             = try(each.value.name, var.defaults.name, "")
  region                           = try(each.value.region, var.defaults.region, null)
  route_table_association_timeouts = try(each.value.route_table_association_timeouts, var.defaults.route_table_association_timeouts, null)
  route_table_tags                 = try(each.value.route_table_tags, var.defaults.route_table_tags, {})
  route_timeouts                   = try(each.value.route_timeouts, var.defaults.route_timeouts, null)
  routes                           = try(each.value.routes, var.defaults.routes, {})
  tags                             = try(each.value.tags, var.defaults.tags, {})
  timeouts                         = try(each.value.timeouts, var.defaults.timeouts, null)
  vpc_id                           = try(each.value.vpc_id, var.defaults.vpc_id, null)
}
