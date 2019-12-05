variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_ipv6" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
  type        = bool
  default     = false
}

variable "private_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list
  default     = []
}

variable "public_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list
  default     = []
}

variable "database_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 database subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list
  default     = []
}

variable "redshift_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 redshift subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list
  default     = []
}

variable "elasticache_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 elasticache subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list
  default     = []
}

variable "intra_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 intra subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list
  default     = []
}

variable "assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = false
}

variable "private_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on private subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = null
}

variable "public_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on public subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = null
}

variable "database_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on database subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = null
}

variable "redshift_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on redshift subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = null
}

variable "elasticache_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on elasticache subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = null
}

variable "intra_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on intra subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = bool
  default     = null
}

variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type        = list(string)
  default     = []
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public"
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private"
}

variable "intra_subnet_suffix" {
  description = "Suffix to append to intra subnets name"
  type        = string
  default     = "intra"
}

variable "database_subnet_suffix" {
  description = "Suffix to append to database subnets name"
  type        = string
  default     = "db"
}

variable "redshift_subnet_suffix" {
  description = "Suffix to append to redshift subnets name"
  type        = string
  default     = "redshift"
}

variable "elasticache_subnet_suffix" {
  description = "Suffix to append to elasticache subnets name"
  type        = string
  default     = "elasticache"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  description = "A list of database subnets"
  type        = list(string)
  default     = []
}

variable "redshift_subnets" {
  description = "A list of redshift subnets"
  type        = list(string)
  default     = []
}

variable "elasticache_subnets" {
  description = "A list of elasticache subnets"
  type        = list(string)
  default     = []
}

variable "intra_subnets" {
  description = "A list of intra subnets"
  type        = list(string)
  default     = []
}

variable "create_database_subnet_route_table" {
  description = "Controls if separate route table for database should be created"
  type        = bool
  default     = false
}

variable "create_redshift_subnet_route_table" {
  description = "Controls if separate route table for redshift should be created"
  type        = bool
  default     = false
}

variable "enable_public_redshift" {
  description = "Controls if redshift should have public routing table"
  type        = bool
  default     = false
}

variable "create_elasticache_subnet_route_table" {
  description = "Controls if separate route table for elasticache should be created"
  type        = bool
  default     = false
}

variable "create_database_subnet_group" {
  description = "Controls if database subnet group should be created"
  type        = bool
  default     = true
}

variable "create_elasticache_subnet_group" {
  description = "Controls if elasticache subnet group should be created"
  type        = bool
  default     = true
}

variable "create_redshift_subnet_group" {
  description = "Controls if redshift subnet group should be created"
  type        = bool
  default     = true
}

variable "create_database_internet_gateway_route" {
  description = "Controls if an internet gateway route for public database access should be created"
  type        = bool
  default     = false
}

variable "create_database_nat_gateway_route" {
  description = "Controls if a nat gateway route should be created to give internet access to the database subnets"
  type        = bool
  default     = false
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_classiclink" {
  description = "Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = bool
  default     = null
}

variable "enable_classiclink_dns_support" {
  description = "Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = bool
  default     = null
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
  default     = false
}

variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type        = bool
  default     = false
}

variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
  default     = []
}

variable "enable_dynamodb_endpoint" {
  description = "Should be true if you want to provision a DynamoDB endpoint to the VPC"
  type        = bool
  default     = false
}

variable "dynamodb_vpc_endpoint_suffix" {
  description = "Suffix to append to a DynamoDB VPC Endpoint name"
  type        = string
  default     = "dynamodb-vpc-endpoint"
}

variable "enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  type        = bool
  default     = false
}

variable "s3_vpc_endpoint_suffix" {
  description = "Suffix to append to a S3 VPC Endpoint name"
  type        = string
  default     = "s3-vpc-endpoint"
}

variable "enable_codebuild_endpoint" {
  description = "Should be true if you want to provision an Codebuild endpoint to the VPC"
  default     = false
}

variable "codebuild_vpc_endpoint_suffix" {
  description = "Suffix to append to a CodeBuild VPC Endpoint name"
  type        = string
  default     = "codebuild-vpc-endpoint"
}

variable "codebuild_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Codebuild endpoint"
  default     = []
}

variable "codebuild_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Codebuilt endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  default     = []
}

variable "codebuild_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Codebuild endpoint"
  default     = false
}

variable "enable_codecommit_endpoint" {
  description = "Should be true if you want to provision an Codecommit endpoint to the VPC"
  default     = false
}

