output "vpc_cidr_block" {
  description = "The CIDR IPAM allocated to the VPC, not known until apply"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_cidr_blocks" {
  description = "Map of availability zone to public subnet CIDR, carved from the allocation"
  value       = module.public.ipv4_cidr_blocks
}

output "private_subnet_cidr_blocks" {
  description = "Map of availability zone to private subnet CIDR, carved from the allocation"
  value       = module.private.ipv4_cidr_blocks
}

output "ipam_regional_pool_id" {
  description = "The regional pool the VPC CIDR was allocated from"
  value       = aws_vpc_ipam_pool.regional.id
}
