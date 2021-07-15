output "vpc_id" {
  description = "The ID of the VPC"
  value       = concat(aws_vpc.this.*.id, [""])[0]
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = concat(aws_vpc.this.*.arn, [""])[0]
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = concat(aws_vpc.this.*.cidr_block, [""])[0]
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = concat(aws_vpc.this.*.default_security_group_id, [""])[0]
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = concat(aws_vpc.this.*.default_network_acl_id, [""])[0]
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = concat(aws_vpc.this.*.default_route_table_id, [""])[0]
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = concat(aws_vpc.this.*.instance_tenancy, [""])[0]
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = concat(aws_vpc.this.*.enable_dns_support, [""])[0]
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = concat(aws_vpc.this.*.enable_dns_hostnames, [""])[0]
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = concat(aws_vpc.this.*.main_route_table_id, [""])[0]
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = concat(aws_vpc.this.*.ipv6_association_id, [""])[0]
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block"
  value       = concat(aws_vpc.this.*.ipv6_cidr_block, [""])[0]
}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = aws_vpc_ipv4_cidr_block_association.this.*.cidr_block
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = concat(aws_vpc.this.*.owner_id, [""])[0]
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private.*.id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private.*.arn
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = aws_subnet.private.*.cidr_block
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value       = aws_subnet.private.*.ipv6_cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public.*.id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public.*.arn
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = aws_subnet.public.*.cidr_block
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = aws_subnet.public.*.ipv6_cidr_block
}

output "outpost_subnets" {
  description = "List of IDs of outpost subnets"
  value       = aws_subnet.outpost.*.id
}

output "outpost_subnet_arns" {
  description = "List of ARNs of outpost subnets"
  value       = aws_subnet.outpost.*.arn
}

output "outpost_subnets_cidr_blocks" {
  description = "List of cidr_blocks of outpost subnets"
  value       = aws_subnet.outpost.*.cidr_block
}

output "outpost_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of outpost subnets in an IPv6 enabled VPC"
  value       = aws_subnet.outpost.*.ipv6_cidr_block
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database.*.id
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = aws_subnet.database.*.arn
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = aws_subnet.database.*.cidr_block
}

output "database_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC"
  value       = aws_subnet.database.*.ipv6_cidr_block
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = concat(aws_db_subnet_group.database.*.id, [""])[0]
}

output "database_subnet_group_name" {
  description = "Name of database subnet group"
  value       = concat(aws_db_subnet_group.database.*.name, [""])[0]
}

output "redshift_subnets" {
  description = "List of IDs of redshift subnets"
  value       = aws_subnet.redshift.*.id
}

output "redshift_subnet_arns" {
  description = "List of ARNs of redshift subnets"
  value       = aws_subnet.redshift.*.arn
}

output "redshift_subnets_cidr_blocks" {
  description = "List of cidr_blocks of redshift subnets"
  value       = aws_subnet.redshift.*.cidr_block
}

output "redshift_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of redshift subnets in an IPv6 enabled VPC"
  value       = aws_subnet.redshift.*.ipv6_cidr_block
}

output "redshift_subnet_group" {
  description = "ID of redshift subnet group"
  value       = concat(aws_redshift_subnet_group.redshift.*.id, [""])[0]
}

output "elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = aws_subnet.elasticache.*.id
}

output "elasticache_subnet_arns" {
  description = "List of ARNs of elasticache subnets"
  value       = aws_subnet.elasticache.*.arn
}

output "elasticache_subnets_cidr_blocks" {
  description = "List of cidr_blocks of elasticache subnets"
  value       = aws_subnet.elasticache.*.cidr_block
}

output "elasticache_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of elasticache subnets in an IPv6 enabled VPC"
  value       = aws_subnet.elasticache.*.ipv6_cidr_block
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = aws_subnet.intra.*.id
}

output "intra_subnet_arns" {
  description = "List of ARNs of intra subnets"
  value       = aws_subnet.intra.*.arn
}

output "intra_subnets_cidr_blocks" {
  description = "List of cidr_blocks of intra subnets"
  value       = aws_subnet.intra.*.cidr_block
}

output "intra_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of intra subnets in an IPv6 enabled VPC"
  value       = aws_subnet.intra.*.ipv6_cidr_block
}

output "elasticache_subnet_group" {
  description = "ID of elasticache subnet group"
  value       = concat(aws_elasticache_subnet_group.elasticache.*.id, [""])[0]
}

