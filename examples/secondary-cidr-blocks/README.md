# Simple VPC with secondary CIDR blocks

Configuration in this directory creates set of VPC resources across multiple CIDR blocks.

There is a public and private subnet created per availability zone in addition to single NAT Gateway shared between all 3 availability zones.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Outputs

| Name | Description |
|------|-------------|
| nat_public_ips | NAT gateways |
| private_subnets | Subnets |
| public_subnets | List of IDs of public subnets |
| vpc_cidr_block | CIDR blocks |
| vpc_id | VPC |
| vpc_secondary_cidr_blocks | List of secondary CIDR blocks of the VPC |

 <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
