################################################################################
# Route Table
################################################################################

output "id" {
  description = "The ID of the route table"
  value       = try(aws_route_table.this[0].id, null)
}

output "arn" {
  description = "The ARN of the route table"
  value       = try(aws_route_table.this[0].arn, null)
}

output "owner_id" {
  description = "The ID of the AWS account that owns the route table"
  value       = try(aws_route_table.this[0].owner_id, null)
}

################################################################################
# Routes
################################################################################

output "routes" {
  description = "Map of routes created and their attributes"
  value       = aws_route.this
}

################################################################################
# Gateway Association
################################################################################

output "route_table_association_id" {
  description = "The ID of the association between the route table and the gateway"
  value       = try(aws_route_table_association.this[0].id, null)
}
