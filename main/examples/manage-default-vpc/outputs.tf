# Default VPC
output "default_vpc_id" {
  description = "The ID of the Default VPC"
  value       = module.vpc.default_vpc_id
}

output "default_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.default_vpc_cidr_block
}

