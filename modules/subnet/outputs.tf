################################################################################
# Subnet
################################################################################

output "arn" {
  description = "The ARN of the subnet"
  value       = try(aws_subnet.this[0].arn, null)
}

output "id" {
  description = "The ID of the subnet"
  value       = try(aws_subnet.this[0].id, null)
}

output "owner_id" {
  description = "The ID of the AWS account that owns the subnet"
  value       = try(aws_subnet.this[0].owner_id, null)
}

output "ipv4_cidr_block" {
  description = "IPv4 CIDR block assigned to the subnet"
  value       = try(aws_subnet.this[0].cidr_block, null)
}

output "ipv6_cidr_block" {
  description = "IPv6 CIDR block assigned to the subnet"
  value       = try(aws_subnet.this[0].ipv6_cidr_block, null)
}

output "network_acl_association_id" {
  description = "The ID of the association between the subnet and its network ACL"
  value       = try(aws_network_acl_association.this[0].id, null)
}

################################################################################
# Route Table
################################################################################

output "route_table_id" {
  description = "The ID of the route table"
  value       = try(aws_route_table.this[0].id, null)
}

output "route_table_arn" {
  description = "The ARN of the route table"
  value       = try(aws_route_table.this[0].arn, null)
}

output "route_table_association_id" {
  description = "The ID of the association between the route table and the subnet"
  value       = try(aws_route_table_association.subnet[0].id, null)
}

output "route_table_owner_id" {
  description = "The ID of the AWS account that owns the route table"
  value       = try(aws_route_table.this[0].owner_id, null)
}

################################################################################
# Routes
################################################################################

output "routes" {
  description = "Map of routes created and their attributes"
  value       = aws_route.this
}

################################################################################
# NAT Gateway
################################################################################

output "eip_carrier_ip" {
  description = "Carrier IP address"
  value       = try(aws_eip.this[0].carrier_ip, null)
}

output "eip_customer_owned_ip" {
  description = "Customer owned IP"
  value       = try(aws_eip.this[0].customer_owned_ip, null)
}

output "eip_id" {
  description = "Contains the EIP allocation ID"
  value       = try(aws_eip.this[0].id, null)
}

output "eip_private_dns" {
  description = "The Private DNS associated with the Elastic IP address"
  value       = try(aws_eip.this[0].private_dns, null)
}

output "eip_private_ip" {
  description = "Contains the private IP address"
  value       = try(aws_eip.this[0].private_ip, null)
}

output "eip_public_dns" {
  description = "Public DNS associated with the Elastic IP address"
  value       = try(aws_eip.this[0].public_dns, null)
}

output "eip_public_ip" {
  description = "Contains the public IP address"
  value       = try(aws_eip.this[0].public_ip, null)
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = try(aws_nat_gateway.this[0].id, null)
}

output "nat_gateway_network_interface_id" {
  description = "The ID of the network interface associated with the NAT gateway"
  value       = try(aws_nat_gateway.this[0].network_interface_id, null)
}

output "nat_gateway_private_ip" {
  description = "The private IP address of the NAT Gateway"
  value       = try(aws_nat_gateway.this[0].private_ip, null)
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = try(aws_nat_gateway.this[0].public_ip, null)
}