variable "codecommit_vpc_endpoint_suffix" {
  description = "Suffix to append to a CodeCommit VPC Endpoint name"
  type        = string
  default     = "codecommit-vpc-endpoint"
}

variable "codecommit_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Codecommit endpoint"
  default     = []
}

variable "codecommit_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Codecommit endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  default     = []
}

variable "codecommit_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Codecommit endpoint"
  default     = false
}

variable "enable_git_codecommit_endpoint" {
  description = "Should be true if you want to provision an Git Codecommit endpoint to the VPC"
  default     = false
}

variable "git_codecommit_vpc_endpoint_suffix" {
  description = "Suffix to append to a Git CodeCommit VPC Endpoint name"
  type        = string
  default     = "git-codecommit-vpc-endpoint"
}

variable "git_codecommit_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Git Codecommit endpoint"
  default     = []
}

variable "git_codecommit_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Git Codecommit endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  default     = []
}

variable "git_codecommit_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Git Codecommit endpoint"
  default     = false
}

variable "enable_config_endpoint" {
  description = "Should be true if you want to provision an config endpoint to the VPC"
  default     = false
}

variable "config_vpc_endpoint_suffix" {
  description = "Suffix to append to a Config VPC Endpoint name"
  type        = string
  default     = "config-vpc-endpoint"
}

variable "config_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for config endpoint"
  default     = []
}

variable "config_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for config endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  default     = []
}

variable "config_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for config endpoint"
  default     = false
}

variable "enable_sqs_endpoint" {
  description = "Should be true if you want to provision an SQS endpoint to the VPC"
  default     = false
}

variable "sqs_vpc_endpoint_suffix" {
  description = "Suffix to append to a SQS VPC Endpoint name"
  type        = string
  default     = "sqs-vpc-endpoint"
}

variable "sqs_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for SQS endpoint"
  default     = []
}

variable "sqs_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for SQS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  default     = []
}

variable "sqs_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for SQS endpoint"
  default     = false
}

variable "enable_ssm_endpoint" {
  description = "Should be true if you want to provision an SSM endpoint to the VPC"
  type        = bool
  default     = false
}

variable "ssm_vpc_endpoint_suffix" {
  description = "Suffix to append to a SSM VPC Endpoint name"
  type        = string
  default     = "ssm-vpc-endpoint"
}

variable "ssm_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for SSM endpoint"
  type        = list(string)
  default     = []
}

variable "ssm_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for SSM endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "ssm_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for SSM endpoint"
  type        = bool
  default     = false
}

variable "enable_secretsmanager_endpoint" {
  description = "Should be true if you want to provision an Secrets Manager endpoint to the VPC"
  type        = bool
  default     = false
}

variable "secretsmanager_vpc_endpoint_suffix" {
  description = "Suffix to append to a Secrets Manager VPC Endpoint name"
  type        = string
  default     = "secretsmanager-vpc-endpoint"
}

variable "secretsmanager_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Secrets Manager endpoint"
  type        = list(string)
  default     = []
}

variable "secretsmanager_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Secrets Manager endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "secretsmanager_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Secrets Manager endpoint"
  type        = bool
  default     = false
}

variable "enable_apigw_endpoint" {
  description = "Should be true if you want to provision an API Gateway endpoint to the VPC"
  type        = bool
  default     = false
}

variable "apigw_vpc_endpoint_suffix" {
  description = "Suffix to append to a API Gateway VPC Endpoint name"
  type        = string
  default     = "api-gateway-vpc-endpoint"
}

variable "apigw_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for API GW  endpoint"
  type        = list(string)
  default     = []
}

variable "apigw_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for API GW endpoint"
  type        = bool
  default     = false
}

variable "apigw_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for API GW endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "enable_ssmmessages_endpoint" {
  description = "Should be true if you want to provision an SSM Messages endpoint to the VPC"
  type        = bool
  default     = false
}

variable "ssmmessages_vpc_endpoint_suffix" {
  description = "Suffix to append to a SSM Messages Endpoint name"
  type        = string
  default     = "ssm-messages-vpc-endpoint"
}

variable "ssmmessages_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for SSM Messages endpoint"
  type        = list(string)
  default     = []
}

variable "ssmmessages_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for SSM Messages endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "ssmmessages_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for SSM Messages endpoint"
  type        = bool
  default     = false
}

variable "enable_transferserver_endpoint" {
  description = "Should be true if you want to provision a Transfer Server endpoint to the VPC"
  type        = bool
  default     = false
}

