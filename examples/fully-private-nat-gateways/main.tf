locals {
  tgw_id = "tgw-12345678"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach" {
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = local.tgw_id
  vpc_id             = module.vpc.vpc_id
}

module "vpc" {
  source = "../.."

  cidr                  = "10.247.84.0/22"
  secondary_cidr_blocks = ["100.120.0.0/16"]

  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]

  create_igw                                 = false
  nat_gateway_connectivity_type              = "private"
  nat_gateway_private_ips                    = ["10.247.84.122", "10.247.85.204", "10.247.86.117"]
  nat_gateway_secondary_private_ip_addresses = [["10.247.84.133"], ["10.247.85.79", "10.247.85.66"], ["10.247.86.64", "10.247.86.47", "10.247.86.181"]]

  # You can automatically set the number of secondary private IPs for the NAT Gateways, that is a conflicting argument with nat_gateway_secondary_private_ip_addresses
  # nat_gateway_secondary_private_ip_address_count = [1, 2, 3]

  # In this scenario the NAT gateways are created inside public subnets without an igw in the routes.
  public_subnets = ["10.247.84.0/24", "10.247.85.0/24", "10.247.86.0/24"]

  # The private subnets are using a range of IPs that belongs to the non routable IP range
  private_subnets = ["100.120.4.0/22", "100.120.8.0/22", "100.120.12.0/22"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

}
