output "public_subnet_ids" {
  description = "Map of availability zone to public subnet ID"
  value       = module.public.ids
}

output "public_route_table_id" {
  description = "The single route table shared by every public subnet"
  value       = module.public.shared_route_table_id
}

output "nat_gateway_ids" {
  description = "Map of availability zone to the NAT gateway serving that zone"
  value       = module.public.nat_gateway_ids
}

output "private_subnet_ids" {
  description = "Map of availability zone to private subnet ID"
  value       = module.private.ids
}

output "private_route_table_ids" {
  description = "Map of availability zone to route table ID, one per private subnet"
  value       = module.private.route_table_ids
}
