################################################################################
# VPC IPAM Pool Outputs
################################################################################

output "vpc_ipam_pool_id" {
  description = "The ID of the VPC IPAM pool for subnet allocation"
  value       = local.vpc_ipam_pool_id
}

output "vpc_ipam_pool_arn" {
  description = "The ARN of the VPC IPAM pool"
  value       = local.vpc_ipam_pool_arn
}

################################################################################
# RAM Share Outputs
################################################################################

output "vpc_ipam_pool_ram_share_arn" {
  description = "The ARN of the RAM resource share for the VPC IPAM pool"
  value       = try(file("${path.module}/.terraform/vpc-ipam-pool-ram-share.arn"), "")
}

################################################################################
# IPAM Subnets Outputs
################################################################################

output "ipam_subnets" {
  description = "Map of IPAM-created subnet IDs"
  value       = { for k, v in data.aws_subnet.ipam_subnets : k => v.id }
}

output "ipam_subnets_cidr_blocks" {
  description = "Map of IPAM-created subnet CIDR blocks"
  value       = { for k, v in data.aws_subnet.ipam_subnets : k => v.cidr_block }
}

output "ipam_subnets_arns" {
  description = "Map of IPAM-created subnet ARNs"
  value       = { for k, v in data.aws_subnet.ipam_subnets : k => v.arn }
}

output "ipam_subnets_availability_zones" {
  description = "Map of IPAM-created subnet availability zones"
  value       = { for k, v in data.aws_subnet.ipam_subnets : k => v.availability_zone }
}

output "ipam_subnet_objects" {
  description = "Full objects of all IPAM-created subnets"
  value       = data.aws_subnet.ipam_subnets
}
