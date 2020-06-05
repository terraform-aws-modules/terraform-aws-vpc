# Endpoints
output "vpc_endpoint_ec2_id" {
  description = "The ID of VPC endpoint for EC2"
  value       = module.vpc_endpoints.vpc_endpoint_ec2_id
}

output "vpc_endpoint_ec2_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for EC2"
  value       = module.vpc_endpoints.vpc_endpoint_ec2_network_interface_ids
}