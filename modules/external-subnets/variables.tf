variable "create" {
  description = "Determines whether resources will be created"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
  default     = null
}

variable "vgw_id" {
  description = "The ID of the VPN Gateway"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
  default     = {}
}

variable "external_subnets" {
  description = "A map of list external subnets inside the VPC"
  type        = map(any)
  default     = {}
}

variable "propagate_external_route_tables_vgw" {
  description = "Should be true if you want route table propagation at external network created outside of vpc module."
  type        = bool
  default     = true
}

variable "single_nat_external" {
  description = "Create single gateway NAT in VPC for external subnets, false provide multiple az gateways"
  type        = bool
  default     = true
}
