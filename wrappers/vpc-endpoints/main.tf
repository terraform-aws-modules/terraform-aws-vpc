module "wrapper" {
  source = "../../modules/vpc-endpoints"

  for_each = var.items

  create                     = try(each.value.create, var.defaults.create, true)
  create_security_group      = try(each.value.create_security_group, var.defaults.create_security_group, false)
  endpoints                  = try(each.value.endpoints, var.defaults.endpoints, {})
  region                     = try(each.value.region, var.defaults.region, null)
  security_group_description = try(each.value.security_group_description, var.defaults.security_group_description, null)
  security_group_ids         = try(each.value.security_group_ids, var.defaults.security_group_ids, [])
  security_group_name        = try(each.value.security_group_name, var.defaults.security_group_name, null)
  security_group_name_prefix = try(each.value.security_group_name_prefix, var.defaults.security_group_name_prefix, null)
  security_group_rules       = try(each.value.security_group_rules, var.defaults.security_group_rules, {})
  security_group_tags        = try(each.value.security_group_tags, var.defaults.security_group_tags, {})
  subnet_ids                 = try(each.value.subnet_ids, var.defaults.subnet_ids, [])
  tags                       = try(each.value.tags, var.defaults.tags, {})
  timeouts                   = try(each.value.timeouts, var.defaults.timeouts, {})
  vpc_id                     = try(each.value.vpc_id, var.defaults.vpc_id, null)
}
