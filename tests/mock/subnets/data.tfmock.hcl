mock_resource "aws_subnet" {
    defaults = {
        id                = "subnet-123"
        arn               = "arn:aws:ec2:ap-southeast-3:123456789012:subnet/subnet-123"
        cidr_block        = "10.0.1.0/24"
        availability_zone = "ap-southeast-3a"
        vpc_id            = "vpc-12345678"
    }
}
