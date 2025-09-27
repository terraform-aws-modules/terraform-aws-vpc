// Core VPC + DHCP test
mock_provider "aws" {
    alias = "mocked"
    source = "./tests/mock/core-vpc"
}

run "run_module_plan" {
    command = plan
    providers = {
        aws = aws.mocked
    }
    module {
        source = "./tests/setup"
    }
}
