# Complete VPC

Configuration in this directory creates set of VPC resources which may be sufficient for staging or production environment (look into [simple-vpc](../simple-vpc) for more simplified setup).

There are public, private, database, ElastiCache, intra (private w/o Internet access) subnets, and NAT Gateways created in each availability zone.

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
| database_subnets | List of IDs of database subnets |
| elasticache_subnets | List of IDs of elasticache subnets |
| intra_subnets | List of IDs of intra subnets |
| nat_public_ips | NAT gateways |
| private_subnets | Subnets |
| public_subnets | List of IDs of public subnets |
| redshift_subnets | List of IDs of redshift subnets |
| vpc_id | VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
