variable "create" {
  description = "Determines whether resources will be created"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
  default     = null
}

variable "endpoints" {
  description = "A map of interface and/or gateway endpoints containing their properties and configurations"
  type        = any
  default     = {}
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
  type        = any
  default     = {}
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
}
