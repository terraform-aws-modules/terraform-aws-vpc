variable "acl_name" {
  description = "Name to be used on the Network ACL."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for the Default Network ACL."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC where network acl are created."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnets where Network ACL are attached."
  type        = list(string)
  default     = []
}
variable "inbound_acl_rules" {
  description = "External subnets inbound network ACLs"
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

variable "outbound_acl_rules" {
  description = "External subnets outbound network ACLs"
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
