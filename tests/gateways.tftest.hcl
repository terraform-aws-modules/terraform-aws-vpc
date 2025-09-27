// Internet / Egress Gateways & NAT test
mock_provider "aws" {
    alias = "mocked"
    source = "./tests/mock/gateways"
}

run "gateways" {
    providers = { aws = aws.mocked }

    assert {
        condition     = aws_internet_gateway.this[0].id == "igw-12345678"
        error_message = "Internet Gateway ID does not match expected value"
    }

    assert {
        condition     = length(aws_egress_only_internet_gateway.this) == 0
        error_message = "Egress Only Internet Gateway should not be created"
    }

    assert {
        condition     = length(aws_eip.nat) >= 1
        error_message = "At least one EIP for NAT should be created"
    }

    assert {
        condition     = aws_eip.nat[0].public_ip == var.expected_nat_ip
        error_message = "EIP public IP does not match expected value"
    }

    assert {
        condition     = length(aws_nat_gateway.this) >= 1
        error_message = "At least one NAT Gateway should be created"
    }

    assert {
        condition     = aws_nat_gateway.this[0].allocation_id == aws_eip.nat[0].id
        error_message = "NAT Gateway does not reference the expected EIP allocation"
    }
}