variable "transferserver_vpc_endpoint_suffix" {
  description = "Suffix to append to a Transfer Server Endpoint name"
  type        = string
  default     = "transferserver-vpc-endpoint"
}

variable "transferserver_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Transfer Server endpoint"
  type        = list(string)
  default     = []
}

variable "transferserver_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Transfer Server endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "transferserver_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Transfer Server endpoint"
  type        = bool
  default     = false
}

variable "enable_ec2_endpoint" {
  description = "Should be true if you want to provision an EC2 endpoint to the VPC"
  type        = bool
  default     = false
}

variable "ec2_vpc_endpoint_suffix" {
  description = "Suffix to append to a EC2 Endpoint name"
  type        = string
  default     = "ec2-vpc-endpoint"
}

variable "ec2_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for EC2 endpoint"
  type        = list(string)
  default     = []
}

variable "ec2_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for EC2 endpoint"
  type        = bool
  default     = false
}

variable "ec2_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for EC2 endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "enable_ec2messages_endpoint" {
  description = "Should be true if you want to provision an EC2 Messages endpoint to the VPC"
  type        = bool
  default     = false
}

variable "ec2messages_vpc_endpoint_suffix" {
  description = "Suffix to append to a EC2 Messages Endpoint name"
  type        = string
  default     = "ec2messages-vpc-endpoint"
}

variable "ec2messages_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for EC2 Messages endpoint"
  type        = list(string)
  default     = []
}

variable "ec2messages_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for EC2 Messages endpoint"
  type        = bool
  default     = false
}

variable "ec2messages_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for EC2 Messages endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "enable_ecr_api_endpoint" {
  description = "Should be true if you want to provision an ECR API endpoint to the VPC"
  type        = bool
  default     = false
}

variable "ecr_api_vpc_endpoint_suffix" {
  description = "Suffix to append to a ECR API Endpoint name"
  type        = string
  default     = "ecr-api-vpc-endpoint"
}

variable "ecr_api_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for ECR API endpoint. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "ecr_api_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for ECR API endpoint"
  type        = bool
  default     = false
}

variable "ecr_api_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for ECR API endpoint"
  type        = list(string)
  default     = []
}

variable "enable_ecr_dkr_endpoint" {
  description = "Should be true if you want to provision an ECR DKR endpoint to the VPC"
  type        = bool
  default     = false
}

variable "ecr_dkr_vpc_endpoint_suffix" {
  description = "Suffix to append to a ECR DKR Endpoint name"
  type        = string
  default     = "ecr-dkr-vpc-endpoint"
}

variable "ecr_dkr_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for ECR DKR endpoint. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "ecr_dkr_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for ECR DKR endpoint"
  type        = bool
  default     = false
}

variable "ecr_dkr_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for ECR DKR endpoint"
  type        = list(string)
  default     = []
}

variable "enable_kms_endpoint" {
  description = "Should be true if you want to provision a KMS endpoint to the VPC"
  type        = bool
  default     = false
}

variable "kms_vpc_endpoint_suffix" {
  description = "Suffix to append to a KMS Endpoint name"
  type        = string
  default     = "kms-vpc-endpoint"
}

variable "kms_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for KMS endpoint"
  type        = list(string)
  default     = []
}

variable "kms_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for KMS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "kms_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for KMS endpoint"
  type        = bool
  default     = false
}

variable "enable_ecs_endpoint" {
  description = "Should be true if you want to provision a ECS endpoint to the VPC"
  type        = bool
  default     = false
}

variable "ecs_vpc_endpoint_suffix" {
  description = "Suffix to append to a ECS Endpoint name"
  type        = string
  default     = "ecs-vpc-endpoint"
}

variable "ecs_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for ECS endpoint"
  type        = list(string)
  default     = []
}

variable "ecs_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for ECS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "ecs_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for ECS endpoint"
  type        = bool
  default     = false
}

variable "enable_ecs_agent_endpoint" {
  description = "Should be true if you want to provision a ECS Agent endpoint to the VPC"
  type        = bool
  default     = false
}

variable "ecs_agent_vpc_endpoint_suffix" {
  description = "Suffix to append to a ECS Agent Endpoint name"
  type        = string
  default     = "ecs-agent-vpc-endpoint"
}

variable "ecs_agent_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for ECS Agent endpoint"
  type        = list(string)
  default     = []
}

variable "ecs_agent_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for ECS Agent endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "ecs_agent_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for ECS Agent endpoint"
  type        = bool
  default     = false
}

variable "enable_ecs_telemetry_endpoint" {
  description = "Should be true if you want to provision a ECS Telemetry endpoint to the VPC"
  type        = bool
  default     = false
}

