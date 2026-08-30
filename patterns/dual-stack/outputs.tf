output "vpc_ipv6_cidr_block" {
  description = "The IPv6 range assigned to the VPC"
  value       = module.vpc.vpc_ipv6_cidr_block
}

output "public_subnet_ids" {
  description = "Map of availability zone to dual stack public subnet ID"
  value       = module.public.ids
}

output "private_subnet_ids" {
  description = "Map of availability zone to dual stack private subnet ID"
  value       = module.private.ids
}

output "ipv6_only_subnet_ids" {
  description = "Map of availability zone to IPv6 only subnet ID"
  value       = module.ipv6_only.ids
}

output "egress_only_internet_gateway_id" {
  description = "The IPv6 outbound only gateway used by both private tiers"
  value       = module.vpc.egress_only_internet_gateway_id
}
