variable "name" {
  description = "VPC name"
  type        = string
  default     = "example-vpc"
}
variable "region" {
  description = "region name"
  type        = string
  default     = "eu-west-1"
}
variable "vpc_cidr" {
  description = "vpc_cidr"
  type        = string
  default     = "10.0.0.0/16"
}


