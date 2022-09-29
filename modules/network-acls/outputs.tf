output "network_acl_id" {
  description = "ID of the network ACL"
  value       = try(aws_network_acl.this[0].id, "")
}

output "network_acl_arn" {
  description = "ARN of the network ACL"
  value       = try(aws_network_acl.this[0].arn, "")
}
