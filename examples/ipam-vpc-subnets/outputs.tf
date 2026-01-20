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
# VPC IPAM Pool Outputs
################################################################################

output "vpc_ipam_pool_id" {
  description = "The ID of the VPC IPAM pool for subnet allocation"
  value       = module.vpc.vpc_ipam_pool_id
}

output "vpc_ipam_pool_arn" {
  description = "The ARN of the VPC IPAM pool"
  value       = module.vpc.vpc_ipam_pool_arn
}

output "vpc_ipam_pool_cidr" {
  description = "The CIDR provisioned to the VPC IPAM pool"
  value       = module.vpc.vpc_ipam_pool_cidr
}

################################################################################
# RAM Share Outputs
################################################################################

output "vpc_ipam_pool_ram_share_id" {
  description = "The ID of the RAM resource share"
  value       = module.vpc.vpc_ipam_pool_ram_share_id
}

output "vpc_ipam_pool_ram_share_arn" {
  description = "The ARN of the RAM resource share"
  value       = module.vpc.vpc_ipam_pool_ram_share_arn
}

################################################################################
# IPAM Subnets Outputs
################################################################################

output "ipam_subnets" {
  description = "Map of IPAM-created subnet IDs"
  value       = module.vpc.ipam_subnets
}

output "ipam_subnets_cidr_blocks" {
  description = "Map of IPAM-created subnet CIDR blocks"
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
  description = "The ID of the top-level IPAM"
  value       = aws_vpc_ipam.this.id
}

output "top_level_ipam_pool_id" {
  description = "The ID of the top-level IPAM pool"
  value       = aws_vpc_ipam_pool.top_level.id
}
