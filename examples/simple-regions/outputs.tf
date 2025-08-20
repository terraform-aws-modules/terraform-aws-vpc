output "vpc_id" {
  description = "The ID of the VPC"
  value = { for region, v in module.vpc :
    region => v.vpc_id
  }
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value = { for region, v in module.vpc :
    region => v.vpc_arn
  }
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value = { for region, v in module.vpc :
    region => v.vpc_cidr_block
  }
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value = { for region, v in module.vpc :
    region => v.default_security_group_id
  }
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value = { for region, v in module.vpc :
    region => v.default_network_acl_id
  }
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value = { for region, v in module.vpc :
    region => v.default_route_table_id
  }
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value = { for region, v in module.vpc :
    region => v.vpc_instance_tenancy
  }
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value = { for region, v in module.vpc :
    region => v.vpc_enable_dns_support
  }
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value = { for region, v in module.vpc :
    region => v.vpc_enable_dns_hostnames
  }
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value = { for region, v in module.vpc :
    region => v.vpc_main_route_table_id
  }
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value = { for region, v in module.vpc :
    region => v.vpc_ipv6_association_id
  }
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block"
  value = { for region, v in module.vpc :
    region => v.vpc_ipv6_cidr_block
  }
}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value = { for region, v in module.vpc :
    region => v.vpc_secondary_cidr_blocks
  }
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value = { for region, v in module.vpc :
    region => v.vpc_owner_id
  }
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value = { for region, v in module.vpc :
    region => v.private_subnets
  }
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value = { for region, v in module.vpc :
    region => v.private_subnet_arns
  }
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value = { for region, v in module.vpc :
    region => v.private_subnets_cidr_blocks
  }
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value = { for region, v in module.vpc :
    region => v.private_subnets_ipv6_cidr_blocks
  }
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value = { for region, v in module.vpc :
    region => v.public_subnets
  }
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value = { for region, v in module.vpc :
    region => v.public_subnet_arns
  }
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value = { for region, v in module.vpc :
    region => v.public_subnets_cidr_blocks
  }
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value = { for region, v in module.vpc :
    region => v.public_subnets_ipv6_cidr_blocks
  }
}

output "outpost_subnets" {
  description = "List of IDs of outpost subnets"
  value = { for region, v in module.vpc :
    region => v.outpost_subnets
  }
}

output "outpost_subnet_arns" {
  description = "List of ARNs of outpost subnets"
  value = { for region, v in module.vpc :
    region => v.outpost_subnet_arns
  }
}

output "outpost_subnets_cidr_blocks" {
  description = "List of cidr_blocks of outpost subnets"
  value = { for region, v in module.vpc :
    region => v.outpost_subnets_cidr_blocks
  }
}

output "outpost_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of outpost subnets in an IPv6 enabled VPC"
  value = { for region, v in module.vpc :
    region => v.outpost_subnets_ipv6_cidr_blocks
  }
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value = { for region, v in module.vpc :
    region => v.database_subnets
  }
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value = { for region, v in module.vpc :
    region => v.database_subnet_arns
  }
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value = { for region, v in module.vpc :
    region => v.database_subnets_cidr_blocks
  }
}

output "database_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC"
  value = { for region, v in module.vpc :
    region => v.database_subnets_ipv6_cidr_blocks
  }
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value = { for region, v in module.vpc :
    region => v.database_subnet_group
  }
}

output "database_subnet_group_name" {
  description = "Name of database subnet group"
  value = { for region, v in module.vpc :
    region => v.database_subnet_group_name
  }
}

output "redshift_subnets" {
  description = "List of IDs of redshift subnets"
  value = { for region, v in module.vpc :
    region => v.redshift_subnets
  }
}

output "redshift_subnet_arns" {
  description = "List of ARNs of redshift subnets"
  value = { for region, v in module.vpc :
    region => v.redshift_subnet_arns
  }
}

output "redshift_subnets_cidr_blocks" {
  description = "List of cidr_blocks of redshift subnets"
  value = { for region, v in module.vpc :
    region => v.redshift_subnets_cidr_blocks
  }
}

