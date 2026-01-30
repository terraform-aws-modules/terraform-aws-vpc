################################################################################
# VPC Outputs
################################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC (allocated from top-level IPAM pool)"
  value       = module.vpc.vpc_cidr_block
}

################################################################################
# VPC IPAM Pool Outputs
################################################################################

# The VPC IPAM pool is created using the native aws_vpc_ipam_pool resource
# with a source_resource block that scopes it to the VPC

output "vpc_ipam_pool_id" {
  description = "The ID of the VPC-scoped IPAM pool for subnet allocation (from aws_vpc_ipam_pool resource)"
  value       = module.vpc.vpc_ipam_pool_id
}

output "vpc_ipam_pool_arn" {
  description = "The ARN of the VPC-scoped IPAM pool (from aws_vpc_ipam_pool resource)"
  value       = module.vpc.vpc_ipam_pool_arn
}

output "vpc_ipam_pool_cidr" {
  description = "The CIDR provisioned to the VPC IPAM pool (from aws_vpc_ipam_pool_cidr resource)"
  value       = module.vpc.vpc_ipam_pool_cidr
}

################################################################################
# RAM Share Outputs
################################################################################

# RAM sharing is managed using native aws_ram_resource_share,
# aws_ram_resource_association, and aws_ram_principal_association resources

output "vpc_ipam_pool_ram_share_id" {
  description = "The ID of the RAM resource share (from aws_ram_resource_share resource)"
  value       = module.vpc.vpc_ipam_pool_ram_share_id
}

output "vpc_ipam_pool_ram_share_arn" {
  description = "The ARN of the RAM resource share (from aws_ram_resource_share resource)"
  value       = module.vpc.vpc_ipam_pool_ram_share_arn
}

################################################################################
# IPAM Subnets Outputs
################################################################################

# Subnets are created using native aws_subnet resources with ipv4_ipam_pool_id
# parameter, which automatically allocates CIDRs from the IPAM pool

output "ipam_subnets" {
  description = "Map of IPAM-created subnet IDs (from aws_subnet resources with ipv4_ipam_pool_id)"
  value       = module.vpc.ipam_subnets
}

output "ipam_subnets_cidr_blocks" {
  description = "Map of IPAM-allocated subnet CIDR blocks (automatically allocated based on netmask_length)"
  value       = module.vpc.ipam_subnets_cidr_blocks
}

output "ipam_subnets_availability_zones" {
  description = "Map of IPAM-created subnet availability zones"
  value       = module.vpc.ipam_subnets_availability_zones
}

################################################################################
# Top-level IPAM Outputs
################################################################################

output "top_level_ipam_id" {
  description = "The ID of the top-level IPAM instance"
  value       = aws_vpc_ipam.this.id
}

output "top_level_ipam_pool_id" {
  description = "The ID of the top-level IPAM pool (source pool for VPC-scoped pools)"
  value       = aws_vpc_ipam_pool.top_level.id
}
