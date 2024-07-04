output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "nat_public_secondary_ips" {
  description = "The secondary public IPs of the NAT gateways"
  value       = module.vpc.nat_public_secondary_ips
}
