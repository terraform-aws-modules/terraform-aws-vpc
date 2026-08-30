output "subnets" {
  description = "Map of subnet keys to all attributes of the subnet sub-module"
  value       = module.subnet
}

output "ids" {
  description = "Map of subnet keys to subnet IDs"
  value       = { for k, v in module.subnet : k => v.id }
}

output "arns" {
  description = "Map of subnet keys to subnet ARNs"
  value       = { for k, v in module.subnet : k => v.arn }
}

output "ipv4_cidr_blocks" {
  description = "Map of subnet keys to IPv4 CIDR blocks"
  value       = { for k, v in module.subnet : k => v.ipv4_cidr_block }
}

output "ipv6_cidr_blocks" {
  description = "Map of subnet keys to IPv6 CIDR blocks"
  value       = { for k, v in module.subnet : k => v.ipv6_cidr_block }
}

output "route_table_ids" {
  description = "Map of subnet keys to the route table associated with that subnet"
  value       = { for k, v in module.subnet : k => v.route_table_id }
}

output "shared_route_table_id" {
  description = "The route table shared by every subnet, when the group's routes are identical"
  value       = module.route_table.id
}

output "shared_route_table_routes" {
  description = "Map of the routes on the shared route table, when one was created"
  value       = module.route_table.routes
}

output "nat_gateway_ids" {
  description = "Map of subnet keys to the NAT gateway created in that subnet"
  value = {
    for k, v in module.subnet : k => v.nat_gateway_id
    if coalesce(var.subnets[k].create_nat_gateway, var.create_nat_gateway)
  }
}

output "network_acl_id" {
  description = "The ID of the network ACL created for the group"
  value       = try(aws_network_acl.this[0].id, null)
}
