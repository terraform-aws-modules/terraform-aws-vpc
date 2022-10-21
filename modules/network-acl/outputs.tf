output "network_acl_id" {
  value       = aws_network_acl.this.id
  description = "The ID of the network ACL"
}

output "network_acl_arn" {
  value       = aws_network_acl.this.arn
  description = "The ARN of the network ACL"
}