variable "ecs_telemetry_vpc_endpoint_suffix" {
  description = "Suffix to append to a ECS Telemetry Endpoint name"
  type        = string
  default     = "ecs-telemetry-vpc-endpoint"
}

variable "ecs_telemetry_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for ECS Telemetry endpoint"
  type        = list(string)
  default     = []
}

variable "ecs_telemetry_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for ECS Telemetry endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "ecs_telemetry_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for ECS Telemetry endpoint"
  type        = bool
  default     = false
}

variable "enable_sns_endpoint" {
  description = "Should be true if you want to provision a SNS endpoint to the VPC"
  type        = bool
  default     = false
}

variable "sns_vpc_endpoint_suffix" {
  description = "Suffix to append to a SNS Endpoint name"
  type        = string
  default     = "sns-vpc-endpoint"
}

variable "sns_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for SNS endpoint"
  type        = list(string)
  default     = []
}

variable "sns_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for SNS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "sns_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for SNS endpoint"
  type        = bool
  default     = false
}

variable "enable_monitoring_endpoint" {
  description = "Should be true if you want to provision a CloudWatch Monitoring endpoint to the VPC"
  type        = bool
  default     = false
}

variable "monitoring_vpc_endpoint_suffix" {
  description = "Suffix to append to a CloudWatch Monitoring Endpoint name"
  type        = string
  default     = "monitoring-vpc-endpoint"
}

variable "monitoring_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for CloudWatch Monitoring endpoint"
  type        = list(string)
  default     = []
}

variable "monitoring_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for CloudWatch Monitoring endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "monitoring_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Monitoring endpoint"
  type        = bool
  default     = false
}

variable "enable_elasticloadbalancing_endpoint" {
  description = "Should be true if you want to provision an Elastic Load Balancing endpoint to the VPC"
  type        = bool
  default     = false
}

variable "elasticloadbalancing_vpc_endpoint_suffix" {
  description = "Suffix to append to an Elastic Load Balancing Endpoint name"
  type        = string
  default     = "elasticloadbalancing-vpc-endpoint"
}

variable "elasticloadbalancing_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Elastic Load Balancing endpoint"
  type        = list(string)
  default     = []
}

variable "elasticloadbalancing_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Elastic Load Balancing endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "elasticloadbalancing_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Elastic Load Balancing endpoint"
  type        = bool
  default     = false
}

variable "enable_events_endpoint" {
  description = "Should be true if you want to provision a CloudWatch Events endpoint to the VPC"
  type        = bool
  default     = false
}

variable "events_vpc_endpoint_suffix" {
  description = "Suffix to append to a CloudWatch Events Endpoint name"
  type        = string
  default     = "events-vpc-endpoint"
}

variable "events_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for CloudWatch Events endpoint"
  type        = list(string)
  default     = []
}

variable "events_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for CloudWatch Events endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "events_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Events endpoint"
  type        = bool
  default     = false
}

variable "enable_logs_endpoint" {
  description = "Should be true if you want to provision a CloudWatch Logs endpoint to the VPC"
  type        = bool
  default     = false
}

variable "logs_vpc_endpoint_suffix" {
  description = "Suffix to append to a CloudWatch Logs Endpoint name"
  type        = string
  default     = "logs-vpc-endpoint"
}

variable "logs_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for CloudWatch Logs endpoint"
  type        = list(string)
  default     = []
}

variable "logs_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for CloudWatch Logs endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "logs_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Logs endpoint"
  type        = bool
  default     = false
}

variable "enable_cloudtrail_endpoint" {
  description = "Should be true if you want to provision a CloudTrail endpoint to the VPC"
  type        = bool
  default     = false
}

variable "cloudtrail_vpc_endpoint_suffix" {
  description = "Suffix to append to a CloudTrail Endpoint name"
  type        = string
  default     = "cloudtrail-vpc-endpoint"
}

variable "cloudtrail_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for CloudTrail endpoint"
  type        = list(string)
  default     = []
}

variable "cloudtrail_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for CloudTrail endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "cloudtrail_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for CloudTrail endpoint"
  type        = bool
  default     = false
}

variable "enable_kinesis_streams_endpoint" {
  description = "Should be true if you want to provision a Kinesis Streams endpoint to the VPC"
  type        = bool
  default     = false
}

variable "kinesis_streams_vpc_endpoint_suffix" {
  description = "Suffix to append to a Kinesis Streams Endpoint name"
  type        = string
  default     = "kinesis-streams-vpc-endpoint"
}

