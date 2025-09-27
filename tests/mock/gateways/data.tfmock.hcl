mock_resource "aws_internet_gateway" {
    defaults = {
        id  = "igw-12345678"
        arn = "arn:aws:ec2:ap-southeast-3:123456789012:internet-gateway/igw-12345678"
    }
}

mock_resource "aws_egress_only_internet_gateway" {
    defaults = {
        id = "eigw-12345678"
    }
}

mock_resource "aws_eip" {
    defaults = {
        id = "eipalloc-12345678"
        public_ip = "203.0.113.10"
    }
}

mock_resource "aws_nat_gateway" {
    defaults = {
        id = "nat-12345678"
        allocation_id = "eipalloc-12345678"
        subnet_id = "subnet-123"
        state = "available"
    }
}
