################################################################################
# VPC Outputs
################################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

################################################################################
# Subnet Outputs
################################################################################

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

################################################################################
# NAT Gateway Outputs
################################################################################

output "natgw_ids" {
  description = "List of NAT Gateway IDs (will contain a single regional NAT Gateway)"
  value       = module.vpc.natgw_ids
}

output "natgw_regional_addresses" {
  description = "Addresses of the regional NAT Gateway, one per availability zone it is active in (allocation ID, network interface ID, public IP, ...)"
  value       = module.vpc.natgw_regional_addresses
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created by the module for the NAT Gateway (empty with `eip_allocation = \"auto\"`, where AWS allocates the EIPs)"
  value       = module.vpc.nat_public_ips
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created by the module for the NAT Gateway (empty with `eip_allocation = \"auto\"`, where AWS allocates the EIPs)"
  value       = module.vpc.nat_ids
}

output "private_nat_gateway_route_ids" {
  description = "List of IDs of the private nat gateway route (all route to the same regional NAT Gateway)"
  value       = module.vpc.private_nat_gateway_route_ids
}

################################################################################
# Internet Gateway Outputs
################################################################################

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}
