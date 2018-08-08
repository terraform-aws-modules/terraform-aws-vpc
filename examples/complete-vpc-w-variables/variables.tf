variable "aws_access_key" {
  description = "AWS access key."
  default     = "REPLACE_WITH_YOUR_ACCESS_KEY"
}

variable "aws_secret_key" {
  description = "AWS secret key."
  default     = "REPLACE_WITH_YOUR_SECRET_KEY"
}

variable "ip_2nd_octet" {
  description = "Desired second octet of IP range"
  default     = "1"
}

variable "environment" {
  description = "Desired name of Environment"
  default     = "qa"
}

variable "deployment_name" {
  description = "Desired name of Deployment"
  default     = "Complete-VPC-with-variables"
}

variable "vpc_user_name" {
  description = "Desired user name of Deployment"
  default     = "Test User"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-1"
}

# ap-southeast-1 region available zones
variable "ap-southeast-1_azs" {
  description = "A list of availability zones in the region"
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "module_vpc_source" {
  description = "Module's GitHub source"
  default     = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git"
}

# The CIDR block for the VPC. Locals used to avoid "default may not contain interpolations" issue
locals {
  l_sidr = "10.${var.ip_2nd_octet}.0.0/16"
  l_private_subnets = ["10.${var.ip_2nd_octet}.1.0/24", "10.${var.ip_2nd_octet}.2.0/24", "10.${var.ip_2nd_octet}.3.0/24"]
  l_public_subnets = ["10.${var.ip_2nd_octet}.11.0/24", "10.${var.ip_2nd_octet}.12.0/24", "10.${var.ip_2nd_octet}.13.0/24"]
  l_database_subnets = ["10.${var.ip_2nd_octet}.21.0/24", "10.${var.ip_2nd_octet}.22.0/24", "10.${var.ip_2nd_octet}.23.0/24"]
  l_elasticache_subnets = ["10.${var.ip_2nd_octet}.31.0/24", "10.${var.ip_2nd_octet}.32.0/24", "10.${var.ip_2nd_octet}.33.0/24"]
  l_redshift_subnets = ["10.${var.ip_2nd_octet}.41.0/24", "10.${var.ip_2nd_octet}.42.0/24", "10.${var.ip_2nd_octet}.43.0/24"]
  l_intra_subnets = ["10.${var.ip_2nd_octet}.51.0/24", "10.${var.ip_2nd_octet}.52.0/24", "10.${var.ip_2nd_octet}.53.0/24"]
}

variable "create_database_subnet_group" {
  description = "Controls if database subnet group should be created"
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = true
}

variable "enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Should be true if you want to provision a DynamoDB endpoint to the VPC"
  default     = true
}

variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  default     = true
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set"
  default     = "service.consul"
}

locals {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided"
  # type        = "list"
  l_dhcp_options_domain_name_servers = ["127.0.0.1", "10.${var.ip_2nd_octet}.0.2"]
}
