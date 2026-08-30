output "gwlb_endpoint_ids" {
  description = "Map of availability zone to Gateway Load Balancer endpoint ID"
  value       = { for k, v in aws_vpc_endpoint.gwlb : k => v.id }
}

output "application_subnet_ids" {
  description = "Map of availability zone to application subnet ID"
  value       = module.application.ids
}

output "endpoint_subnet_ids" {
  description = "Map of availability zone to endpoint subnet ID"
  value       = module.endpoint.ids
}

output "igw_ingress_route_table_id" {
  description = "The gateway route table that sends inbound traffic to the endpoints"
  value       = module.igw_ingress.id
}
