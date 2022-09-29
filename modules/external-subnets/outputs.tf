output "external_subnets" {
  description = "List of IDs of external subnets"
  value       = try(aws_subnet.external_subnets[*].id, [])
}

output "external_subnet_arns" {
  description = "List of ARNs of external subnets"
  value       = try(aws_subnet.external_subnets[*].arn, [])
}

output "external_subnets_cidr_blocks" {
  description = "List of cidr_blocks of external subnets"
  value       = try(compact(aws_subnet.external_subnets[*].cidr_block), [])
}

output "external_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of external subnets in an IPv6 enabled VPC"
  value       = try(compact(aws_subnet.external_subnets[*].ipv6_cidr_block), [])
}

output "external_route_table_ids" {
  description = "List of IDs of external route tables"
  value       = try(aws_route_table.external_subnets[*].id, [])
}

output "external_route_table_association_ids" {
  description = "List of IDs of the external route table association"
  value       = try(aws_route_table_association.external_subnets[*].id, [])
}
