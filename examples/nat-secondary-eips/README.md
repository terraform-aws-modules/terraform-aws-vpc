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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.30 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../ | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_public_secondary_ips"></a> [nat\_public\_secondary\_ips](#output\_nat\_public\_secondary\_ips) | The secondary public IPs of the NAT gateways |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
 <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