variable "kinesis_streams_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Kinesis Streams endpoint"
  type        = list(string)
  default     = []
}

variable "kinesis_streams_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Kinesis Streams endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "kinesis_streams_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Kinesis Streams endpoint"
  type        = bool
  default     = false
}

variable "enable_kinesis_firehose_endpoint" {
  description = "Should be true if you want to provision a Kinesis Firehose endpoint to the VPC"
  type        = bool
  default     = false
}

variable "kinesis_firehose_vpc_endpoint_suffix" {
  description = "Suffix to append to a Kinesis Firehose Endpoint name"
  type        = string
  default     = "firehose-streams-vpc-endpoint"
}

variable "kinesis_firehose_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Kinesis Firehose endpoint"
  type        = list(string)
  default     = []
}

variable "kinesis_firehose_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Kinesis Firehose endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "kinesis_firehose_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Kinesis Firehose endpoint"
  type        = bool
  default     = false
}

variable "enable_glue_endpoint" {
  description = "Should be true if you want to provision a Glue endpoint to the VPC"
  type        = bool
  default     = false
}

variable "glue_vpc_endpoint_suffix" {
  description = "Suffix to append to a Glue Endpoint name"
  type        = string
  default     = "glue-vpc-endpoint"
}

variable "glue_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Glue endpoint"
  type        = list(string)
  default     = []
}

variable "glue_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Glue endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "glue_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Glue endpoint"
  type        = bool
  default     = false
}

variable "enable_sagemaker_notebook_endpoint" {
  description = "Should be true if you want to provision a Sagemaker Notebook endpoint to the VPC"
  type        = bool
  default     = false
}

variable "sagemaker_notebook_vpc_endpoint_suffix" {
  description = "Suffix to append to a Sagemaker Notebook Endpoint name"
  type        = string
  default     = "sagemaker-notebooks-vpc-endpoint"
}

variable "sagemaker_notebook_endpoint_region" {
  description = "Region to use for Sagemaker Notebook endpoint"
  type        = string
  default     = ""
}

variable "sagemaker_notebook_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Sagemaker Notebook endpoint"
  type        = list(string)
  default     = []
}

variable "sagemaker_notebook_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Sagemaker Notebook endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "sagemaker_notebook_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Sagemaker Notebook endpoint"
  type        = bool
  default     = false
}

variable "enable_sts_endpoint" {
  description = "Should be true if you want to provision a STS endpoint to the VPC"
  type        = bool
  default     = false
}

variable "sts_vpc_endpoint_suffix" {
  description = "Suffix to append to a STS Endpoint name"
  type        = string
  default     = "sts-vpc-endpoint"
}

variable "sts_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for STS endpoint"
  type        = list(string)
  default     = []
}

variable "sts_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for STS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "sts_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for STS endpoint"
  type        = bool
  default     = false
}

variable "enable_cloudformation_endpoint" {
  description = "Should be true if you want to provision a Cloudformation endpoint to the VPC"
  type        = bool
  default     = false
}

variable "cloudformation_vpc_endpoint_suffix" {
  description = "Suffix to append to a Cloudformation Endpoint name"
  type        = string
  default     = "cloudformation-vpc-endpoint"
}

variable "cloudformation_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Cloudformation endpoint"
  type        = list(string)
  default     = []
}

variable "cloudformation_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Cloudformation endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "cloudformation_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Cloudformation endpoint"
  type        = bool
  default     = false
}

variable "enable_codepipeline_endpoint" {
  description = "Should be true if you want to provision a CodePipeline endpoint to the VPC"
  type        = bool
  default     = false
}

variable "codepipeline_vpc_endpoint_suffix" {
  description = "Suffix to append to a CodePipeline Endpoint name"
  type        = string
  default     = "codepipeline-vpc-endpoint"
}

variable "codepipeline_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for CodePipeline endpoint"
  type        = list(string)
  default     = []
}

variable "codepipeline_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for CodePipeline endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "codepipeline_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for CodePipeline endpoint"
  type        = bool
  default     = false
}
variable "enable_appmesh_envoy_management_endpoint" {
  description = "Should be true if you want to provision a AppMesh endpoint to the VPC"
  type        = bool
  default     = false
}

variable "appmesh_envoy_management_vpc_endpoint_suffix" {
  description = "Suffix to append to a AppMesh Endpoint name"
  type        = string
  default     = "appmesh-vpc-endpoint"
}

variable "appmesh_envoy_management_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for AppMesh endpoint"
  type        = list(string)
  default     = []
}

