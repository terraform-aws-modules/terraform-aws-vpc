variable "create" {
  description = "Determines whether resources will be created"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The ID of the associated VPC"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the NACL"
  type        = map(string)
  default     = {}
}

variable "inbound_acl_rules" {
  description = "Inbound network ACLs"
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
  description = "Outbound network ACLs"
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

variable "subnet_ids" {
  description = "A list of Subnet IDs to apply the ACL to"
  type        = list(string)
  default     = []
}
