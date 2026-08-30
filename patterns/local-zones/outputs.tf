output "region_subnet_ids" {
  description = "Map of parent Region availability zone to private subnet ID"
  value       = module.region_private.ids
}

output "region_nat_gateway_id" {
  description = "The NAT gateway serving the parent Region"
  value       = module.region_public.nat_gateway_ids[local.azs[0]]
}

output "local_zone_subnet_id" {
  description = "The private subnet in the Local Zone"
  value       = module.local_zone_private_subnet.id
}

output "local_zone_nat_gateway_id" {
  description = "The NAT gateway in the Local Zone, distinct from the Region's"
  value       = module.local_zone_public_subnet.nat_gateway_id
}
