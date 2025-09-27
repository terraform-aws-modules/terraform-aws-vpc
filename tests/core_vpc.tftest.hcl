// Core VPC + DHCP test
mock_provider "aws" {
    alias = "mocked"
    source = "./tests/mock/core-vpc"
}

run "vpc" {
    providers = {
        aws = aws.mocked
    }
    
    assert {
        condition     = aws_vpc.this[0].id == "vpc-12345678"
        error_message = "VPC ID does not match expected value"
    }

    assert {
        condition     = aws_vpc.this[0].cidr_block == var.vpc_cidr
        error_message = "VPC CIDR block does not match expected value"
    }

    assert {
        condition     = aws_vpc.this[0].instance_tenancy == var.vpc_instance_tenancy
        error_message = "VPC instance tenancy does not match expected value"
    }

    assert {
        condition     = aws_vpc.this[0].enable_dns_support == var.vpc_enable_dns_support
        error_message = "VPC DNS support setting does not match expected value"
    }

    assert {
        condition     = aws_vpc.this[0].enable_dns_hostnames == var.vpc_enable_dns_hostnames
        error_message = "VPC DNS hostnames setting does not match expected value"
    }

    assert {
        condition     = (
            aws_vpc.this[0].assign_generated_ipv6_cidr_block == var.vpc_assign_generated_ipv6_cidr_block
            || (
            aws_vpc.this[0].assign_generated_ipv6_cidr_block == null
            && var.vpc_assign_generated_ipv6_cidr_block == false
            )
        )
        error_message = "VPC IPv6 assignment setting does not match expected value"
    }
}

run "dhcp_options" {
    providers = {
        aws = aws.mocked
    }

    assert {
        condition     = aws_vpc_dhcp_options.this[0].id == "dopt-12345678"
        error_message = "DHCP Options ID does not match expected value"
    }

    assert {
        condition     = tolist(aws_vpc_dhcp_options.this[0].domain_name_servers) == tolist(var.dhcp_options_domain_name_servers)
        error_message = "DHCP Options domain-name-servers does not match expected value"
    }

    assert {
        condition     = aws_vpc_dhcp_options_association.this[0].dhcp_options_id == aws_vpc_dhcp_options.this[0].id
        error_message = "DHCP Options Association does not reference the DHCP Options resource"
    }
}

