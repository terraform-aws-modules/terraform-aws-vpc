output "subnet_ids" {
  description = "Map of caller-chosen subnet name to subnet ID"
  value       = module.subnets.ids
}

output "subnet_cidr_blocks" {
  description = "Map of caller-chosen subnet name to IPv4 CIDR block"
  value       = module.subnets.ipv4_cidr_blocks
}

output "eks_subnet_ids" {
  description = "Only the subnets intended for EKS, selected by name"
  value       = { for k, v in module.subnets.ids : k => v if startswith(k, "eks-") }
}
