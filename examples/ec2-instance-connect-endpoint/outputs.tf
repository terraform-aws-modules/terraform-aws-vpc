output "instance_connect_endpoint_id" {
  description = "The ID of the EC2 Instance Connect Endpoint"
  value       = module.vpc.instance_connect_endpoint_id
}
