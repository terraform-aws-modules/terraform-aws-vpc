################################################################################
# VPC
################################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

################################################################################
# Subnets
################################################################################

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "firewall_subnets" {
  description = "List of IDs of firewall subnets"
  value       = module.vpc.firewall_subnets
}

################################################################################
# NAT Gateway
################################################################################

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "network_firewall_arn" {
  description = "ARN of the Network Firewall"
  value       = module.vpc.network_firewall_arn
}
