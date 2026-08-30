variable "local_zone" {
  description = "Name of an enabled Local Zone, for example `us-west-2-lax-1a`"
  type        = string
  default     = null

  # without this the subnet would be created in an ordinary availability zone chosen by
  # AWS, which looks like success and is not a Local Zone at all
  validation {
    condition     = var.local_zone != null
    error_message = "`local_zone` is required. This pattern needs a Local Zone you have opted into."
  }
}

variable "local_zone_network_border_group" {
  description = "Network border group the Local Zone's Elastic IPs must come from, for example `us-west-2-lax-1`"
  type        = string
  default     = null
}
