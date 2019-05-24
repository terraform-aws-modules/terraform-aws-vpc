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

//output "vpc_enable_classiclink" {
//  description = "Whether or not the VPC has Classiclink enabled"
//  value       = "${element(concat(aws_vpc.this.*.enable_classiclink, list("")), 0)}"
//}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = concat(aws_vpc.this.*.main_route_table_id, [""])[0]
}

//output "vpc_ipv6_association_id" {
//  description = "The association ID for the IPv6 CIDR block"
//  value       = "${element(concat(aws_vpc.this.*.ipv6_association_id, list("")), 0)}"
//}
//
//output "vpc_ipv6_cidr_block" {
//  description = "The IPv6 CIDR block"
//  value       = "${element(concat(aws_vpc.this.*.ipv6_cidr_block, list("")), 0)}"
//}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = aws_vpc_ipv4_cidr_block_association.this.*.cidr_block
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

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = concat(aws_db_subnet_group.database.*.id, [""])[0]
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

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat.*.id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat.*.public_ip
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this.*.id
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = concat(aws_internet_gateway.this.*.id, [""])[0]
}

output "vgw_id" {
  description = "The ID of the VPN Gateway"
  value = concat(
    aws_vpn_gateway.this.*.id,
    aws_vpn_gateway_attachment.this.*.vpn_gateway_id,
    [""],
  )[0]
}

output "default_vpc_id" {
  description = "The ID of the VPC"
  value       = concat(aws_default_vpc.this.*.id, [""])[0]
}

output "default_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = concat(aws_default_vpc.this.*.cidr_block, [""])[0]
}

output "default_vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = concat(aws_default_vpc.this.*.default_security_group_id, [""])[0]
}

output "default_vpc_default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = concat(aws_default_vpc.this.*.default_network_acl_id, [""])[0]
}

output "default_vpc_default_route_table_id" {
  description = "The ID of the default route table"
  value       = concat(aws_default_vpc.this.*.default_route_table_id, [""])[0]
}

output "default_vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = concat(aws_default_vpc.this.*.instance_tenancy, [""])[0]
}

output "default_vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = concat(aws_default_vpc.this.*.enable_dns_support, [""])[0]
}

output "default_vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = concat(aws_default_vpc.this.*.enable_dns_hostnames, [""])[0]
}

//output "default_vpc_enable_classiclink" {
//  description = "Whether or not the VPC has Classiclink enabled"
//  value       = "${element(concat(aws_default_vpc.this.*.enable_classiclink, list("")), 0)}"
//}

output "default_vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = concat(aws_default_vpc.this.*.main_route_table_id, [""])[0]
}

//output "default_vpc_ipv6_association_id" {
//  description = "The association ID for the IPv6 CIDR block"
//  value       = "${element(concat(aws_default_vpc.this.*.ipv6_association_id, list("")), 0)}"
//}
//
//output "default_vpc_ipv6_cidr_block" {
//  description = "The IPv6 CIDR block"
//  value       = "${element(concat(aws_default_vpc.this.*.ipv6_cidr_block, list("")), 0)}"
//}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = concat(aws_network_acl.public.*.id, [""])[0]
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = concat(aws_network_acl.private.*.id, [""])[0]
}

output "intra_network_acl_id" {
  description = "ID of the intra network ACL"
  value       = concat(aws_network_acl.intra.*.id, [""])[0]
}

output "database_network_acl_id" {
  description = "ID of the database network ACL"
  value       = concat(aws_network_acl.database.*.id, [""])[0]
}

output "redshift_network_acl_id" {
  description = "ID of the redshift network ACL"
  value       = concat(aws_network_acl.redshift.*.id, [""])[0]
}

output "elasticache_network_acl_id" {
  description = "ID of the elasticache network ACL"
  value       = concat(aws_network_acl.elasticache.*.id, [""])[0]
}

# VPC Endpoints
output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = concat(aws_vpc_endpoint.s3.*.id, [""])[0]
}

output "vpc_endpoint_s3_pl_id" {
  description = "The prefix list for the S3 VPC endpoint."
  value       = concat(aws_vpc_endpoint.s3.*.prefix_list_id, [""])[0]
}

output "vpc_endpoint_dynamodb_id" {
  description = "The ID of VPC endpoint for DynamoDB"
  value       = concat(aws_vpc_endpoint.dynamodb.*.id, [""])[0]
}

output "vpc_endpoint_dynamodb_pl_id" {
  description = "The prefix list for the DynamoDB VPC endpoint."
  value       = concat(aws_vpc_endpoint.dynamodb.*.prefix_list_id, [""])[0]
}

output "vpc_endpoint_sqs_id" {
  description = "The ID of VPC endpoint for SQS"
  value       = "${element(concat(aws_vpc_endpoint.sqs.*.id, list("")), 0)}"
}

output "vpc_endpoint_sqs_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for SQS."
  value       = "${flatten(aws_vpc_endpoint.sqs.*.network_interface_ids)}"
}

output "vpc_endpoint_sqs_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for SQS."
  value       = "${flatten(aws_vpc_endpoint.sqs.*.dns_entry)}"
}

output "vpc_endpoint_ssm_id" {
  description = "The ID of VPC endpoint for SSM"
  value       = concat(aws_vpc_endpoint.ssm.*.id, [""])[0]
}

output "vpc_endpoint_ssm_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for SSM."
  value       = flatten(aws_vpc_endpoint.ssm.*.network_interface_ids)
}

