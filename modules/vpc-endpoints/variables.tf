variable "create" {
  description = "Determines whether resources will be created"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration. If a value is provided, `service_endpoint` must be specified due to https://github.com/hashicorp/terraform-provider-aws/issues/42462"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
  default     = null
}

variable "endpoints" {
  description = "A map of interface and/or gateway endpoints containing their properties and configurations"
  type = map(object({
    create = optional(bool, true)

    auto_accept = optional(bool)
    dns_options = optional(object({
      dns_record_ip_type                             = optional(string)
      private_dns_only_for_inbound_resolver_endpoint = optional(bool)
    }))
    ip_address_type     = optional(string)
    policy              = optional(string)
    private_dns_enabled = optional(bool)
    route_table_ids     = optional(list(string))
    security_group_ids  = optional(list(string), [])
    service             = optional(string)
    service_endpoint    = optional(string)
    service_name        = optional(string)
    service_region      = optional(string)
    service_type        = optional(string, "Interface")
    subnet_configurations = optional(list(object({
      ipv4      = optional(string)
      ipv6      = optional(string)
      subnet_id = optional(string)
    })), [])
    subnet_ids = optional(list(string), [])
    tags       = optional(map(string), {})
  }))
  default = {}
}

variable "security_group_ids" {
  description = "Default security group IDs to associate with the VPC endpoints"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Default subnets IDs to associate with the VPC endpoints"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting VPC endpoint resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Security Group
################################################################################

variable "create_security_group" {
  description = "Determines if a security group is created"
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name to use on security group created. Conflicts with `security_group_name_prefix`"
  type        = string
  default     = null
}

variable "security_group_name_prefix" {
  description = "Name prefix to use on security group created. Conflicts with `security_group_name`"
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = null
}

variable "security_group_rules" {
  description = "Security group rules to add to the security group created"
  type = map(object({
    cidr_blocks              = optional(list(string))
    description              = optional(string)
    from_port                = optional(number, 443)
    ipv6_cidr_blocks         = optional(list(string))
    prefix_list_ids          = optional(list(string))
    protocol                 = optional(string, "tcp")
    self                     = optional(bool)
    source_security_group_id = optional(string)
    to_port                  = optional(number, 443)
    type                     = optional(string, "ingress")
  }))
  default = {}
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
}
