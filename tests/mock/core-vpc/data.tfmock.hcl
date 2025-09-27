mock_resource "aws_vpc" {
    defaults = {
        id                          = "vpc-12345678"
        arn                         = "arn:aws:ec2:ap-southeast-3:123456789012:vpc/vpc-12345678"
        cidr_block                  = "10.0.0.0/16"
        instance_tenancy            = "default"
        enable_dns_support          = true
        enable_dns_hostnames        = true
        main_route_table_id         = "rtb-12345678"
        default_network_acl_id      = "acl-12345678"
        default_security_group_id   = "sg-12345678"
        default_route_table_id      = "rtb-12345678"
        ipv6_association_id         = null
        ipv6_cidr_block             = null
        assign_generated_ipv6_cidr_block = false
    }
}


mock_resource "aws_vpc_dhcp_options" {
    defaults = {
        id                   = "dopt-12345678"
        domain_name          = "service.consul"
        domain_name_servers  = ["127.0.0.1", "10.10.0.2"]
    }
}

mock_resource "aws_vpc_dhcp_options_association" {
    defaults = {
        id              = "doptassoc-123"
        dhcp_options_id = "dopt-12345678"
        vpc_id          = "vpc-12345678"
    }
}