output "redshift_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of redshift subnets in an IPv6 enabled VPC"
  value = { for region, v in module.vpc :
    region => v.redshift_subnets_ipv6_cidr_blocks
  }
}

output "redshift_subnet_group" {
  description = "ID of redshift subnet group"
  value = { for region, v in module.vpc :
    region => v.redshift_subnet_group
  }
}

output "elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value = { for region, v in module.vpc :
    region => v.elasticache_subnets
  }
}

output "elasticache_subnet_arns" {
  description = "List of ARNs of elasticache subnets"
  value = { for region, v in module.vpc :
    region => v.elasticache_subnet_arns
  }
}

output "elasticache_subnets_cidr_blocks" {
  description = "List of cidr_blocks of elasticache subnets"
  value = { for region, v in module.vpc :
    region => v.elasticache_subnets_cidr_blocks
  }
}

output "elasticache_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of elasticache subnets in an IPv6 enabled VPC"
  value = { for region, v in module.vpc :
    region => v.elasticache_subnets_ipv6_cidr_blocks
  }
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value = { for region, v in module.vpc :
    region => v.intra_subnets
  }
}

output "intra_subnet_arns" {
  description = "List of ARNs of intra subnets"
  value = { for region, v in module.vpc :
    region => v.intra_subnet_arns
  }
}

output "intra_subnets_cidr_blocks" {
  description = "List of cidr_blocks of intra subnets"
  value = { for region, v in module.vpc :
    region => v.intra_subnets_cidr_blocks
  }
}

output "intra_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of intra subnets in an IPv6 enabled VPC"
  value = { for region, v in module.vpc :
    region => v.intra_subnets_ipv6_cidr_blocks
  }
}

output "elasticache_subnet_group" {
  description = "ID of elasticache subnet group"
  value = { for region, v in module.vpc :
    region => v.elasticache_subnet_group
  }
}

output "elasticache_subnet_group_name" {
  description = "Name of elasticache subnet group"
  value = { for region, v in module.vpc :
    region => v.elasticache_subnet_group_name
  }
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value = { for region, v in module.vpc :
    region => v.public_route_table_ids
  }
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value = { for region, v in module.vpc :
    region => v.private_route_table_ids
  }
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value = { for region, v in module.vpc :
    region => v.database_route_table_ids
  }
}

output "redshift_route_table_ids" {
  description = "List of IDs of redshift route tables"
  value = { for region, v in module.vpc :
    region => v.redshift_route_table_ids
  }
}

output "elasticache_route_table_ids" {
  description = "List of IDs of elasticache route tables"
  value = { for region, v in module.vpc :
    region => v.elasticache_route_table_ids
  }
}

output "intra_route_table_ids" {
  description = "List of IDs of intra route tables"
  value = { for region, v in module.vpc :
    region => v.intra_route_table_ids
  }
}

output "public_internet_gateway_route_id" {
  description = "ID of the internet gateway route"
  value = { for region, v in module.vpc :
    region => v.public_internet_gateway_route_id
  }
}

output "public_internet_gateway_ipv6_route_id" {
  description = "ID of the IPv6 internet gateway route"
  value = { for region, v in module.vpc :
    region => v.public_internet_gateway_ipv6_route_id
  }
}

output "database_internet_gateway_route_id" {
  description = "ID of the database internet gateway route"
  value = { for region, v in module.vpc :
    region => v.database_internet_gateway_route_id
  }
}

output "database_nat_gateway_route_ids" {
  description = "List of IDs of the database nat gateway route"
  value = { for region, v in module.vpc :
    region => v.database_nat_gateway_route_ids
  }
}

output "database_ipv6_egress_route_id" {
  description = "ID of the database IPv6 egress route"
  value = { for region, v in module.vpc :
    region => v.database_ipv6_egress_route_id
  }
}

output "private_nat_gateway_route_ids" {
  description = "List of IDs of the private nat gateway route"
  value = { for region, v in module.vpc :
    region => v.private_nat_gateway_route_ids
  }
}