output "elasticache_subnet_group_name" {
  description = "Name of elasticache subnet group"
  value       = concat(aws_elasticache_subnet_group.elasticache.*.name, [""])[0]
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public.*.id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private.*.id
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = length(aws_route_table.database.*.id) > 0 ? aws_route_table.database.*.id : aws_route_table.private.*.id
}

output "redshift_route_table_ids" {
  description = "List of IDs of redshift route tables"
  value       = length(aws_route_table.redshift.*.id) > 0 ? aws_route_table.redshift.*.id : aws_route_table.private.*.id
}

output "elasticache_route_table_ids" {
  description = "List of IDs of elasticache route tables"
  value       = length(aws_route_table.elasticache.*.id) > 0 ? aws_route_table.elasticache.*.id : aws_route_table.private.*.id
}

output "intra_route_table_ids" {
  description = "List of IDs of intra route tables"
  value       = aws_route_table.intra.*.id
}

output "public_internet_gateway_route_id" {
  description = "ID of the internet gateway route."
  value       = concat(aws_route.public_internet_gateway.*.id, [""])[0]
}

output "public_internet_gateway_ipv6_route_id" {
  description = "ID of the IPv6 internet gateway route."
  value       = concat(aws_route.public_internet_gateway_ipv6.*.id, [""])[0]
}

output "database_internet_gateway_route_id" {
  description = "ID of the database internet gateway route."
  value       = concat(aws_route.database_internet_gateway.*.id, [""])[0]
}

output "database_nat_gateway_route_ids" {
  description = "List of IDs of the database nat gateway route."
  value       = aws_route.database_nat_gateway.*.id
}

output "database_ipv6_egress_route_id" {
  description = "ID of the database IPv6 egress route."
  value       = concat(aws_route.database_ipv6_egress.*.id, [""])[0]
}

output "private_nat_gateway_route_ids" {
  description = "List of IDs of the private nat gateway route."
  value       = aws_route.private_nat_gateway.*.id
}

output "private_ipv6_egress_route_ids" {
  description = "List of IDs of the ipv6 egress route."
  value       = aws_route.private_ipv6_egress.*.id
}

output "private_route_table_association_ids" {
  description = "List of IDs of the private route table association"
  value       = aws_route_table_association.private.*.id
}

output "database_route_table_association_ids" {
  description = "List of IDs of the database route table association"
  value       = aws_route_table_association.database.*.id
}

output "redshift_route_table_association_ids" {
  description = "List of IDs of the redshift route table association"
  value       = aws_route_table_association.redshift.*.id
}

output "redshift_public_route_table_association_ids" {
  description = "List of IDs of the public redshidt route table association"
  value       = aws_route_table_association.redshift_public.*.id
}

output "elasticache_route_table_association_ids" {
  description = "List of IDs of the elasticache route table association"
  value       = aws_route_table_association.elasticache.*.id
}

output "intra_route_table_association_ids" {
  description = "List of IDs of the intra route table association"
  value       = aws_route_table_association.intra.*.id
}

output "public_route_table_association_ids" {
  description = "List of IDs of the public route table association"
  value       = aws_route_table_association.public.*.id
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat.*.id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = var.reuse_nat_ips ? var.external_nat_ips : aws_eip.nat.*.public_ip
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this.*.id
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = concat(aws_internet_gateway.this.*.id, [""])[0]
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = concat(aws_internet_gateway.this.*.arn, [""])[0]
}

output "egress_only_internet_gateway_id" {
  description = "The ID of the egress only Internet Gateway"
  value       = concat(aws_egress_only_internet_gateway.this.*.id, [""])[0]
}

output "cgw_ids" {
  description = "List of IDs of Customer Gateway"
  value       = [for k, v in aws_customer_gateway.this : v.id]
}

output "cgw_arns" {
  description = "List of ARNs of Customer Gateway"
  value       = [for k, v in aws_customer_gateway.this : v.arn]
}

output "this_customer_gateway" {
  description = "Map of Customer Gateway attributes"
  value       = aws_customer_gateway.this
}

output "vgw_id" {
  description = "The ID of the VPN Gateway"
  value       = concat(aws_vpn_gateway.this.*.id, aws_vpn_gateway_attachment.this.*.vpn_gateway_id, [""])[0]
}

output "vgw_arn" {
  description = "The ARN of the VPN Gateway"
  value       = concat(aws_vpn_gateway.this.*.arn, [""])[0]
}

output "default_vpc_id" {
  description = "The ID of the Default VPC"
  value       = concat(aws_default_vpc.this.*.id, [""])[0]
}

