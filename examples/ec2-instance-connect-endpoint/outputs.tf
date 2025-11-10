output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "instance_connect_endpoints" {
  description = "Map of EC2 Instance Connect Endpoints created"
  value       = module.vpc.instance_connect_endpoints
}
