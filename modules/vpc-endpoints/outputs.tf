output "endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value       = aws_vpc_endpoint.this
}

################################################################################
# Security Group
################################################################################

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = try(aws_security_group.this[0].arn, null)
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, null)
}

output "dns_names" {
  description = "DNS names of vpc endpoint for ingress"
  value = try({for k, v in aws_vpc_endpoint.this : k => v.dns_entry}, null)
}
