variable "gwlb_service_name" {
  description = "Name of the Gateway Load Balancer endpoint service fronting the appliance fleet, for example `com.amazonaws.vpce.eu-west-1.vpce-svc-0123456789abcdef0`"
  type        = string
  default     = null

  validation {
    condition     = var.gwlb_service_name != null
    error_message = "`gwlb_service_name` is required. This pattern consumes an appliance fleet that lives outside this configuration."
  }
}
