module "wrapper" {
  source = "../"

  for_each = var.items

  amazon_side_asn                        = try(each.value.amazon_side_asn, var.defaults.amazon_side_asn, "64512")
  azs                                    = try(each.value.azs, var.defaults.azs, [])
  cidr                                   = try(each.value.cidr, var.defaults.cidr, "10.0.0.0/16")
  create_database_internet_gateway_route = try(each.value.create_database_internet_gateway_route, var.defaults.create_database_internet_gateway_route, false)
  create_database_nat_gateway_route      = try(each.value.create_database_nat_gateway_route, var.defaults.create_database_nat_gateway_route, false)
  create_database_subnet_group           = try(each.value.create_database_subnet_group, var.defaults.create_database_subnet_group, true)
  create_database_subnet_route_table     = try(each.value.create_database_subnet_route_table, var.defaults.create_database_subnet_route_table, false)
  create_egress_only_igw                 = try(each.value.create_egress_only_igw, var.defaults.create_egress_only_igw, true)
  create_elasticache_subnet_group        = try(each.value.create_elasticache_subnet_group, var.defaults.create_elasticache_subnet_group, true)
  create_elasticache_subnet_route_table  = try(each.value.create_elasticache_subnet_route_table, var.defaults.create_elasticache_subnet_route_table, false)
  create_flow_log_cloudwatch_iam_role    = try(each.value.create_flow_log_cloudwatch_iam_role, var.defaults.create_flow_log_cloudwatch_iam_role, false)
  create_flow_log_cloudwatch_log_group   = try(each.value.create_flow_log_cloudwatch_log_group, var.defaults.create_flow_log_cloudwatch_log_group, false)
  create_igw                             = try(each.value.create_igw, var.defaults.create_igw, true)
  create_multiple_intra_route_tables     = try(each.value.create_multiple_intra_route_tables, var.defaults.create_multiple_intra_route_tables, false)
  create_multiple_public_route_tables    = try(each.value.create_multiple_public_route_tables, var.defaults.create_multiple_public_route_tables, false)
  create_private_nat_gateway_route       = try(each.value.create_private_nat_gateway_route, var.defaults.create_private_nat_gateway_route, true)
  create_redshift_subnet_group           = try(each.value.create_redshift_subnet_group, var.defaults.create_redshift_subnet_group, true)
  create_redshift_subnet_route_table     = try(each.value.create_redshift_subnet_route_table, var.defaults.create_redshift_subnet_route_table, false)
  create_vpc                             = try(each.value.create_vpc, var.defaults.create_vpc, true)
  customer_gateway_tags                  = try(each.value.customer_gateway_tags, var.defaults.customer_gateway_tags, {})
  customer_gateways                      = try(each.value.customer_gateways, var.defaults.customer_gateways, {})
  customer_owned_ipv4_pool               = try(each.value.customer_owned_ipv4_pool, var.defaults.customer_owned_ipv4_pool, null)
  database_acl_tags                      = try(each.value.database_acl_tags, var.defaults.database_acl_tags, {})
  database_dedicated_network_acl         = try(each.value.database_dedicated_network_acl, var.defaults.database_dedicated_network_acl, false)
  database_inbound_acl_rules = try(each.value.database_inbound_acl_rules, var.defaults.database_inbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  database_outbound_acl_rules = try(each.value.database_outbound_acl_rules, var.defaults.database_outbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  database_route_table_tags                                      = try(each.value.database_route_table_tags, var.defaults.database_route_table_tags, {})
  database_subnet_assign_ipv6_address_on_creation                = try(each.value.database_subnet_assign_ipv6_address_on_creation, var.defaults.database_subnet_assign_ipv6_address_on_creation, false)
  database_subnet_enable_dns64                                   = try(each.value.database_subnet_enable_dns64, var.defaults.database_subnet_enable_dns64, true)
  database_subnet_enable_resource_name_dns_a_record_on_launch    = try(each.value.database_subnet_enable_resource_name_dns_a_record_on_launch, var.defaults.database_subnet_enable_resource_name_dns_a_record_on_launch, false)
  database_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(each.value.database_subnet_enable_resource_name_dns_aaaa_record_on_launch, var.defaults.database_subnet_enable_resource_name_dns_aaaa_record_on_launch, true)
  database_subnet_group_name                                     = try(each.value.database_subnet_group_name, var.defaults.database_subnet_group_name, null)
  database_subnet_group_tags                                     = try(each.value.database_subnet_group_tags, var.defaults.database_subnet_group_tags, {})
  database_subnet_ipv6_native                                    = try(each.value.database_subnet_ipv6_native, var.defaults.database_subnet_ipv6_native, false)
  database_subnet_ipv6_prefixes                                  = try(each.value.database_subnet_ipv6_prefixes, var.defaults.database_subnet_ipv6_prefixes, [])
  database_subnet_names                                          = try(each.value.database_subnet_names, var.defaults.database_subnet_names, [])
  database_subnet_private_dns_hostname_type_on_launch            = try(each.value.database_subnet_private_dns_hostname_type_on_launch, var.defaults.database_subnet_private_dns_hostname_type_on_launch, null)
  database_subnet_suffix                                         = try(each.value.database_subnet_suffix, var.defaults.database_subnet_suffix, "db")
  database_subnet_tags                                           = try(each.value.database_subnet_tags, var.defaults.database_subnet_tags, {})
  database_subnets                                               = try(each.value.database_subnets, var.defaults.database_subnets, [])
  default_network_acl_egress = try(each.value.default_network_acl_egress, var.defaults.default_network_acl_egress, [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ])
  default_network_acl_ingress = try(each.value.default_network_acl_ingress, var.defaults.default_network_acl_ingress, [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ])
  default_network_acl_name                       = try(each.value.default_network_acl_name, var.defaults.default_network_acl_name, null)
  default_network_acl_tags                       = try(each.value.default_network_acl_tags, var.defaults.default_network_acl_tags, {})
  default_route_table_name                       = try(each.value.default_route_table_name, var.defaults.default_route_table_name, null)
  default_route_table_propagating_vgws           = try(each.value.default_route_table_propagating_vgws, var.defaults.default_route_table_propagating_vgws, [])
  default_route_table_routes                     = try(each.value.default_route_table_routes, var.defaults.default_route_table_routes, [])
  default_route_table_tags                       = try(each.value.default_route_table_tags, var.defaults.default_route_table_tags, {})
  default_security_group_egress                  = try(each.value.default_security_group_egress, var.defaults.default_security_group_egress, [])
  default_security_group_ingress                 = try(each.value.default_security_group_ingress, var.defaults.default_security_group_ingress, [])
  default_security_group_name                    = try(each.value.default_security_group_name, var.defaults.default_security_group_name, null)
  default_security_group_tags                    = try(each.value.default_security_group_tags, var.defaults.default_security_group_tags, {})
  default_vpc_enable_dns_hostnames               = try(each.value.default_vpc_enable_dns_hostnames, var.defaults.default_vpc_enable_dns_hostnames, true)
  default_vpc_enable_dns_support                 = try(each.value.default_vpc_enable_dns_support, var.defaults.default_vpc_enable_dns_support, true)
  default_vpc_name                               = try(each.value.default_vpc_name, var.defaults.default_vpc_name, null)
  default_vpc_tags                               = try(each.value.default_vpc_tags, var.defaults.default_vpc_tags, {})
  dhcp_options_domain_name                       = try(each.value.dhcp_options_domain_name, var.defaults.dhcp_options_domain_name, "")
  dhcp_options_domain_name_servers               = try(each.value.dhcp_options_domain_name_servers, var.defaults.dhcp_options_domain_name_servers, ["AmazonProvidedDNS"])
  dhcp_options_ipv6_address_preferred_lease_time = try(each.value.dhcp_options_ipv6_address_preferred_lease_time, var.defaults.dhcp_options_ipv6_address_preferred_lease_time, null)
  dhcp_options_netbios_name_servers              = try(each.value.dhcp_options_netbios_name_servers, var.defaults.dhcp_options_netbios_name_servers, [])
  dhcp_options_netbios_node_type                 = try(each.value.dhcp_options_netbios_node_type, var.defaults.dhcp_options_netbios_node_type, "")
  dhcp_options_ntp_servers                       = try(each.value.dhcp_options_ntp_servers, var.defaults.dhcp_options_ntp_servers, [])
  dhcp_options_tags                              = try(each.value.dhcp_options_tags, var.defaults.dhcp_options_tags, {})
  elasticache_acl_tags                           = try(each.value.elasticache_acl_tags, var.defaults.elasticache_acl_tags, {})
  elasticache_dedicated_network_acl              = try(each.value.elasticache_dedicated_network_acl, var.defaults.elasticache_dedicated_network_acl, false)
  elasticache_inbound_acl_rules = try(each.value.elasticache_inbound_acl_rules, var.defaults.elasticache_inbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  elasticache_outbound_acl_rules = try(each.value.elasticache_outbound_acl_rules, var.defaults.elasticache_outbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  elasticache_route_table_tags                                      = try(each.value.elasticache_route_table_tags, var.defaults.elasticache_route_table_tags, {})
  elasticache_subnet_assign_ipv6_address_on_creation                = try(each.value.elasticache_subnet_assign_ipv6_address_on_creation, var.defaults.elasticache_subnet_assign_ipv6_address_on_creation, false)
  elasticache_subnet_enable_dns64                                   = try(each.value.elasticache_subnet_enable_dns64, var.defaults.elasticache_subnet_enable_dns64, true)
  elasticache_subnet_enable_resource_name_dns_a_record_on_launch    = try(each.value.elasticache_subnet_enable_resource_name_dns_a_record_on_launch, var.defaults.elasticache_subnet_enable_resource_name_dns_a_record_on_launch, false)
  elasticache_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(each.value.elasticache_subnet_enable_resource_name_dns_aaaa_record_on_launch, var.defaults.elasticache_subnet_enable_resource_name_dns_aaaa_record_on_launch, true)
  elasticache_subnet_group_name                                     = try(each.value.elasticache_subnet_group_name, var.defaults.elasticache_subnet_group_name, null)
  elasticache_subnet_group_tags                                     = try(each.value.elasticache_subnet_group_tags, var.defaults.elasticache_subnet_group_tags, {})
  elasticache_subnet_ipv6_native                                    = try(each.value.elasticache_subnet_ipv6_native, var.defaults.elasticache_subnet_ipv6_native, false)
  elasticache_subnet_ipv6_prefixes                                  = try(each.value.elasticache_subnet_ipv6_prefixes, var.defaults.elasticache_subnet_ipv6_prefixes, [])
  elasticache_subnet_names                                          = try(each.value.elasticache_subnet_names, var.defaults.elasticache_subnet_names, [])
  elasticache_subnet_private_dns_hostname_type_on_launch            = try(each.value.elasticache_subnet_private_dns_hostname_type_on_launch, var.defaults.elasticache_subnet_private_dns_hostname_type_on_launch, null)
  elasticache_subnet_suffix                                         = try(each.value.elasticache_subnet_suffix, var.defaults.elasticache_subnet_suffix, "elasticache")
  elasticache_subnet_tags                                           = try(each.value.elasticache_subnet_tags, var.defaults.elasticache_subnet_tags, {})
  elasticache_subnets                                               = try(each.value.elasticache_subnets, var.defaults.elasticache_subnets, [])
  enable_dhcp_options                                               = try(each.value.enable_dhcp_options, var.defaults.enable_dhcp_options, false)
  enable_dns_hostnames                                              = try(each.value.enable_dns_hostnames, var.defaults.enable_dns_hostnames, true)
  enable_dns_support                                                = try(each.value.enable_dns_support, var.defaults.enable_dns_support, true)
  enable_flow_log                                                   = try(each.value.enable_flow_log, var.defaults.enable_flow_log, false)
  enable_ipv6                                                       = try(each.value.enable_ipv6, var.defaults.enable_ipv6, false)
  enable_nat_gateway                                                = try(each.value.enable_nat_gateway, var.defaults.enable_nat_gateway, false)
  enable_network_address_usage_metrics                              = try(each.value.enable_network_address_usage_metrics, var.defaults.enable_network_address_usage_metrics, null)
  enable_public_redshift                                            = try(each.value.enable_public_redshift, var.defaults.enable_public_redshift, false)
  enable_vpn_gateway                                                = try(each.value.enable_vpn_gateway, var.defaults.enable_vpn_gateway, false)
  external_nat_ip_ids                                               = try(each.value.external_nat_ip_ids, var.defaults.external_nat_ip_ids, [])
  external_nat_ips                                                  = try(each.value.external_nat_ips, var.defaults.external_nat_ips, [])
  flow_log_cloudwatch_iam_role_arn                                  = try(each.value.flow_log_cloudwatch_iam_role_arn, var.defaults.flow_log_cloudwatch_iam_role_arn, "")
  flow_log_cloudwatch_iam_role_conditions                           = try(each.value.flow_log_cloudwatch_iam_role_conditions, var.defaults.flow_log_cloudwatch_iam_role_conditions, [])
  flow_log_cloudwatch_log_group_class                               = try(each.value.flow_log_cloudwatch_log_group_class, var.defaults.flow_log_cloudwatch_log_group_class, null)
  flow_log_cloudwatch_log_group_kms_key_id                          = try(each.value.flow_log_cloudwatch_log_group_kms_key_id, var.defaults.flow_log_cloudwatch_log_group_kms_key_id, null)
  flow_log_cloudwatch_log_group_name_prefix                         = try(each.value.flow_log_cloudwatch_log_group_name_prefix, var.defaults.flow_log_cloudwatch_log_group_name_prefix, "/aws/vpc-flow-log/")
  flow_log_cloudwatch_log_group_name_suffix                         = try(each.value.flow_log_cloudwatch_log_group_name_suffix, var.defaults.flow_log_cloudwatch_log_group_name_suffix, "")
  flow_log_cloudwatch_log_group_retention_in_days                   = try(each.value.flow_log_cloudwatch_log_group_retention_in_days, var.defaults.flow_log_cloudwatch_log_group_retention_in_days, null)
  flow_log_cloudwatch_log_group_skip_destroy                        = try(each.value.flow_log_cloudwatch_log_group_skip_destroy, var.defaults.flow_log_cloudwatch_log_group_skip_destroy, false)
  flow_log_deliver_cross_account_role                               = try(each.value.flow_log_deliver_cross_account_role, var.defaults.flow_log_deliver_cross_account_role, null)
  flow_log_destination_arn                                          = try(each.value.flow_log_destination_arn, var.defaults.flow_log_destination_arn, "")
  flow_log_destination_type                                         = try(each.value.flow_log_destination_type, var.defaults.flow_log_destination_type, "cloud-watch-logs")
  flow_log_file_format                                              = try(each.value.flow_log_file_format, var.defaults.flow_log_file_format, null)
  flow_log_hive_compatible_partitions                               = try(each.value.flow_log_hive_compatible_partitions, var.defaults.flow_log_hive_compatible_partitions, false)
  flow_log_log_format                                               = try(each.value.flow_log_log_format, var.defaults.flow_log_log_format, null)
  flow_log_max_aggregation_interval                                 = try(each.value.flow_log_max_aggregation_interval, var.defaults.flow_log_max_aggregation_interval, 600)
  flow_log_per_hour_partition                                       = try(each.value.flow_log_per_hour_partition, var.defaults.flow_log_per_hour_partition, false)
  flow_log_traffic_type                                             = try(each.value.flow_log_traffic_type, var.defaults.flow_log_traffic_type, "ALL")
  igw_tags                                                          = try(each.value.igw_tags, var.defaults.igw_tags, {})
  instance_tenancy                                                  = try(each.value.instance_tenancy, var.defaults.instance_tenancy, "default")
  intra_acl_tags                                                    = try(each.value.intra_acl_tags, var.defaults.intra_acl_tags, {})
  intra_dedicated_network_acl                                       = try(each.value.intra_dedicated_network_acl, var.defaults.intra_dedicated_network_acl, false)
  intra_inbound_acl_rules = try(each.value.intra_inbound_acl_rules, var.defaults.intra_inbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  intra_outbound_acl_rules = try(each.value.intra_outbound_acl_rules, var.defaults.intra_outbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  intra_route_table_tags                                      = try(each.value.intra_route_table_tags, var.defaults.intra_route_table_tags, {})
  intra_subnet_assign_ipv6_address_on_creation                = try(each.value.intra_subnet_assign_ipv6_address_on_creation, var.defaults.intra_subnet_assign_ipv6_address_on_creation, false)
  intra_subnet_enable_dns64                                   = try(each.value.intra_subnet_enable_dns64, var.defaults.intra_subnet_enable_dns64, true)
  intra_subnet_enable_resource_name_dns_a_record_on_launch    = try(each.value.intra_subnet_enable_resource_name_dns_a_record_on_launch, var.defaults.intra_subnet_enable_resource_name_dns_a_record_on_launch, false)
  intra_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(each.value.intra_subnet_enable_resource_name_dns_aaaa_record_on_launch, var.defaults.intra_subnet_enable_resource_name_dns_aaaa_record_on_launch, true)
  intra_subnet_ipv6_native                                    = try(each.value.intra_subnet_ipv6_native, var.defaults.intra_subnet_ipv6_native, false)
  intra_subnet_ipv6_prefixes                                  = try(each.value.intra_subnet_ipv6_prefixes, var.defaults.intra_subnet_ipv6_prefixes, [])
  intra_subnet_names                                          = try(each.value.intra_subnet_names, var.defaults.intra_subnet_names, [])
  intra_subnet_private_dns_hostname_type_on_launch            = try(each.value.intra_subnet_private_dns_hostname_type_on_launch, var.defaults.intra_subnet_private_dns_hostname_type_on_launch, null)
  intra_subnet_suffix                                         = try(each.value.intra_subnet_suffix, var.defaults.intra_subnet_suffix, "intra")
  intra_subnet_tags                                           = try(each.value.intra_subnet_tags, var.defaults.intra_subnet_tags, {})
  intra_subnets                                               = try(each.value.intra_subnets, var.defaults.intra_subnets, [])
  ipv4_ipam_pool_id                                           = try(each.value.ipv4_ipam_pool_id, var.defaults.ipv4_ipam_pool_id, null)
  ipv4_netmask_length                                         = try(each.value.ipv4_netmask_length, var.defaults.ipv4_netmask_length, null)
  ipv6_cidr                                                   = try(each.value.ipv6_cidr, var.defaults.ipv6_cidr, null)
  ipv6_cidr_block_network_border_group                        = try(each.value.ipv6_cidr_block_network_border_group, var.defaults.ipv6_cidr_block_network_border_group, null)
  ipv6_ipam_pool_id                                           = try(each.value.ipv6_ipam_pool_id, var.defaults.ipv6_ipam_pool_id, null)
  ipv6_netmask_length                                         = try(each.value.ipv6_netmask_length, var.defaults.ipv6_netmask_length, null)
  manage_default_network_acl                                  = try(each.value.manage_default_network_acl, var.defaults.manage_default_network_acl, true)
  manage_default_route_table                                  = try(each.value.manage_default_route_table, var.defaults.manage_default_route_table, true)
  manage_default_security_group                               = try(each.value.manage_default_security_group, var.defaults.manage_default_security_group, true)
  manage_default_vpc                                          = try(each.value.manage_default_vpc, var.defaults.manage_default_vpc, false)
  map_customer_owned_ip_on_launch                             = try(each.value.map_customer_owned_ip_on_launch, var.defaults.map_customer_owned_ip_on_launch, false)
  map_public_ip_on_launch                                     = try(each.value.map_public_ip_on_launch, var.defaults.map_public_ip_on_launch, false)
  name                                                        = try(each.value.name, var.defaults.name, "")
  nat_eip_tags                                                = try(each.value.nat_eip_tags, var.defaults.nat_eip_tags, {})
  nat_gateway_destination_cidr_block                          = try(each.value.nat_gateway_destination_cidr_block, var.defaults.nat_gateway_destination_cidr_block, "0.0.0.0/0")
  nat_gateway_tags                                            = try(each.value.nat_gateway_tags, var.defaults.nat_gateway_tags, {})
  one_nat_gateway_per_az                                      = try(each.value.one_nat_gateway_per_az, var.defaults.one_nat_gateway_per_az, false)
  outpost_acl_tags                                            = try(each.value.outpost_acl_tags, var.defaults.outpost_acl_tags, {})
  outpost_arn                                                 = try(each.value.outpost_arn, var.defaults.outpost_arn, null)
  outpost_az                                                  = try(each.value.outpost_az, var.defaults.outpost_az, null)
  outpost_dedicated_network_acl                               = try(each.value.outpost_dedicated_network_acl, var.defaults.outpost_dedicated_network_acl, false)
  outpost_inbound_acl_rules = try(each.value.outpost_inbound_acl_rules, var.defaults.outpost_inbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  outpost_outbound_acl_rules = try(each.value.outpost_outbound_acl_rules, var.defaults.outpost_outbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  outpost_subnet_assign_ipv6_address_on_creation                = try(each.value.outpost_subnet_assign_ipv6_address_on_creation, var.defaults.outpost_subnet_assign_ipv6_address_on_creation, false)
  outpost_subnet_enable_dns64                                   = try(each.value.outpost_subnet_enable_dns64, var.defaults.outpost_subnet_enable_dns64, true)
  outpost_subnet_enable_resource_name_dns_a_record_on_launch    = try(each.value.outpost_subnet_enable_resource_name_dns_a_record_on_launch, var.defaults.outpost_subnet_enable_resource_name_dns_a_record_on_launch, false)
  outpost_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(each.value.outpost_subnet_enable_resource_name_dns_aaaa_record_on_launch, var.defaults.outpost_subnet_enable_resource_name_dns_aaaa_record_on_launch, true)
  outpost_subnet_ipv6_native                                    = try(each.value.outpost_subnet_ipv6_native, var.defaults.outpost_subnet_ipv6_native, false)
  outpost_subnet_ipv6_prefixes                                  = try(each.value.outpost_subnet_ipv6_prefixes, var.defaults.outpost_subnet_ipv6_prefixes, [])
  outpost_subnet_names                                          = try(each.value.outpost_subnet_names, var.defaults.outpost_subnet_names, [])
  outpost_subnet_private_dns_hostname_type_on_launch            = try(each.value.outpost_subnet_private_dns_hostname_type_on_launch, var.defaults.outpost_subnet_private_dns_hostname_type_on_launch, null)
  outpost_subnet_suffix                                         = try(each.value.outpost_subnet_suffix, var.defaults.outpost_subnet_suffix, "outpost")
  outpost_subnet_tags                                           = try(each.value.outpost_subnet_tags, var.defaults.outpost_subnet_tags, {})
  outpost_subnets                                               = try(each.value.outpost_subnets, var.defaults.outpost_subnets, [])
  private_acl_tags                                              = try(each.value.private_acl_tags, var.defaults.private_acl_tags, {})
  private_dedicated_network_acl                                 = try(each.value.private_dedicated_network_acl, var.defaults.private_dedicated_network_acl, false)
  private_inbound_acl_rules = try(each.value.private_inbound_acl_rules, var.defaults.private_inbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  private_outbound_acl_rules = try(each.value.private_outbound_acl_rules, var.defaults.private_outbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  private_route_table_tags                                      = try(each.value.private_route_table_tags, var.defaults.private_route_table_tags, {})
  private_subnet_assign_ipv6_address_on_creation                = try(each.value.private_subnet_assign_ipv6_address_on_creation, var.defaults.private_subnet_assign_ipv6_address_on_creation, false)
  private_subnet_enable_dns64                                   = try(each.value.private_subnet_enable_dns64, var.defaults.private_subnet_enable_dns64, true)
  private_subnet_enable_resource_name_dns_a_record_on_launch    = try(each.value.private_subnet_enable_resource_name_dns_a_record_on_launch, var.defaults.private_subnet_enable_resource_name_dns_a_record_on_launch, false)
  private_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(each.value.private_subnet_enable_resource_name_dns_aaaa_record_on_launch, var.defaults.private_subnet_enable_resource_name_dns_aaaa_record_on_launch, true)
  private_subnet_ipv6_native                                    = try(each.value.private_subnet_ipv6_native, var.defaults.private_subnet_ipv6_native, false)
  private_subnet_ipv6_prefixes                                  = try(each.value.private_subnet_ipv6_prefixes, var.defaults.private_subnet_ipv6_prefixes, [])
  private_subnet_names                                          = try(each.value.private_subnet_names, var.defaults.private_subnet_names, [])
  private_subnet_private_dns_hostname_type_on_launch            = try(each.value.private_subnet_private_dns_hostname_type_on_launch, var.defaults.private_subnet_private_dns_hostname_type_on_launch, null)
  private_subnet_suffix                                         = try(each.value.private_subnet_suffix, var.defaults.private_subnet_suffix, "private")
  private_subnet_tags                                           = try(each.value.private_subnet_tags, var.defaults.private_subnet_tags, {})
  private_subnet_tags_per_az                                    = try(each.value.private_subnet_tags_per_az, var.defaults.private_subnet_tags_per_az, {})
  private_subnets                                               = try(each.value.private_subnets, var.defaults.private_subnets, [])
  propagate_intra_route_tables_vgw                              = try(each.value.propagate_intra_route_tables_vgw, var.defaults.propagate_intra_route_tables_vgw, false)
  propagate_private_route_tables_vgw                            = try(each.value.propagate_private_route_tables_vgw, var.defaults.propagate_private_route_tables_vgw, false)
  propagate_public_route_tables_vgw                             = try(each.value.propagate_public_route_tables_vgw, var.defaults.propagate_public_route_tables_vgw, false)
  public_acl_tags                                               = try(each.value.public_acl_tags, var.defaults.public_acl_tags, {})
  public_dedicated_network_acl                                  = try(each.value.public_dedicated_network_acl, var.defaults.public_dedicated_network_acl, false)
  public_inbound_acl_rules = try(each.value.public_inbound_acl_rules, var.defaults.public_inbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  public_outbound_acl_rules = try(each.value.public_outbound_acl_rules, var.defaults.public_outbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  public_route_table_tags                                      = try(each.value.public_route_table_tags, var.defaults.public_route_table_tags, {})
  public_subnet_assign_ipv6_address_on_creation                = try(each.value.public_subnet_assign_ipv6_address_on_creation, var.defaults.public_subnet_assign_ipv6_address_on_creation, false)
  public_subnet_enable_dns64                                   = try(each.value.public_subnet_enable_dns64, var.defaults.public_subnet_enable_dns64, true)
  public_subnet_enable_resource_name_dns_a_record_on_launch    = try(each.value.public_subnet_enable_resource_name_dns_a_record_on_launch, var.defaults.public_subnet_enable_resource_name_dns_a_record_on_launch, false)
  public_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(each.value.public_subnet_enable_resource_name_dns_aaaa_record_on_launch, var.defaults.public_subnet_enable_resource_name_dns_aaaa_record_on_launch, true)
  public_subnet_ipv6_native                                    = try(each.value.public_subnet_ipv6_native, var.defaults.public_subnet_ipv6_native, false)
  public_subnet_ipv6_prefixes                                  = try(each.value.public_subnet_ipv6_prefixes, var.defaults.public_subnet_ipv6_prefixes, [])
  public_subnet_names                                          = try(each.value.public_subnet_names, var.defaults.public_subnet_names, [])
  public_subnet_private_dns_hostname_type_on_launch            = try(each.value.public_subnet_private_dns_hostname_type_on_launch, var.defaults.public_subnet_private_dns_hostname_type_on_launch, null)
  public_subnet_suffix                                         = try(each.value.public_subnet_suffix, var.defaults.public_subnet_suffix, "public")
  public_subnet_tags                                           = try(each.value.public_subnet_tags, var.defaults.public_subnet_tags, {})
  public_subnet_tags_per_az                                    = try(each.value.public_subnet_tags_per_az, var.defaults.public_subnet_tags_per_az, {})
  public_subnets                                               = try(each.value.public_subnets, var.defaults.public_subnets, [])
  putin_khuylo                                                 = try(each.value.putin_khuylo, var.defaults.putin_khuylo, true)
  redshift_acl_tags                                            = try(each.value.redshift_acl_tags, var.defaults.redshift_acl_tags, {})
  redshift_dedicated_network_acl                               = try(each.value.redshift_dedicated_network_acl, var.defaults.redshift_dedicated_network_acl, false)
  redshift_inbound_acl_rules = try(each.value.redshift_inbound_acl_rules, var.defaults.redshift_inbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  redshift_outbound_acl_rules = try(each.value.redshift_outbound_acl_rules, var.defaults.redshift_outbound_acl_rules, [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ])
  redshift_route_table_tags                                      = try(each.value.redshift_route_table_tags, var.defaults.redshift_route_table_tags, {})
  redshift_subnet_assign_ipv6_address_on_creation                = try(each.value.redshift_subnet_assign_ipv6_address_on_creation, var.defaults.redshift_subnet_assign_ipv6_address_on_creation, false)
  redshift_subnet_enable_dns64                                   = try(each.value.redshift_subnet_enable_dns64, var.defaults.redshift_subnet_enable_dns64, true)
  redshift_subnet_enable_resource_name_dns_a_record_on_launch    = try(each.value.redshift_subnet_enable_resource_name_dns_a_record_on_launch, var.defaults.redshift_subnet_enable_resource_name_dns_a_record_on_launch, false)
  redshift_subnet_enable_resource_name_dns_aaaa_record_on_launch = try(each.value.redshift_subnet_enable_resource_name_dns_aaaa_record_on_launch, var.defaults.redshift_subnet_enable_resource_name_dns_aaaa_record_on_launch, true)
  redshift_subnet_group_name                                     = try(each.value.redshift_subnet_group_name, var.defaults.redshift_subnet_group_name, null)
  redshift_subnet_group_tags                                     = try(each.value.redshift_subnet_group_tags, var.defaults.redshift_subnet_group_tags, {})
  redshift_subnet_ipv6_native                                    = try(each.value.redshift_subnet_ipv6_native, var.defaults.redshift_subnet_ipv6_native, false)
  redshift_subnet_ipv6_prefixes                                  = try(each.value.redshift_subnet_ipv6_prefixes, var.defaults.redshift_subnet_ipv6_prefixes, [])
  redshift_subnet_names                                          = try(each.value.redshift_subnet_names, var.defaults.redshift_subnet_names, [])
  redshift_subnet_private_dns_hostname_type_on_launch            = try(each.value.redshift_subnet_private_dns_hostname_type_on_launch, var.defaults.redshift_subnet_private_dns_hostname_type_on_launch, null)
  redshift_subnet_suffix                                         = try(each.value.redshift_subnet_suffix, var.defaults.redshift_subnet_suffix, "redshift")
  redshift_subnet_tags                                           = try(each.value.redshift_subnet_tags, var.defaults.redshift_subnet_tags, {})
  redshift_subnets                                               = try(each.value.redshift_subnets, var.defaults.redshift_subnets, [])
  region                                                         = try(each.value.region, var.defaults.region, null)
  reuse_nat_ips                                                  = try(each.value.reuse_nat_ips, var.defaults.reuse_nat_ips, false)
  secondary_cidr_blocks                                          = try(each.value.secondary_cidr_blocks, var.defaults.secondary_cidr_blocks, [])
  single_nat_gateway                                             = try(each.value.single_nat_gateway, var.defaults.single_nat_gateway, false)
  tags                                                           = try(each.value.tags, var.defaults.tags, {})
  use_ipam_pool                                                  = try(each.value.use_ipam_pool, var.defaults.use_ipam_pool, false)
  vpc_block_public_access_exclusions                             = try(each.value.vpc_block_public_access_exclusions, var.defaults.vpc_block_public_access_exclusions, {})
  vpc_block_public_access_options                                = try(each.value.vpc_block_public_access_options, var.defaults.vpc_block_public_access_options, {})
  vpc_flow_log_iam_policy_name                                   = try(each.value.vpc_flow_log_iam_policy_name, var.defaults.vpc_flow_log_iam_policy_name, "vpc-flow-log-to-cloudwatch")
  vpc_flow_log_iam_policy_use_name_prefix                        = try(each.value.vpc_flow_log_iam_policy_use_name_prefix, var.defaults.vpc_flow_log_iam_policy_use_name_prefix, true)
  vpc_flow_log_iam_role_name                                     = try(each.value.vpc_flow_log_iam_role_name, var.defaults.vpc_flow_log_iam_role_name, "vpc-flow-log-role")
  vpc_flow_log_iam_role_path                                     = try(each.value.vpc_flow_log_iam_role_path, var.defaults.vpc_flow_log_iam_role_path, null)
  vpc_flow_log_iam_role_use_name_prefix                          = try(each.value.vpc_flow_log_iam_role_use_name_prefix, var.defaults.vpc_flow_log_iam_role_use_name_prefix, true)
  vpc_flow_log_permissions_boundary                              = try(each.value.vpc_flow_log_permissions_boundary, var.defaults.vpc_flow_log_permissions_boundary, null)
  vpc_flow_log_tags                                              = try(each.value.vpc_flow_log_tags, var.defaults.vpc_flow_log_tags, {})
  vpc_tags                                                       = try(each.value.vpc_tags, var.defaults.vpc_tags, {})
  vpn_gateway_az                                                 = try(each.value.vpn_gateway_az, var.defaults.vpn_gateway_az, null)
  vpn_gateway_id                                                 = try(each.value.vpn_gateway_id, var.defaults.vpn_gateway_id, "")
  vpn_gateway_tags                                               = try(each.value.vpn_gateway_tags, var.defaults.vpn_gateway_tags, {})
}
