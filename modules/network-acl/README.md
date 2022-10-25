# AWS VPC Network ACL Terraform sub-module

Terraform sub-module which creates VPC Network ACL resources on AWS.

## Usage

```hcl
module "nacl" {
  source = "terraform-aws-modules/vpc/aws//modules/network-acl"

  vpc_id     = "vpc-12345678"
  subnet_ids = [ "subnet-100500abc100500ab" ]

  tags = {
    Name = "NACL-name"
  }

  inbound_acl_rules = [
    {
      rule_number = 900
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
  ]

  outbound_acl_rules = [
    {
      rule_number = 900
      rule_action = "allow"
      from_port   = 32768
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
```

## Examples

- [Network-ACL](../../examples/network-acl) with dedicated network ACL module.
