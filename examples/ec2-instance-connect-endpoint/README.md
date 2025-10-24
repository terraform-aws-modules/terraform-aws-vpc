# Example: EC2 Instance Connect Endpoint

This example demonstrates how to enable the EC2 Instance Connect Endpoint feature within the VPC module.

## Usage

```hcl
module "vpc" {
  source = "../../"

  name = "example-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  create_instance_connect_endpoint      = true
  instance_connect_subnet_id            = element(module.vpc.private_subnets, 0)
  instance_connect_security_group_ids   = [aws_security_group.allow_ssh.id]
  instance_connect_preserve_client_ip   = false
}