output "default_vpc_arn" {
  description = "The ARN of the Default VPC"
  value       = concat(aws_default_vpc.this.*.arn, [""])[0]
}

output "default_vpc_cidr_block" {
  description = "The CIDR block of the Default VPC"
  value       = concat(aws_default_vpc.this.*.cidr_block, [""])[0]
}

output "default_vpc_default_security_group_id" {
  description = "The ID of the security group created by default on Default VPC creation"
  value       = concat(aws_default_vpc.this.*.default_security_group_id, [""])[0]
}

output "default_vpc_default_network_acl_id" {
  description = "The ID of the default network ACL of the Default VPC"
  value       = concat(aws_default_vpc.this.*.default_network_acl_id, [""])[0]
}

output "default_vpc_default_route_table_id" {
  description = "The ID of the default route table of the Default VPC"
  value       = concat(aws_default_vpc.this.*.default_route_table_id, [""])[0]
}

output "default_vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within Default VPC"
  value       = concat(aws_default_vpc.this.*.instance_tenancy, [""])[0]
}

output "default_vpc_enable_dns_support" {
  description = "Whether or not the Default VPC has DNS support"
  value       = concat(aws_default_vpc.this.*.enable_dns_support, [""])[0]
}

output "default_vpc_enable_dns_hostnames" {
  description = "Whether or not the Default VPC has DNS hostname support"
  value       = concat(aws_default_vpc.this.*.enable_dns_hostnames, [""])[0]
}

output "default_vpc_main_route_table_id" {
  description = "The ID of the main route table associated with the Default VPC"
  value       = concat(aws_default_vpc.this.*.main_route_table_id, [""])[0]
}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = concat(aws_network_acl.public.*.id, [""])[0]
}

output "public_network_acl_arn" {
  description = "ARN of the public network ACL"
  value       = concat(aws_network_acl.public.*.arn, [""])[0]
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = concat(aws_network_acl.private.*.id, [""])[0]
}

output "private_network_acl_arn" {
  description = "ARN of the private network ACL"
  value       = concat(aws_network_acl.private.*.arn, [""])[0]
}

output "outpost_network_acl_id" {
  description = "ID of the outpost network ACL"
  value       = concat(aws_network_acl.outpost.*.id, [""])[0]
}

output "outpost_network_acl_arn" {
  description = "ARN of the outpost network ACL"
  value       = concat(aws_network_acl.outpost.*.arn, [""])[0]
}

output "intra_network_acl_id" {
  description = "ID of the intra network ACL"
  value       = concat(aws_network_acl.intra.*.id, [""])[0]
}

output "intra_network_acl_arn" {
  description = "ARN of the intra network ACL"
  value       = concat(aws_network_acl.intra.*.arn, [""])[0]
}

output "database_network_acl_id" {
  description = "ID of the database network ACL"
  value       = concat(aws_network_acl.database.*.id, [""])[0]
}

output "database_network_acl_arn" {
  description = "ARN of the database network ACL"
  value       = concat(aws_network_acl.database.*.arn, [""])[0]
}

output "redshift_network_acl_id" {
  description = "ID of the redshift network ACL"
  value       = concat(aws_network_acl.redshift.*.id, [""])[0]
}

output "redshift_network_acl_arn" {
  description = "ARN of the redshift network ACL"
  value       = concat(aws_network_acl.redshift.*.arn, [""])[0]
}

output "elasticache_network_acl_id" {
  description = "ID of the elasticache network ACL"
  value       = concat(aws_network_acl.elasticache.*.id, [""])[0]
}

output "elasticache_network_acl_arn" {
  description = "ARN of the elasticache network ACL"
  value       = concat(aws_network_acl.elasticache.*.arn, [""])[0]
}

# VPC flow log
output "vpc_flow_log_id" {
  description = "The ID of the Flow Log resource"
  value       = concat(aws_flow_log.this.*.id, [""])[0]
}

output "vpc_flow_log_destination_arn" {
  description = "The ARN of the destination for VPC Flow Logs"
  value       = local.flow_log_destination_arn
}

output "vpc_flow_log_destination_type" {
  description = "The type of the destination for VPC Flow Logs"
  value       = var.flow_log_destination_type
}

output "vpc_flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN of the IAM role used when pushing logs to Cloudwatch log group"
  value       = local.flow_log_iam_role_arn
}

# Static values (arguments)
output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.azs
}

output "name" {
  description = "The name of the VPC specified as argument to this module"
  value       = var.name
}
