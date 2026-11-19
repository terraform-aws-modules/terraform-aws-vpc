variable "region" {
  description = "AWS Region containing the IPv6 IPAM pool"
  type        = string
  default     = "us-west-2"
}

variable "ipv6_ipam_pool_id" {
  description = "ID of an existing IPv6 IPAM pool with the requested CIDR"
  type        = string
}

variable "ipv6_cidr" {
  description = "Exact IPv6 /56 to allocate to the VPC from the IPAM pool"
  type        = string
}
