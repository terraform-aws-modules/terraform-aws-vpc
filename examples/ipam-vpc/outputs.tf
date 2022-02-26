# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.ipv4_ipam_explicit_cidrs_calculate_subnets.vpc_id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.ipv4_ipam_explicit_cidrs_calculate_subnets.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.ipv4_ipam_explicit_cidrs_calculate_subnets.public_subnets
}
