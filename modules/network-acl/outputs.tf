output "network_acl_id" {
  value       = aws_network_acl.this[0].id
  description = "The ID of the network ACL"
}

output "network_acl_arn" {
  value       = aws_network_acl.this[0].arn
  description = "The ARN of the network ACL"
}
