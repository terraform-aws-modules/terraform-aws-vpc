variable "create" {
  description = "Controls if resources should be created"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "name" {
  description = "Name used across the resources created"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC the resources are created within"
  type        = string
  default     = null
}

################################################################################
# Route Table
################################################################################

variable "timeouts" {
  description = "Create, update, and delete timeout configurations for the route table"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "route_table_tags" {
  description = "Additional tags for the route table"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Routes
################################################################################

variable "routes" {
  description = "Map of route definitions to create"
  type = map(object({
    destination_ipv4_cidr_block = optional(string)
    destination_ipv6_cidr_block = optional(string)
    destination_prefix_list_id  = optional(string)
    carrier_gateway_id          = optional(string)
    core_network_arn            = optional(string)
    egress_only_gateway_id      = optional(string)
    gateway_id                  = optional(string)
    local_gateway_id            = optional(string)
    nat_gateway_id              = optional(string)
    odb_network_arn             = optional(string)
    network_interface_id        = optional(string)
    transit_gateway_id          = optional(string)
    vpc_endpoint_id             = optional(string)
    vpc_peering_connection_id   = optional(string)
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default  = {}
  nullable = false
}

variable "route_timeouts" {
  description = "Default create, update, and delete timeout configurations for routes"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

################################################################################
# Gateway Association
################################################################################

variable "create_gateway_association" {
  description = "Controls if the route table is associated with the gateway given by `gateway_id`. A separate toggle rather than deriving it from `gateway_id`, because that ID is normally a computed value and would leave the count unknown at plan time"
  type        = bool
  default     = false
}

variable "gateway_id" {
  description = "The ID of an internet gateway or virtual private gateway to associate the route table with. Leave unset for a plain route table to be shared across subnets"
  type        = string
  default     = null
}

variable "route_table_association_timeouts" {
  description = "Create, update, and delete timeout configurations for the gateway association"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
