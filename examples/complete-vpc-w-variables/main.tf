provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

module "vpc" {
  # More details about source are on https://www.terraform.io/docs/modules/sources.html
  # source = "../../"
  # source = "${var.module_vpc_source}"
  # we could not use variable for source :(
  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git"

  name = "${var.deployment_name}"

  cidr = "${local.l_sidr}"

  # azs                 = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  azs                 = "${var.ap-southeast-1_azs}"
  # private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets     = "${local.l_private_subnets}"
  # public_subnets      = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  public_subnets      = "${local.l_public_subnets}"
  # database_subnets    = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  database_subnets    = "${local.l_database_subnets}"
  # elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
  elasticache_subnets = "${local.l_elasticache_subnets}"
  # redshift_subnets    = ["10.0.41.0/24", "10.0.42.0/24", "10.0.43.0/24"]
  redshift_subnets    = "${local.l_redshift_subnets}"
  # intra_subnets       = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]
  intra_subnets       = "${local.l_intra_subnets}"

  create_database_subnet_group = "${var.create_database_subnet_group}"

  enable_nat_gateway = "${var.enable_nat_gateway}"
  single_nat_gateway = "${var.single_nat_gateway}"

  enable_vpn_gateway = "${var.enable_vpn_gateway}"

  enable_s3_endpoint       = "${var.enable_s3_endpoint}"
  enable_dynamodb_endpoint = "${var.enable_dynamodb_endpoint}"

  enable_dhcp_options              = "${var.enable_dhcp_options}"
  dhcp_options_domain_name         = "${var.dhcp_options_domain_name}"
  dhcp_options_domain_name_servers = "${local.l_dhcp_options_domain_name_servers}"

  tags = {
    # Owner       = "user"
    Owner       = "${var.vpc_user_name}"
    # Environment = "QA"
    Environment = "${var.environment}"
    # Name        = "${var.deployment_name}-complete"
    Name        = "${var.environment}-${var.ip_2nd_octet}-${var.deployment_name}"
  }
}
