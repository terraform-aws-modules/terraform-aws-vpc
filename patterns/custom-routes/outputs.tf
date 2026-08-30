output "private_route_table_id" {
  description = "The route table carrying all four routes"
  value       = module.private.shared_route_table_id
}

output "routes" {
  description = "The route keys carried by the private route table, showing the key is the address"
  value       = keys(module.private.shared_route_table_routes)
}

output "private_subnet_ids" {
  description = "Map of availability zone to private subnet ID"
  value       = module.private.ids
}
