################################################################################
# Issue 44
################################################################################

# VPC
output "issue_44_vpc_id" {
  description = "The ID of the VPC"
  value       = module.asymmetrical_subnets.vpc_id
}

# Subnets
output "issue_44_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.asymmetrical_subnets.private_subnets
}

output "issue_44_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.asymmetrical_subnets.public_subnets
}

output "issue_44_database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.asymmetrical_subnets.database_subnets
}

output "issue_44_elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = module.asymmetrical_subnets.elasticache_subnets
}

# NAT gateways
output "issue_44_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.asymmetrical_subnets.nat_public_ips
}

################################################################################
# Issue 46
################################################################################

# VPC
output "issue_46_vpc_id" {
  description = "The ID of the VPC"
  value       = module.no_private_subnets.vpc_id
}

# Subnets
output "issue_46_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.no_private_subnets.private_subnets
}

output "issue_46_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.no_private_subnets.public_subnets
}

output "issue_46_database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.no_private_subnets.database_subnets
}

output "issue_46_elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = module.no_private_subnets.elasticache_subnets
}

# NAT gateways
output "issue_46_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.no_private_subnets.nat_public_ips
}

################################################################################
# Issue 108
################################################################################

# VPC
output "issue_108_vpc_id" {
  description = "The ID of the VPC"
  value       = module.overlapping_public_subnets.vpc_id
}

# Subnets
output "issue_108_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.overlapping_public_subnets.private_subnets
}

output "issue_108_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.overlapping_public_subnets.public_subnets
}

output "issue_108_database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.overlapping_public_subnets.database_subnets
}

output "issue_108_elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = module.overlapping_public_subnets.elasticache_subnets
}

# NAT gateways
output "issue_108_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.overlapping_public_subnets.nat_public_ips
}
