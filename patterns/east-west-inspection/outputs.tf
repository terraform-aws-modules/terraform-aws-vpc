output "app_subnet_ids" {
  description = "Map of availability zone to application tier subnet ID"
  value       = module.app.ids
}

output "db_subnet_ids" {
  description = "Map of availability zone to database tier subnet ID"
  value       = module.db.ids
}

output "firewall_subnet_ids" {
  description = "Map of availability zone to firewall subnet ID"
  value       = module.firewall.ids
}

output "firewall_endpoint_ids" {
  description = "Map of availability zone to the firewall endpoint both tiers route through"
  value       = { for az, e in local.firewall_endpoints : az => e.endpoint_id }
}
