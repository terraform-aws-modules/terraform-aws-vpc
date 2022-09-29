# AWS VPC External Subnets Terraform sub-module

Terraform sub-module which creates VPC External Subnets resources on AWS.

## Usage

See [`examples`](../../examples) directory for working examples to reference:

```hcl
module "external_subnets" {
  source = "terraform-aws-modules/vpc/aws//modules/external-subnets"

  vpc_id = module.vpc.vpc_id
  vgw_id = module.vpc.vgw_id

  external_subnets = {
    example = {
      subnets = {
        eu-central-1a = "10.0.1.0/24"
        eu-central-1b = "10.0.2.0/24"
        eu-central-1c = "10.0.3.0/24"
      }
    }
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
```

## Examples

- [Complete-VPC](../../examples/external-subnets) with VPC External Subnets.
