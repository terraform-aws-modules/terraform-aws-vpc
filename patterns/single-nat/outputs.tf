output "nat_gateway_id" {
  description = "The single NAT gateway serving the whole VPC"
  value       = module.public.nat_gateway_ids[local.nat_zone]
}

output "public_subnet_ids" {
  description = "Map of availability zone to public subnet ID"
  value       = module.public.ids
}

output "private_subnet_ids" {
  description = "Map of availability zone to private subnet ID"
  value       = module.private.ids
}

output "private_route_table_id" {
  description = "The single route table shared by every private subnet"
  value       = module.private.shared_route_table_id
}
