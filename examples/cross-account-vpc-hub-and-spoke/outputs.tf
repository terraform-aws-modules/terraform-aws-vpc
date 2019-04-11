# VPC
output "hub_vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.hub.vpc_id}"
}

# CIDR blocks
output "hub_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = ["${module.hub.vpc_cidr_block}"]
}

# Subnets
output "hub_private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.hub.private_subnets}"]
}

output "hub_public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.hub.public_subnets}"]
}

# AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = ["${module.hub.azs}"]
}

output "tgw_id" {
  description = "Transist Gateway ID"
  value       = ["${module.hub.tgw_id}"]
}

# VPC
output "spoke_vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.hub.vpc_id}"
}

# CIDR blocks
output "spoke_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = ["${module.hub.vpc_cidr_block}"]
}

# Subnets
output "spoke_private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.hub.private_subnets}"]
}