output "private_ipv6_egress_route_ids" {
  description = "List of IDs of the ipv6 egress route"
  value = { for region, v in module.vpc :
    region => v.private_ipv6_egress_route_ids
  }
}

output "private_route_table_association_ids" {
  description = "List of IDs of the private route table association"
  value = { for region, v in module.vpc :
    region => v.private_route_table_association_ids
  }
}

output "database_route_table_association_ids" {
  description = "List of IDs of the database route table association"
  value = { for region, v in module.vpc :
    region => v.database_route_table_association_ids
  }
}

output "redshift_route_table_association_ids" {
  description = "List of IDs of the redshift route table association"
  value = { for region, v in module.vpc :
    region => v.redshift_route_table_association_ids
  }
}

output "redshift_public_route_table_association_ids" {
  description = "List of IDs of the public redshift route table association"
  value = { for region, v in module.vpc :
    region => v.redshift_public_route_table_association_ids
  }
}

output "elasticache_route_table_association_ids" {
  description = "List of IDs of the elasticache route table association"
  value = { for region, v in module.vpc :
    region => v.elasticache_route_table_association_ids
  }
}

output "intra_route_table_association_ids" {
  description = "List of IDs of the intra route table association"
  value = { for region, v in module.vpc :
    region => v.intra_route_table_association_ids
  }
}

output "public_route_table_association_ids" {
  description = "List of IDs of the public route table association"
  value = { for region, v in module.vpc :
    region => v.public_route_table_association_ids
  }
}

output "dhcp_options_id" {
  description = "The ID of the DHCP options"
  value = { for region, v in module.vpc :
    region => v.dhcp_options_id
  }
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value = { for region, v in module.vpc :
    region => v.nat_ids
  }
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value = { for region, v in module.vpc :
    region => v.nat_public_ips
  }
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value = { for region, v in module.vpc :
    region => v.natgw_ids
  }
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value = { for region, v in module.vpc :
    region => v.igw_id
  }
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value = { for region, v in module.vpc :
    region => v.igw_arn
  }
}

output "egress_only_internet_gateway_id" {
  description = "The ID of the egress only Internet Gateway"
  value = { for region, v in module.vpc :
    region => v.egress_only_internet_gateway_id
  }
}

output "cgw_ids" {
  description = "List of IDs of Customer Gateway"
  value = { for region, v in module.vpc :
    region => v.cgw_ids
  }
}

output "cgw_arns" {
  description = "List of ARNs of Customer Gateway"
  value = { for region, v in module.vpc :
    region => v.cgw_arns
  }
}

output "this_customer_gateway" {
  description = "Map of Customer Gateway attributes"
  value = { for region, v in module.vpc :
    region => v.this_customer_gateway
  }
}

output "vgw_id" {
  description = "The ID of the VPN Gateway"
  value = { for region, v in module.vpc :
    region => v.vgw_id
  }
}

output "vgw_arn" {
  description = "The ARN of the VPN Gateway"
  value = { for region, v in module.vpc :
    region => v.vgw_arn
  }
}

output "default_vpc_id" {
  description = "The ID of the Default VPC"
  value = { for region, v in module.vpc :
    region => v.default_vpc_id
  }
}

output "default_vpc_arn" {
  description = "The ARN of the Default VPC"
  value = { for region, v in module.vpc :
    region => v.default_vpc_arn
  }
}

output "default_vpc_cidr_block" {
  description = "The CIDR block of the Default VPC"
  value = { for region, v in module.vpc :
    region => v.default_vpc_cidr_block
  }
}

output "default_vpc_default_security_group_id" {
  description = "The ID of the security group created by default on Default VPC creation"
  value = { for region, v in module.vpc :
    region => v.default_vpc_default_security_group_id
  }
}

output "default_vpc_default_network_acl_id" {
  description = "The ID of the default network ACL of the Default VPC"
  value = { for region, v in module.vpc :
    region => v.default_vpc_default_network_acl_id
  }
}

