#####################################
provider "aws" {
    region = "ap-south-1"
    version = "~> 2.0"
    allowed_account_ids = ["44444444444"]
    profile = "testuser"
}

#terraform {
#  backend "s3" {}
#  required_version = "= 0.11.11"
#}

module "vpc" {
    source = "../../"

    name = "rabbani-terraform"
    cidr = "172.35.0.0/16"

    tags = {
        Owner       = "devops"
        Environment = "production"
        Terraform   = "true"
        User        = "rabbani-test"
    }


    azs = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]

    generic_public_subnets = [
        {
            cidr_block = "172.35.240.0/24",
            avlzone = "ap-south-1a",
            tag_suffix = "public_prd"
            route_table_name = "public"
        },
        {
            cidr_block = "172.35.241.0/24",
            avlzone = "ap-south-1b",
            tag_suffix = "public_prd"
            route_table_name = "public"
        },
        {
            cidr_block = "172.35.242.0/24",
            avlzone = "ap-south-1c",
            tag_suffix = "public_prd"
            route_table_name = "public"
        },
    ]

    generic_private_subnets = [
        {
            cidr_block = "172.35.230.0/24",
            avlzone = "ap-south-1a",
            subnets_suffix = "database"
            route_table_name = "private_1a"
        },
        {
            cidr_block = "172.35.231.0/24",
            avlzone = "ap-south-1b",
            subnets_suffix = "database"
            route_table_name = "private_1b"
        },
        {
            cidr_block = "172.35.232.0/24",
            avlzone = "ap-south-1c",
            subnets_suffix = "database"
            route_table_name = "private_1c"
        },
        {
            cidr_block = "172.35.220.0/24",
            avlzone = "ap-south-1a",
            subnets_suffix = "elk"
            route_table_name = "private_1a"
        },
        {
            cidr_block = "172.35.221.0/24",
            avlzone = "ap-south-1b",
            subnets_suffix = "elk"
            route_table_name = "private_1b"
        },
        {
            cidr_block = "172.35.222.0/24",
            avlzone = "ap-south-1c",
            subnets_suffix = "elk"
            route_table_name = "private_1c"
        },
    ]

    enable_nat_gateway = true
    single_nat_gateway = false

    reuse_nat_ips = false
#    external_nat_ip_ids = ["2.34.5.612", "56.34.12.89", "90.12.1.3"]

}