output "vpc_endpoint_ssm_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for SSM."
  value       = flatten(aws_vpc_endpoint.ssm.*.dns_entry)
}

output "vpc_endpoint_ssmmessages_id" {
  description = "The ID of VPC endpoint for SSMMESSAGES"
  value       = concat(aws_vpc_endpoint.ssmmessages.*.id, [""])[0]
}

output "vpc_endpoint_ssmmessages_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for SSMMESSAGES."
  value       = flatten(aws_vpc_endpoint.ssmmessages.*.network_interface_ids)
}

output "vpc_endpoint_ssmmessages_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for SSMMESSAGES."
  value       = flatten(aws_vpc_endpoint.ssmmessages.*.dns_entry)
}

output "vpc_endpoint_ec2_id" {
  description = "The ID of VPC endpoint for EC2"
  value       = concat(aws_vpc_endpoint.ec2.*.id, [""])[0]
}

output "vpc_endpoint_ec2_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for EC2"
  value       = flatten(aws_vpc_endpoint.ec2.*.network_interface_ids)
}

output "vpc_endpoint_ec2_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for EC2."
  value       = flatten(aws_vpc_endpoint.ec2.*.dns_entry)
}

output "vpc_endpoint_ec2messages_id" {
  description = "The ID of VPC endpoint for EC2MESSAGES"
  value       = concat(aws_vpc_endpoint.ec2messages.*.id, [""])[0]
}

output "vpc_endpoint_ec2messages_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for EC2MESSAGES"
  value       = flatten(aws_vpc_endpoint.ec2messages.*.network_interface_ids)
}

output "vpc_endpoint_ec2messages_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for EC2MESSAGES."
  value       = flatten(aws_vpc_endpoint.ec2messages.*.dns_entry)
}

output "vpc_endpoint_kms_id" {
  description = "The ID of VPC endpoint for KMS"
  value       = concat(aws_vpc_endpoint.kms.*.id, [""])[0]
}

output "vpc_endpoint_kms_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for KMS."
  value       = flatten(aws_vpc_endpoint.kms.*.network_interface_ids)
}

output "vpc_endpoint_kms_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for KMS."
  value       = flatten(aws_vpc_endpoint.kms.*.dns_entry)
}

output "vpc_endpoint_ecr_api_id" {
  description = "The ID of VPC endpoint for ECR API"
  value       = concat(aws_vpc_endpoint.ecr_api.*.id, [""])[0]
}

output "vpc_endpoint_ecr_api_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for ECR API."
  value       = flatten(aws_vpc_endpoint.ecr_api.*.network_interface_ids)
}

output "vpc_endpoint_ecr_api_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for ECR API."
  value       = flatten(aws_vpc_endpoint.ecr_api.*.dns_entry)
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "The ID of VPC endpoint for ECR DKR"
  value       = concat(aws_vpc_endpoint.ecr_dkr.*.id, [""])[0]
}

output "vpc_endpoint_ecr_dkr_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for ECR DKR."
  value       = flatten(aws_vpc_endpoint.ecr_dkr.*.network_interface_ids)
}

output "vpc_endpoint_ecr_dkr_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for ECR DKR."
  value       = flatten(aws_vpc_endpoint.ecr_dkr.*.dns_entry)
}

output "vpc_endpoint_apigw_id" {
  description = "The ID of VPC endpoint for APIGW"
  value       = concat(aws_vpc_endpoint.apigw.*.id, [""])[0]
}

output "vpc_endpoint_apigw_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for APIGW."
  value       = flatten(aws_vpc_endpoint.apigw.*.network_interface_ids)
}

output "vpc_endpoint_apigw_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for APIGW."
  value       = flatten(aws_vpc_endpoint.apigw.*.dns_entry)
}

output "vpc_endpoint_ecs_id" {
  description = "The ID of VPC endpoint for ECS"
  value       = "${element(concat(aws_vpc_endpoint.ecs.*.id, list("")), 0)}"
}

output "vpc_endpoint_ecs_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for ECS."
  value       = "${flatten(aws_vpc_endpoint.ecs.*.network_interface_ids)}"
}

output "vpc_endpoint_ecs_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for ECS."
  value       = "${flatten(aws_vpc_endpoint.ecs.*.dns_entry)}"
}

output "vpc_endpoint_ecs_agent_id" {
  description = "The ID of VPC endpoint for ECS Agent"
  value       = "${element(concat(aws_vpc_endpoint.ecs_agent.*.id, list("")), 0)}"
}

output "vpc_endpoint_ecs_agent_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for ECS Agent."
  value       = "${flatten(aws_vpc_endpoint.ecs_agent.*.network_interface_ids)}"
}

output "vpc_endpoint_ecs_agent_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for ECS Agent."
  value       = "${flatten(aws_vpc_endpoint.ecs_agent.*.dns_entry)}"
}

output "vpc_endpoint_ecs_telemetry_id" {
  description = "The ID of VPC endpoint for ECS Telemetry"
  value       = "${element(concat(aws_vpc_endpoint.ecs_telemetry.*.id, list("")), 0)}"
}

output "vpc_endpoint_ecs_telemetry_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for ECS Telemetry."
  value       = "${flatten(aws_vpc_endpoint.ecs_telemetry.*.network_interface_ids)}"
}

output "vpc_endpoint_ecs_telemetry_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for ECS Telemetry."
  value       = "${flatten(aws_vpc_endpoint.ecs_telemetry.*.dns_entry)}"
}

# Static values (arguments)
output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.azs
}