variable "appmesh_envoy_management_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for AppMesh endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "appmesh_envoy_management_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for AppMesh endpoint"
  type        = bool
  default     = false
}
variable "enable_servicecatalog_endpoint" {
  description = "Should be true if you want to provision a Service Catalog endpoint to the VPC"
  type        = bool
  default     = false
}

variable "servicecatalog_vpc_endpoint_suffix" {
  description = "Suffix to append to a Service Catalog Endpoint name"
  type        = string
  default     = "service-catalog-vpc-endpoint"
}

variable "servicecatalog_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Service Catalog endpoint"
  type        = list(string)
  default     = []
}

variable "servicecatalog_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Service Catalog endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "servicecatalog_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Service Catalog endpoint"
  type        = bool
  default     = false
}
variable "enable_storagegateway_endpoint" {
  description = "Should be true if you want to provision a Storage Gateway endpoint to the VPC"
  type        = bool
  default     = false
}

variable "storagegateway_vpc_endpoint_suffix" {
  description = "Suffix to append to a Storage Gateway Endpoint name"
  type        = string
  default     = "storage-gateway-vpc-endpoint"
}

variable "storagegateway_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Storage Gateway endpoint"
  type        = list(string)
  default     = []
}

variable "storagegateway_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Storage Gateway endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "storagegateway_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Storage Gateway endpoint"
  type        = bool
  default     = false
}
variable "enable_transfer_endpoint" {
  description = "Should be true if you want to provision a Transfer endpoint to the VPC"
  type        = bool
  default     = false
}

variable "transfer_vpc_endpoint_suffix" {
  description = "Suffix to append to a Transfer Endpoint name"
  type        = string
  default     = "transfer-vpc-endpoint"
}

variable "transfer_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Transfer endpoint"
  type        = list(string)
  default     = []
}

variable "transfer_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Transfer endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "transfer_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Transfer endpoint"
  type        = bool
  default     = false
}
variable "enable_sagemaker_api_endpoint" {
  description = "Should be true if you want to provision a SageMaker API endpoint to the VPC"
  type        = bool
  default     = false
}

variable "sagemaker_api_vpc_endpoint_suffix" {
  description = "Suffix to append to a Sagemaker API endpoint name"
  type        = string
  default     = "sagemaker-api-vpc-endpoint"
}

variable "sagemaker_api_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for SageMaker API endpoint"
  type        = list(string)
  default     = []
}

variable "sagemaker_api_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for SageMaker API endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "sagemaker_api_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for SageMaker API endpoint"
  type        = bool
  default     = false
}
variable "enable_sagemaker_runtime_endpoint" {
  description = "Should be true if you want to provision a SageMaker Runtime endpoint to the VPC"
  type        = bool
  default     = false
}

variable "sagemaker_runtime_vpc_endpoint_suffix" {
  description = "Suffix to append to a Sagemaker Runtime endpoint name"
  type        = string
  default     = "sagemaker-runtime-vpc-endpoint"
}

variable "sagemaker_runtime_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for SageMaker Runtime endpoint"
  type        = list(string)
  default     = []
}

variable "sagemaker_runtime_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for SageMaker Runtime endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "sagemaker_runtime_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for SageMaker Runtime endpoint"
  type        = bool
  default     = false
}

variable "enable_appstream_endpoint" {
  description = "Should be true if you want to provision a AppStream endpoint to the VPC"
  type        = bool
  default     = false
}

variable "appstream_vpc_endpoint_suffix" {
  description = "Suffix to append to a AppStream endpoint name"
  type        = string
  default     = "appstream-vpc-endpoint"
}

variable "appstream_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for AppStream endpoint"
  type        = list(string)
  default     = []
}

variable "appstream_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for AppStream endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "appstream_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for AppStream endpoint"
  type        = bool
  default     = false
}

variable "enable_athena_endpoint" {
  description = "Should be true if you want to provision a Athena endpoint to the VPC"
  type        = bool
  default     = false
}

variable "athena_vpc_endpoint_suffix" {
  description = "Suffix to append to Athena endpoint name"
  type        = string
  default     = "athena-vpc-endpoint"
}

variable "athena_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Athena endpoint"
  type        = list(string)
  default     = []
}

variable "athena_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Athena endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "athena_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Athena endpoint"
  type        = bool
  default     = false
}

variable "enable_rekognition_endpoint" {
  description = "Should be true if you want to provision a Rekognition endpoint to the VPC"
  type        = bool
  default     = false
}

variable "rekognition_vpc_endpoint_suffix" {
  description = "Suffix to append to Rekognition endpoint name"
  type        = string
  default     = "rekognition-vpc-endpoint"
}

