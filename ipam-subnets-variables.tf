################################################################################
# VPC IPAM Pool for Subnets
################################################################################

variable "create_vpc_ipam_pool" {
  description = "Controls if an IPAM pool should be created for VPC subnet allocation"
  type        = bool
  default     = false
}

variable "vpc_ipam_pool_name" {
  description = "Name of the VPC IPAM pool. If not provided, defaults to '<vpc-name>-vpc-subnets'"
  type        = string
  default     = null
}

variable "vpc_ipam_pool_description" {
  description = "Description of the VPC IPAM pool"
  type        = string
  default     = null
}

variable "vpc_ipam_scope_id" {
  description = "The ID of the IPAM scope where the VPC pool will be created"
  type        = string
  default     = null
}

variable "vpc_ipam_pool_locale" {
  description = "The locale (AWS region) for the IPAM pool. This is where the pool can allocate IPs and must match the VPC's region. Defaults to the region of the VPC"
  type        = string
  default     = null
}

variable "vpc_ipam_pool_region" {
  description = "The AWS region where IPAM pool resources should be created. This should be where your IPAM is located (e.g., eu-west-1). If not specified, uses the provider's default region"
  type        = string
  default     = null
}

variable "vpc_ipam_pool_aws_profile" {
  description = "AWS CLI profile to use for IPAM pool and RAM share creation. Required when IPAM is in a different AWS account than the default provider. If not specified, uses the default AWS credentials"
  type        = string
  default     = ""
}

variable "vpc_aws_profile" {
  description = "AWS CLI profile to use for VPC and subnet operations. Required when VPC is in a different AWS account than the default provider. If not specified, uses the default AWS credentials"
  type        = string
  default     = ""
}

variable "vpc_ipam_source_pool_id" {
  description = "The ID of the source IPAM pool from which to allocate CIDRs. Required if creating a VPC IPAM pool"
  type        = string
  default     = null
}

variable "vpc_ipam_pool_cidr" {
  description = "The CIDR to provision to the VPC IPAM pool. If not provided, will use the VPC's CIDR (either from var.cidr or allocated from IPAM)"
  type        = string
  default     = null
}

variable "vpc_ipam_pool_allocation_default_netmask_length" {
  description = "The default netmask length for allocations from this pool"
  type        = number
  default     = null
}

variable "vpc_ipam_pool_allocation_max_netmask_length" {
  description = "The maximum netmask length that can be allocated from this pool"
  type        = number
  default     = null
}

variable "vpc_ipam_pool_allocation_min_netmask_length" {
  description = "The minimum netmask length that can be allocated from this pool"
  type        = number
  default     = null
}

variable "vpc_ipam_pool_auto_import" {
  description = "If enabled, IPAM will continuously look for resources within the CIDR range of this pool and automatically import them as allocations"
  type        = bool
  default     = true
}

variable "vpc_ipam_pool_tags" {
  description = "Additional tags for the VPC IPAM pool"
  type        = map(string)
  default     = {}
}

################################################################################
# RAM Share for VPC IPAM Pool
################################################################################

variable "vpc_ipam_pool_ram_share_enabled" {
  description = "Controls if the VPC IPAM pool should be shared via AWS RAM"
  type        = bool
  default     = false
}

variable "vpc_ipam_pool_ram_share_name" {
  description = "Name of the RAM resource share. If not provided, defaults to '<vpc-name>-ipam-pool-share'"
  type        = string
  default     = null
}

variable "vpc_ipam_pool_ram_share_principals" {
  description = "List of principals (AWS account IDs, Organization ARNs, or OU ARNs) to share the IPAM pool with"
  type        = list(string)
  default     = []
}

variable "vpc_ipam_pool_ram_share_allow_external_principals" {
  description = "Whether to allow sharing with principals outside of your organization"
  type        = bool
  default     = false
}

variable "vpc_ipam_pool_ram_share_tags" {
  description = "Additional tags for the RAM resource share"
  type        = map(string)
  default     = {}
}

################################################################################
# IPAM-based Subnets (Workaround using null_resource)
################################################################################

variable "ipam_subnets" {
  description = <<-EOT
    List of subnets to create using IPAM pool allocation. Each subnet should have:
    - name: Name tag for the subnet
    - availability_zone: AZ where the subnet will be created
    - netmask_length: The netmask length for the subnet (e.g., 24 for /24)
    - tags: (Optional) Additional tags for the subnet
    - aws_profile: (Optional) AWS CLI profile to use for subnet creation
    
    Example:
    [
      {
        name              = "ipam-subnet-1"
        availability_zone = "eu-west-2a"
        netmask_length    = 28
        tags              = { Environment = "dev" }
      }
    ]
  EOT
  type = list(object({
    name              = string
    availability_zone = string
    netmask_length    = number
    tags              = optional(map(string), {})
    aws_profile       = optional(string, "")
  }))
  default = []
}
