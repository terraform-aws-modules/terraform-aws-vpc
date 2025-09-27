// Subnets group test
mock_provider "aws" {
    alias = "mocked"
    source = "./tests/mock/subnets"
}

run "subnets" {
    providers = { aws = aws.mocked }

    assert {
        condition     = length(aws_subnet.public.*.id) == 2
        error_message = "Should have 2 public subnets"
    }
    assert {
        condition     = length(aws_subnet.private.*.id) == 2
        error_message = "Should have 2 private subnets"
    }

    assert {
        condition     = length(aws_subnet.database.*.id) == 2
        error_message = "Should have 2 database subnets"
    }

    assert {
        condition     = length(aws_subnet.elasticache.*.id) == 2
        error_message = "Should have 2 elasticache subnets"
    }

    assert {
        condition     = length(aws_subnet.redshift.*.id) == 2
        error_message = "Should have 2 redshift subnets"
    }

    assert {
        condition     = length(aws_subnet.intra.*.id) == 2
        error_message = "Should have 2 intra subnets"
    }

    assert {
        condition     = length(aws_subnet.outpost.*.id) == 0
        error_message = "Should have 0 outpost subnets"
    }

    assert {
        condition = alltrue([
            for subnet in aws_subnet.public : subnet.vpc_id == aws_vpc.this[0].id
        ])
        error_message = "Public Subnet is not associated with the correct VPC"
    }

    # assert {
    #     condition     = aws_subnet.this[1].cidr_block == "10.0.2.0/24"
    #     error_message = "Second subnet CIDR block does not match expected value"
    # }

    # assert {
    #     condition     = aws_subnet.this[2].cidr_block == "10.0.3.0/24"
    #     error_message = "Third subnet CIDR block does not match expected value"
    # }
}
