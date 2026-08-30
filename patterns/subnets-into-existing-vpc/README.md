# Subnets Into An Existing VPC

Add subnets, route tables and a NAT gateway to a VPC this configuration does not own and
does not manage.

There is no `module "vpc"` here at all. The sub-modules take a `vpc_id` and nothing else,
so a VPC created by another team, another account's Terraform, ClickOps or CloudFormation
works exactly the same.

## Architecture

```
   existing VPC, managed elsewhere        looked up by tag, not created
   ┌──────────────────────────────────────────────────────────────────┐
   │  (existing subnets, untouched)                                   │
   │                                                                  │
   │  NEW  public   → the VPC's existing internet gateway             │
   │  NEW  private  → NAT gateway in the new public subnet            │
   └──────────────────────────────────────────────────────────────────┘
```

The internet gateway is discovered rather than created, because the VPC already has one
and a VPC can only have one attached.

## Why this works

The `subnets` sub-module's only structural input is `vpc_id`. It does not read anything
from the root module, does not assume a tier, and does not assume it is the only thing
creating subnets in that VPC. The same is true of the `subnet` and `route-table`
sub-modules it is built from.

That is the difference between a sub-module and a tier of the root module: a tier exists
inside a VPC the module built, and a sub-module exists inside any VPC at all.

## Requests this answers

- [#1034](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1034) Subnets-only deployment to an existing VPC
- [#1191](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1191) Plan fails unless the VPC is not already deployed

## References

- [Subnets for your VPC](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html)

## Usage

Set `vpc_tag_name` to a VPC that already exists, then:

```bash
$ terraform init && terraform apply
```