variable "rekognition_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Rekognition endpoint"
  type        = list(string)
  default     = []
}

variable "rekognition_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Rekognition endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "rekognition_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Rekognition endpoint"
  type        = bool
  default     = false
}

variable "enable_efs_endpoint" {
  description = "Should be true if you want to provision an EFS endpoint to the VPC"
  type        = bool
  default     = false
}

variable "efs_vpc_endpoint_suffix" {
  description = "Suffix to append to EFS endpoint name"
  type        = string
  default     = "efs-vpc-endpoint"
}

variable "efs_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for EFS endpoint"
  type        = list(string)
  default     = []
}

variable "efs_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for EFS endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "efs_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for EFS endpoint"
  type        = bool
  default     = false
}

variable "enable_cloud_directory_endpoint" {
  description = "Should be true if you want to provision an Cloud Directory endpoint to the VPC"
  type        = bool
  default     = false
}

variable "cloud_directory_vpc_endpoint_suffix" {
  description = "Suffix to append to a Cloud Directory endpoint name"
  type        = string
  default     = "cloud-directory-vpc-endpoint"
}

variable "cloud_directory_endpoint_security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface for Cloud Directory endpoint"
  type        = list(string)
  default     = []
}

variable "cloud_directory_endpoint_subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for Cloud Directory endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used."
  type        = list(string)
  default     = []
}

variable "cloud_directory_endpoint_private_dns_enabled" {
  description = "Whether or not to associate a private hosted zone with the specified VPC for Cloud Directory endpoint"
  type        = bool
  default     = false
}


variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = true
}

variable "customer_gateways" {
  description = "Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address)"
  type        = map(map(any))
  default     = {}
}

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  type        = bool
  default     = false
}

variable "vpn_gateway_id" {
  description = "ID of VPN Gateway to attach to the VPC"
  default     = ""
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN."
  default     = "64512"
}

variable "vpn_gateway_az" {
  description = "The Availability Zone for the VPN Gateway"
  type        = string
  default     = null
}

variable "propagate_intra_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "propagate_private_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "propagate_public_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "public_route_table_tags" {
  description = "Additional tags for the public route tables"
  type        = map(string)
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  type        = map(string)
  default     = {}
}

variable "database_route_table_tags" {
  description = "Additional tags for the database route tables"
  type        = map(string)
  default     = {}
}

variable "redshift_route_table_tags" {
  description = "Additional tags for the redshift route tables"
  type        = map(string)
  default     = {}
}

variable "elasticache_route_table_tags" {
  description = "Additional tags for the elasticache route tables"
  type        = map(string)
  default     = {}
}

variable "intra_route_table_tags" {
  description = "Additional tags for the intra route tables"
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags for the database subnets"
  type        = map(string)
  default     = {}
}

variable "database_subnet_group_tags" {
  description = "Additional tags for the database subnet group"
  type        = map(string)
  default     = {}
}

variable "redshift_subnet_tags" {
  description = "Additional tags for the redshift subnets"
  type        = map(string)
  default     = {}
}

variable "redshift_subnet_group_tags" {
  description = "Additional tags for the redshift subnet group"
  type        = map(string)
  default     = {}
}

variable "elasticache_subnet_tags" {
  description = "Additional tags for the elasticache subnets"
  type        = map(string)
  default     = {}
}

variable "intra_subnet_tags" {
  description = "Additional tags for the intra subnets"
  type        = map(string)
  default     = {}
}

variable "public_acl_tags" {
  description = "Additional tags for the public subnets network ACL"
  type        = map(string)
  default     = {}
}

variable "private_acl_tags" {
  description = "Additional tags for the private subnets network ACL"
  type        = map(string)
  default     = {}
}

variable "intra_acl_tags" {
  description = "Additional tags for the intra subnets network ACL"
  type        = map(string)
  default     = {}
}

variable "database_acl_tags" {
  description = "Additional tags for the database subnets network ACL"
  type        = map(string)
  default     = {}
}

variable "redshift_acl_tags" {
  description = "Additional tags for the redshift subnets network ACL"
  type        = map(string)
  default     = {}
}

variable "elasticache_acl_tags" {
  description = "Additional tags for the elasticache subnets network ACL"
  type        = map(string)
  default     = {}
}

variable "dhcp_options_tags" {
  description = "Additional tags for the DHCP option set (requires enable_dhcp_options set to true)"
  type        = map(string)
  default     = {}
}

