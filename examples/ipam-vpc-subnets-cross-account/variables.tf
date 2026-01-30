################################################################################
# Account Configuration
################################################################################

variable "networking_account_id" {
  description = "AWS account ID for the networking account (where IPAM resources are created)"
  type        = string
}

variable "application_account_id" {
  description = "AWS account ID for the application account (where VPC and subnets are created)"
  type        = string
}

################################################################################
# General Configuration
################################################################################

variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Example     = "ipam-vpc-subnets-cross-account"
    Description = "Cross-account IPAM with VPC-scoped pools"
  }
}

################################################################################
# IPAM Configuration
################################################################################

variable "top_level_pool_cidr" {
  description = "CIDR block for the top-level IPAM pool in networking account"
  type        = string
  default     = "10.0.0.0/8"
}

variable "allow_external_principals" {
  description = "Allow sharing with external principals (accounts outside the organization)"
  type        = bool
  default     = false
}

################################################################################
# VPC Configuration
################################################################################

variable "vpc_name" {
  description = "Name of the VPC in application account"
  type        = string
  default     = "cross-account-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (must be within top_level_pool_cidr range)"
  type        = string
  default     = "10.0.0.0/16"
}

################################################################################
# IPAM Pool Allocation Constraints
################################################################################

variable "default_netmask_length" {
  description = "Default netmask length for subnet allocation from VPC IPAM pool"
  type        = number
  default     = 24
}

variable "min_netmask_length" {
  description = "Minimum netmask length for subnet allocation from VPC IPAM pool"
  type        = number
  default     = 24
}

variable "max_netmask_length" {
  description = "Maximum netmask length for subnet allocation from VPC IPAM pool"
  type        = number
  default     = 28
}