output "default_vpc_default_route_table_id" {
  description = "The ID of the default route table of the Default VPC"
  value = { for region, v in module.vpc :
    region => v.default_vpc_default_route_table_id
  }
}

output "default_vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within Default VPC"
  value = { for region, v in module.vpc :
    region => v.default_vpc_instance_tenancy
  }
}

output "default_vpc_enable_dns_support" {
  description = "Whether or not the Default VPC has DNS support"
  value = { for region, v in module.vpc :
    region => v.default_vpc_enable_dns_support
  }
}

output "default_vpc_enable_dns_hostnames" {
  description = "Whether or not the Default VPC has DNS hostname support"
  value = { for region, v in module.vpc :
    region => v.default_vpc_enable_dns_hostnames
  }
}

output "default_vpc_main_route_table_id" {
  description = "The ID of the main route table associated with the Default VPC"
  value = { for region, v in module.vpc :
    region => v.default_vpc_main_route_table_id
  }
}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value = { for region, v in module.vpc :
    region => v.public_network_acl_id
  }
}

output "public_network_acl_arn" {
  description = "ARN of the public network ACL"
  value = { for region, v in module.vpc :
    region => v.public_network_acl_arn
  }
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value = { for region, v in module.vpc :
    region => v.private_network_acl_id
  }
}

output "private_network_acl_arn" {
  description = "ARN of the private network ACL"
  value = { for region, v in module.vpc :
    region => v.private_network_acl_arn
  }
}

output "outpost_network_acl_id" {
  description = "ID of the outpost network ACL"
  value = { for region, v in module.vpc :
    region => v.outpost_network_acl_id
  }
}

output "outpost_network_acl_arn" {
  description = "ARN of the outpost network ACL"
  value = { for region, v in module.vpc :
    region => v.outpost_network_acl_arn
  }
}

output "intra_network_acl_id" {
  description = "ID of the intra network ACL"
  value = { for region, v in module.vpc :
    region => v.intra_network_acl_id
  }
}

output "intra_network_acl_arn" {
  description = "ARN of the intra network ACL"
  value = { for region, v in module.vpc :
    region => v.intra_network_acl_arn
  }
}

output "database_network_acl_id" {
  description = "ID of the database network ACL"
  value = { for region, v in module.vpc :
    region => v.database_network_acl_id
  }
}

output "database_network_acl_arn" {
  description = "ARN of the database network ACL"
  value = { for region, v in module.vpc :
    region => v.database_network_acl_arn
  }
}

output "redshift_network_acl_id" {
  description = "ID of the redshift network ACL"
  value = { for region, v in module.vpc :
    region => v.redshift_network_acl_id
  }
}

output "redshift_network_acl_arn" {
  description = "ARN of the redshift network ACL"
  value = { for region, v in module.vpc :
    region => v.redshift_network_acl_arn
  }
}

output "elasticache_network_acl_id" {
  description = "ID of the elasticache network ACL"
  value = { for region, v in module.vpc :
    region => v.elasticache_network_acl_id
  }
}

output "elasticache_network_acl_arn" {
  description = "ARN of the elasticache network ACL"
  value = { for region, v in module.vpc :
    region => v.elasticache_network_acl_arn
  }
}

# VPC flow log
output "vpc_flow_log_id" {
  description = "The ID of the Flow Log resource"
  value = { for region, v in module.vpc :
    region => v.vpc_flow_log_id
  }
}

output "vpc_flow_log_destination_arn" {
  description = "The ARN of the destination for VPC Flow Logs"
  value = { for region, v in module.vpc :
    region => v.vpc_flow_log_destination_arn
  }
}

output "vpc_flow_log_destination_type" {
  description = "The type of the destination for VPC Flow Logs"
  value = { for region, v in module.vpc :
    region => v.vpc_flow_log_destination_type
  }
}

output "vpc_flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN of the IAM role used when pushing logs to Cloudwatch log group"
  value = { for region, v in module.vpc :
    region => v.vpc_flow_log_cloudwatch_iam_role_arn
  }
}
