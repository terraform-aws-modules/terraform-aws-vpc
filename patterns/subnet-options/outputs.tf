################################################################################
# Subnet
################################################################################

output "arn" {
  description = "The ARN of the subnet"
  value       = module.external_eip_subnet.arn
}

output "id" {
  description = "The ID of the subnet"
  value       = module.external_eip_subnet.id
}

output "owner_id" {
  description = "The ID of the AWS account that owns the subnet"
  value       = module.external_eip_subnet.owner_id
}

output "ipv4_cidr_block" {
  description = "IPv4 CIDR block assigned to the subnet"
  value       = module.external_eip_subnet.ipv4_cidr_block
}

output "ipv6_cidr_block" {
  description = "IPv6 CIDR block assigned to the subnet"
  value       = module.external_eip_subnet.ipv6_cidr_block
}

output "network_acl_association_id" {
  description = "The ID of the association between the second subnet and the network ACL it joins"
  value       = module.managed_eip_subnet.network_acl_association_id
}

################################################################################
# Route Table
################################################################################

output "route_table_id" {
  description = "The ID of the route table"
  value       = module.external_eip_subnet.route_table_id
}

output "route_table_arn" {
  description = "The ARN of the route table"
  value       = module.external_eip_subnet.route_table_arn
}

output "route_table_association_id" {
  description = "The ID of the association between the route table and the subnet"
  value       = module.external_eip_subnet.route_table_association_id
}

output "route_table_owner_id" {
  description = "The ID of the AWS account that owns the route table"
  value       = module.external_eip_subnet.route_table_owner_id
}

################################################################################
# Routes
################################################################################

output "routes" {
  description = "Map of routes created and their attributes"
  value       = module.external_eip_subnet.routes
}

################################################################################
# NAT Gateway
################################################################################

output "eip_carrier_ip" {
  description = "Carrier IP address of the sub-module managed Elastic IP"
  value       = module.managed_eip_subnet.eip_carrier_ip
}

output "eip_customer_owned_ip" {
  description = "Customer owned IP of the sub-module managed Elastic IP"
  value       = module.managed_eip_subnet.eip_customer_owned_ip
}

output "eip_id" {
  description = "Allocation ID of the sub-module managed Elastic IP"
  value       = module.managed_eip_subnet.eip_id
}

output "eip_private_dns" {
  description = "The private DNS associated with the sub-module managed Elastic IP"
  value       = module.managed_eip_subnet.eip_private_dns
}

output "eip_private_ip" {
  description = "The private IP address of the sub-module managed Elastic IP"
  value       = module.managed_eip_subnet.eip_private_ip
}

output "eip_public_dns" {
  description = "The public DNS associated with the sub-module managed Elastic IP"
  value       = module.managed_eip_subnet.eip_public_dns
}

output "eip_public_ip" {
  description = "The public IP address of the sub-module managed Elastic IP"
  value       = module.managed_eip_subnet.eip_public_ip
}

output "external_eip_id" {
  description = "Allocation ID of the Elastic IP allocated outside the sub-module and handed to its NAT gateway"
  value       = aws_eip.nat.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT gateway built on the externally allocated Elastic IP"
  value       = module.external_eip_subnet.nat_gateway_id
}

output "nat_gateway_network_interface_id" {
  description = "The ID of the network interface associated with the NAT gateway"
  value       = module.external_eip_subnet.nat_gateway_network_interface_id
}

output "nat_gateway_private_ip" {
  description = "The private IP address of the NAT gateway"
  value       = module.external_eip_subnet.nat_gateway_private_ip
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT gateway, which is the externally allocated Elastic IP"
  value       = module.external_eip_subnet.nat_gateway_public_ip
}

################################################################################
# Disabled
################################################################################

output "disabled_id" {
  description = "The ID of the subnet that is not created, which is null"
  value       = module.disabled.id
}

output "disabled_route_table_id" {
  description = "The ID of the route table that is not created, which is null"
  value       = module.disabled.route_table_id
}

output "disabled_nat_gateway_id" {
  description = "The ID of the NAT gateway that is not created, which is null"
  value       = module.disabled.nat_gateway_id
}
