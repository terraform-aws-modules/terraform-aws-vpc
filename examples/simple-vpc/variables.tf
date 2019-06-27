# VPC Name
variable "vpc_name" {
  type    = string
  default = "simple-example"
}

# AZs
variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

# Public Subnet Tags
variable "public_subnet_tags" {
  type = map
  default = {
    Name = "overridden-name-public"
  }
}

# VPC Tags
variable "vpc_tags" {
  type = map
  default = {
    Name = "vpc-name"
  }
}

# Tags
variable "tags" {
  type = map
  default = {
    Owner       = "user"
    Environment = "dev"
  }
}
