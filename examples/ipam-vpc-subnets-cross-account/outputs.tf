################################################################################
# IPAM Outputs (Networking Account)
################################################################################

output "ipam_id" {
  description = "The ID of the IPAM instance in networking account"
  value       = aws_vpc_ipam.main.id
}

output "ipam_arn" {
  description = "The ARN of the IPAM instance in networking account"
  value       = aws_vpc_ipam.main.arn
}

output "ipam_private_default_scope_id" {
  description = "The ID of the IPAM private default scope"
  value       = aws_vpc_ipam.main.private_default_scope_id
}

output "top_level_ipam_pool_id" {
  description = "The ID of the top-level IPAM pool in networking account"
  value       = aws_vpc_ipam_pool.top_level.id
}

output "top_level_ipam_pool_arn" {
  description = "The ARN of the top-level IPAM pool in networking account"
  value       = aws_vpc_ipam_pool.top_level.arn
}

output "top_level_ipam_pool_cidr" {
  description = "The CIDR provisioned to the top-level IPAM pool"
  value       = aws_vpc_ipam_pool_cidr.top_level.cidr
}

################################################################################
# RAM Share Outputs (Networking Account)
################################################################################

output "ram_share_id" {
  description = "The ID of the RAM resource share"
  value       = aws_ram_resource_share.ipam_pool.id
}

output "ram_share_arn" {
  description = "The ARN of the RAM resource share"
  value       = aws_ram_resource_share.ipam_pool.arn
}

################################################################################
# VPC Outputs (Application Account)
################################################################################

output "vpc_id" {
  description = "The ID of the VPC in application account"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC in application account"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_owner_id" {
  description = "The owner ID of the VPC"
  value       = module.vpc.vpc_owner_id
}

################################################################################
# VPC IPAM Pool Outputs (Application Account)
################################################################################

output "vpc_ipam_pool_id" {
  description = "The ID of the VPC-scoped IPAM pool in application account (from aws_vpc_ipam_pool resource)"
  value       = module.vpc.vpc_ipam_pool_id
}

output "vpc_ipam_pool_arn" {
  description = "The ARN of the VPC-scoped IPAM pool in application account (from aws_vpc_ipam_pool resource)"
  value       = module.vpc.vpc_ipam_pool_arn
}

output "vpc_ipam_pool_cidr" {
  description = "The CIDR provisioned to the VPC IPAM pool (from aws_vpc_ipam_pool_cidr resource)"
  value       = module.vpc.vpc_ipam_pool_cidr
}

################################################################################
# Subnet Outputs (Application Account)
################################################################################

output "ipam_subnets" {
  description = "Map of IPAM-created subnet IDs (from aws_subnet resources with ipv4_ipam_pool_id)"
  value       = module.vpc.ipam_subnets
}

output "ipam_subnets_cidr_blocks" {
  description = "Map of IPAM-allocated subnet CIDR blocks (automatically allocated based on netmask_length)"
  value       = module.vpc.ipam_subnets_cidr_blocks
}

output "ipam_subnets_arns" {
  description = "Map of IPAM-created subnet ARNs"
  value       = module.vpc.ipam_subnets_arns
}

output "ipam_subnets_availability_zones" {
  description = "Map of IPAM-created subnet availability zones"
  value       = module.vpc.ipam_subnets_availability_zones
}

output "ipam_subnet_objects" {
  description = "Map of IPAM subnet objects with all attributes"
  value       = module.vpc.ipam_subnet_objects
}

################################################################################
# Summary Output
################################################################################

output "summary" {
  description = "Summary of the cross-account IPAM deployment"
  value = {
    networking_account = {
      account_id         = var.networking_account_id
      ipam_id            = aws_vpc_ipam.main.id
      top_level_pool_id  = aws_vpc_ipam_pool.top_level.id
      top_level_pool_arn = aws_vpc_ipam_pool.top_level.arn
      ram_share_arn      = aws_ram_resource_share.ipam_pool.arn
    }
    application_account = {
      account_id       = var.application_account_id
      vpc_id           = module.vpc.vpc_id
      vpc_cidr         = module.vpc.vpc_cidr_block
      vpc_ipam_pool_id = module.vpc.vpc_ipam_pool_id
      subnet_count     = length(module.vpc.ipam_subnets)
      subnet_cidrs     = values(module.vpc.ipam_subnets_cidr_blocks)
    }
  }
}
