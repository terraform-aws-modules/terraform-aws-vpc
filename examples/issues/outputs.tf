################################################################################
# Issue 44
################################################################################

# VPC
output "issue_44_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc_issue_44.vpc_id
}

# Subnets
output "issue_44_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc_issue_44.private_subnets
}

output "issue_44_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc_issue_44.public_subnets
}

output "issue_44_database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc_issue_44.database_subnets
}

output "issue_44_elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = module.vpc_issue_44.elasticache_subnets
}

# NAT gateways
output "issue_44_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc_issue_44.nat_public_ips
}

################################################################################
# Issue 46
################################################################################

# VPC
output "issue_46_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc_issue_46.vpc_id
}

# Subnets
output "issue_46_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc_issue_46.private_subnets
}

output "issue_46_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc_issue_46.public_subnets
}

output "issue_46_database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc_issue_46.database_subnets
}

output "issue_46_elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = module.vpc_issue_46.elasticache_subnets
}

# NAT gateways
output "issue_46_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc_issue_46.nat_public_ips
}

################################################################################
# Issue 108
################################################################################

# VPC
output "issue_108_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc_issue_108.vpc_id
}

# Subnets
output "issue_108_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc_issue_108.private_subnets
}

output "issue_108_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc_issue_108.public_subnets
}

output "issue_108_database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc_issue_108.database_subnets
}

output "issue_108_elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = module.vpc_issue_108.elasticache_subnets
}

# NAT gateways
output "issue_108_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc_issue_108.nat_public_ips
}
