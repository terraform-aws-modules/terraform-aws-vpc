# Issue 108 - VPC

Configuration in this directory creates set of VPC resources to cover issues reported on GitHub:

* https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/108#issue-308084655
* https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/102#issuecomment-374877706
* https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/44#issuecomment-378679404

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

No provider.

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| database\_subnets | List of IDs of database subnets |
| elasticache\_subnets | List of IDs of elasticache subnets |
| nat\_public\_ips | List of public Elastic IPs created for AWS NAT Gateway |
| private\_subnets | List of IDs of private subnets |
| public\_subnets | List of IDs of public subnets |
| vpc\_id | The ID of the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
