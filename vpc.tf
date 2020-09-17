resource "aws_vpc" "AWS_Training" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Gabor Training TF"
  }
}
