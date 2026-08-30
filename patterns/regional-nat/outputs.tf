output "nat_gateway_id" {
  description = "The ID of the regional NAT gateway serving every availability zone"
  value       = module.vpc.regional_nat_gateway_id
}

output "private_subnet_ids" {
  description = "Map of availability zone to private subnet ID"
  value       = module.private.ids
}

output "private_route_table_id" {
  description = "The single route table shared by every private subnet"
  value       = module.private.shared_route_table_id
}
