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
  description = "Name used across the resources created. Each subnet is named `<name>-<key>` unless it sets its own"
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
# Subnets
################################################################################

variable "subnets" {
  description = "Map of subnets to create. The key names the subnet and is the key of every output. A subnet that sets its own `routes` gets its own route table, and one that does not shares the group's"
  type = map(object({
    name                 = optional(string)
    availability_zone    = optional(string)
    availability_zone_id = optional(string)
    ipv4_cidr_block      = optional(string)
    ipv6_cidr_block      = optional(string)
    ipv6_native          = optional(bool)
    create_nat_gateway   = optional(bool)
    tags                 = optional(map(string), {})
    # Tags for this subnet's own route table, when it has one
    route_table_tags = optional(map(string), {})
    # Sharing this subnet through RAM, which is per subnet rather than per group
    share_subnet       = optional(bool)
    resource_share_arn = optional(string)
    # NAT gateway shape, when this subnet hosts one. A private NAT gateway takes no
    # address, and a Local Zone gateway needs one from that zone's border group
    create_eip                    = optional(bool)
    eip_network_border_group      = optional(string)
    nat_gateway_allocation_id     = optional(string)
    nat_gateway_connectivity_type = optional(string)
    routes = optional(map(object({
      destination_ipv4_cidr_block = optional(string)
      destination_ipv6_cidr_block = optional(string)
      destination_prefix_list_id  = optional(string)
      carrier_gateway_id          = optional(string)
      core_network_arn            = optional(string)
      egress_only_gateway_id      = optional(string)
      gateway_id                  = optional(string)
      local_gateway_id            = optional(string)
      nat_gateway_id              = optional(string)
      network_interface_id        = optional(string)
      odb_network_arn             = optional(string)
      transit_gateway_id          = optional(string)
      vpc_endpoint_id             = optional(string)
      vpc_peering_connection_id   = optional(string)
      timeouts = optional(object({
        create = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    })))
  }))
  default  = {}
  nullable = false
}

variable "assign_ipv6_address_on_creation" {
  description = "Specify true to indicate that network interfaces created in the subnets should be assigned an IPv6 address"
  type        = bool
  default     = null
}

variable "enable_dns64" {
  description = "Indicates whether DNS queries made to the Amazon-provided DNS Resolver in these subnets should return synthetic IPv6 addresses for IPv4-only destinations. Needs a `64:ff9b::/96` route to a NAT gateway to be reachable"
  type        = bool
  default     = null
}

variable "enable_resource_name_dns_a_record_on_launch" {
  description = "Indicates whether to respond to DNS queries for instance hostnames with DNS A records"
  type        = bool
  default     = null
}

variable "enable_resource_name_dns_aaaa_record_on_launch" {
  description = "Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records"
  type        = bool
  default     = null
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnets should be assigned a public IP address"
  type        = bool
  default     = null
}

variable "private_dns_hostname_type_on_launch" {
  description = "The type of hostnames to assign to instances in the subnets at launch. Valid values are `ip-name` and `resource-name`"
  type        = string
  default     = null
}

################################################################################
# Route Table
################################################################################

variable "create_route_table" {
  description = "Controls if route table(s) are created for the subnets. Set to `false` and supply `route_table_id` to join a table created elsewhere"
  type        = bool
  default     = true
}

variable "route_table_id" {
  description = "The ID of an existing route table for every subnet to join. Used when `create_route_table` is `false`"
  type        = string
  default     = null
}

variable "routes" {
  description = "Routes shared by every subnet in the group. A subnet that declares its own `routes` overrides these and takes its own route table"
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
    network_interface_id        = optional(string)
    odb_network_arn             = optional(string)
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

variable "route_table_tags" {
  description = "Additional tags for the route table(s)"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# NAT Gateway
################################################################################

variable "share_subnet" {
  description = "Controls if every subnet in the group is shared via RAM. A subnet can override this"
  type        = bool
  default     = false
}

variable "resource_share_arn" {
  description = "ARN of the RAM resource share to associate shared subnets with"
  type        = string
  default     = null
}

variable "create_eip" {
  description = "Controls if an Elastic IP is created for each NAT gateway. A subnet can override this"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Controls if a NAT gateway is created in every subnet of the group. A subnet can override this"
  type        = bool
  default     = false
}

variable "nat_gateway_connectivity_type" {
  description = "Connectivity type for each NAT gateway created in the group. Valid values are `private` or `public`. A subnet can override this"
  type        = string
  default     = null
}

variable "nat_gateway_tags" {
  description = "Additional tags for the NAT gateway(s)"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Network ACL
################################################################################

variable "create_network_acl" {
  description = "Controls if a dedicated network ACL is created for the group. A network ACL is associated with many subnets, so it belongs to the group rather than to any one subnet"
  type        = bool
  default     = false
}

variable "network_acl_id" {
  description = "The ID of an existing network ACL for every subnet to join. Ignored when `create_network_acl` is `true`"
  type        = string
  default     = null
}

variable "network_acl_rules" {
  description = "Map of network ACL rules. Set `egress` to distinguish outbound rules from inbound"
  type = map(object({
    egress          = optional(bool, false)
    rule_number     = number
    rule_action     = string
    protocol        = string
    from_port       = optional(number)
    to_port         = optional(number)
    icmp_code       = optional(number)
    icmp_type       = optional(number)
    cidr_block      = optional(string)
    ipv6_cidr_block = optional(string)
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for r in var.network_acl_rules : contains(["allow", "deny"], r.rule_action)])
    error_message = "`rule_action` must be either `allow` or `deny`."
  }
}

variable "network_acl_tags" {
  description = "Additional tags for the network ACL"
  type        = map(string)
  default     = {}
  nullable    = false
}
