variable "region" {
  type    = string
  default = "eu-west-1"
}
variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "private_subnets" {
  type    = list(string)
  default = ["10.99.101.0/24", "10.99.102.0/24", "10.99.103.0/24"]
}
