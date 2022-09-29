# AWS VPC Network ACLs Terraform sub-module

Terraform sub-module which creates VPC Network ACLs resources on AWS.

## Usage

See [`examples`](../../examples) directory for working examples to reference:

```hcl
module "network_acls" {
  source = "terraform-aws-modules/vpc/aws//modules/network-acls"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids

  acl_name = "example"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
```

## Examples

- [Complete-VPC](../../examples/complete-vpc) with VPC Endpoints.
