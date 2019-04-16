# VPC-1
output "vpc-1_vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc-1.vpc_id}"
}

# CIDR blocks
output "vpc-1_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = ["${module.vpc-1.vpc_cidr_block}"]
}

# Subnets
output "vpc-1_private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.vpc-1.private_subnets}"]
}

output "vpc-1_public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.vpc-1.public_subnets}"]
}

# NAT gateways
output "vpc-1_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = ["${module.vpc-1.nat_public_ips}"]
}

# AZs
output "vpc-1_azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = ["${module.vpc-1.azs}"]
}

output "vpc-1_tgw_id" {
  description = "Transist Gateway ID"
  value       = ["${module.vpc-1.tgw_id}"]
}

# VPC-2
output "vpc-2_vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc-2.vpc_id}"
}

# CIDR blocks
output "vpc-2_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = ["${module.vpc-2.vpc_cidr_block}"]
}

# Subnets
output "vpc-2_private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.vpc-2.private_subnets}"]
}

output "vpc-2_public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.vpc-2.public_subnets}"]
}

# NAT gateways
output "vpc-2_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = ["${module.vpc-2.nat_public_ips}"]
}

# AZs
output "vpc-2_azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = ["${module.vpc-2.azs}"]
}


