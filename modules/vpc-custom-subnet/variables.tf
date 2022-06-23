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

variable "tags" {
  type = object({
    Maintener = string
    Author    = string
  })
  description = "Define general tags"
}

variable "custom_subnets" {
  type        = list(any)
  description = "Define custom subnets"
  default     = []
}

variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
  default     = null
}