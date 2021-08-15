# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "ipv6_cidr_block" {
  description = "The IPv6 CIDR block"
  value       = module.vpc.vpc_ipv6_cidr_block
}

output "ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = module.vpc.vpc_ipv6_association_id
}
