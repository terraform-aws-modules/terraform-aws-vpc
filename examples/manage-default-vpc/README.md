# Manage Default VPC

Configuration in this directory does not create new VPC resources, but it adopts [Default VPC](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/default-vpc.html) created by AWS to allow management of it using Terraform.

This is not usual type of resource in Terraform, so use it carefully. More information is [here](https://www.terraform.io/docs/providers/aws/r/default_vpc.html).

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.

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
| default\_vpc\_cidr\_block | The CIDR block of the VPC |
| default\_vpc\_id | The ID of the Default VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
