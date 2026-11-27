# VPC with explicit IPv4 CIDR and IPv6 IPAM

This example creates a dual-stack VPC with a fixed IPv4 CIDR and an exact
IPv6 `/56` from an existing AWS IPAM pool. It also creates two public
subnets, each with an IPv4 `/24` and an IPv6 `/64`.

Provision an IPv6 pool and make the selected `/56` available for allocation
before running this example. The pool must have a locale matching `region`.
For public BYOIP space, provision the CIDR in IPAM outside this example.
Supply the pool ID and `/56` through Terraform variables or a local
`terraform.tfvars` file.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

Run `terraform destroy` when the example is no longer needed.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../.. | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ipv6_cidr"></a> [ipv6\_cidr](#input\_ipv6\_cidr) | Exact IPv6 /56 to allocate to the VPC from the IPAM pool | `string` | n/a | yes |
| <a name="input_ipv6_ipam_pool_id"></a> [ipv6\_ipam\_pool\_id](#input\_ipv6\_ipam\_pool\_id) | ID of an existing IPv6 IPAM pool with the requested CIDR | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region containing the IPv6 IPAM pool | `string` | `"us-west-2"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | IPv4 CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
| <a name="output_vpc_ipv6_cidr_block"></a> [vpc\_ipv6\_cidr\_block](#output\_vpc\_ipv6\_cidr\_block) | IPv6 CIDR block of the VPC |
<!-- END_TF_DOCS -->