variable "nat_gateway_tags" {
  description = "Additional tags for the NAT gateways"
  type        = map(string)
  default     = {}
}

variable "nat_eip_tags" {
  description = "Additional tags for the NAT EIP"
  type        = map(string)
  default     = {}
}

variable "customer_gateway_tags" {
  description = "Additional tags for the Customer Gateway"
  type        = map(string)
  default     = {}
}

variable "vpn_gateway_tags" {
  description = "Additional tags for the VPN gateway"
  type        = map(string)
  default     = {}
}

variable "vpc_endpoint_tags" {
  description = "Additional tags for the VPC Endpoints"
  type        = map(string)
  default     = {}
}

variable "vpc_flow_log_tags" {
  description = "Additional tags for the VPC Flow Logs"
  type        = map(string)
  default     = {}
}

variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "manage_default_vpc" {
  description = "Should be true to adopt and manage Default VPC"
  type        = bool
  default     = false
}

variable "default_vpc_name" {
  description = "Name to be used on the Default VPC"
  type        = string
  default     = ""
}

variable "default_vpc_enable_dns_support" {
  description = "Should be true to enable DNS support in the Default VPC"
  type        = bool
  default     = true
}

variable "default_vpc_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the Default VPC"
  type        = bool
  default     = false
}

variable "default_vpc_enable_classiclink" {
  description = "Should be true to enable ClassicLink in the Default VPC"
  type        = bool
  default     = false
}

variable "default_vpc_tags" {
  description = "Additional tags for the Default VPC"
  type        = map(string)
  default     = {}
}

variable "manage_default_network_acl" {
  description = "Should be true to adopt and manage Default Network ACL"
  type        = bool
  default     = false
}

variable "default_network_acl_name" {
  description = "Name to be used on the Default Network ACL"
  type        = string
  default     = ""
}

variable "default_network_acl_tags" {
  description = "Additional tags for the Default Network ACL"
  type        = map(string)
  default     = {}
}

variable "public_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for public subnets"
  type        = bool
  default     = false
}

variable "private_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for private subnets"
  type        = bool
  default     = false
}

variable "intra_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for intra subnets"
  type        = bool
  default     = false
}

variable "database_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for database subnets"
  type        = bool
  default     = false
}

variable "redshift_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for redshift subnets"
  type        = bool
  default     = false
}

variable "elasticache_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for elasticache subnets"
  type        = bool
  default     = false
}

variable "default_network_acl_ingress" {
  description = "List of maps of ingress rules to set on the Default Network ACL"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}

variable "default_network_acl_egress" {
  description = "List of maps of egress rules to set on the Default Network ACL"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}

variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_inbound_acl_rules" {
  description = "Private subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_outbound_acl_rules" {
  description = "Private subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "intra_inbound_acl_rules" {
  description = "Intra subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "intra_outbound_acl_rules" {
  description = "Intra subnets outbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "database_inbound_acl_rules" {
  description = "Database subnets inbound network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "database_outbound_acl_rules" {
  description = "Database subnets outbound network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "redshift_inbound_acl_rules" {
  description = "Redshift subnets inbound network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "redshift_outbound_acl_rules" {
  description = "Redshift subnets outbound network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "elasticache_inbound_acl_rules" {
  description = "Elasticache subnets inbound network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "elasticache_outbound_acl_rules" {
  description = "Elasticache subnets outbound network ACL rules"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "Whether to create CloudWatch log group for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "Whether to create IAM role for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL."
  type        = string
  default     = "ALL"
}

variable "flow_log_destination_type" {
  description = "Type of flow log destination. Can be s3 or cloud-watch-logs."
  type        = string
  default     = "cloud-watch-logs"
}

variable "flow_log_log_format" {
  description = "The fields to include in the flow log record, in the order in which they should appear."
  type        = string
  default     = null
}

variable "flow_log_destination_arn" {
  description = "The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create_flow_log_cloudwatch_log_group is set to false this argument must be provided."
  type        = string
  default     = ""
}

variable "flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When flow_log_destination_arn is set to ARN of Cloudwatch Logs, this argument needs to be provided."
  type        = string
  default     = ""
}

variable "flow_log_cloudwatch_log_group_name_prefix" {
  description = "Specifies the name prefix of CloudWatch Log Group for VPC flow logs."
  type        = string
  default     = "/aws/vpc-flow-log/"
}

variable "flow_log_cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group for VPC flow logs."
  type        = number
  default     = null
}

variable "flow_log_cloudwatch_log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data for VPC flow logs."
  type        = string
  default     = null
}
