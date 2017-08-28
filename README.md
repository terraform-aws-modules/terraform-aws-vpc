AWS VPC Terraform module
========================

Terraform module which creates VPC resources on AWS.

Usage
-----

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"

  cidr            = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]

  tags {
    Terraform = "true"
    Environment = "dev"
  }
}
```

Authors
=======

Migrated from `terraform-community-modules/tf_aws_vpc`, where it was maintained by [these awesome contributors](https://github.com/terraform-community-modules/tf_aws_vpc/graphs/contributors).
Module managed by [Anton Babenko](https://github.com/antonbabenko).

License
=======

Apache 2 Licensed. See LICENSE for full details.