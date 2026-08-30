variable "vpc_tag_name" {
  description = "Value of the `Name` tag on the existing VPC to add subnets to"
  type        = string
  default     = null

  validation {
    condition     = var.vpc_tag_name != null
    error_message = "`vpc_tag_name` is required. This pattern adds subnets to a VPC that already exists."
  }
}
