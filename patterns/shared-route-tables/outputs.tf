output "shared_route_table_id" {
  description = "The one route table every shared subnet is associated with"
  value       = module.shared.shared_route_table_id
}

output "shared_subnet_route_table_ids" {
  description = "Route table per shared subnet, which is the same ID three times"
  value       = module.shared.route_table_ids
}

output "per_az_route_table_ids" {
  description = "Route table per subnet, which is three distinct IDs"
  value       = module.per_az.route_table_ids
}
