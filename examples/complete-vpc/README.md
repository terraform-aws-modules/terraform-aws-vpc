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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.15 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../ |  |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | ../../modules/vpc-endpoints |  |
| <a name="module_vpc_endpoints_nocreate"></a> [vpc\_endpoints\_nocreate](#module\_vpc\_endpoints\_nocreate) | ../../modules/vpc-endpoints |  |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.dynamodb_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.generic_endpoint_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_vpc_endpoint_service.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cgw_ids"></a> [cgw\_ids](#output\_cgw\_ids) | List of IDs of Customer Gateway |
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | List of IDs of database subnets |
| <a name="output_elasticache_subnets"></a> [elasticache\_subnets](#output\_elasticache\_subnets) | List of IDs of elasticache subnets |
| <a name="output_intra_subnets"></a> [intra\_subnets](#output\_intra\_subnets) | List of IDs of intra subnets |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | List of public Elastic IPs created for AWS NAT Gateway |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of IDs of private subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of IDs of public subnets |
| <a name="output_redshift_subnets"></a> [redshift\_subnets](#output\_redshift\_subnets) | List of IDs of redshift subnets |
| <a name="output_this_customer_gateway"></a> [this\_customer\_gateway](#output\_this\_customer\_gateway) | Map of Customer Gateway attributes |
| <a name="output_vpc_endpoint_lambda_dns_entry"></a> [vpc\_endpoint\_lambda\_dns\_entry](#output\_vpc\_endpoint\_lambda\_dns\_entry) | The DNS entries for the VPC Endpoint for Lambda. |
| <a name="output_vpc_endpoint_lambda_id"></a> [vpc\_endpoint\_lambda\_id](#output\_vpc\_endpoint\_lambda\_id) | The ID of VPC endpoint for Lambda |
| <a name="output_vpc_endpoint_lambda_network_interface_ids"></a> [vpc\_endpoint\_lambda\_network\_interface\_ids](#output\_vpc\_endpoint\_lambda\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Lambda. |
| <a name="output_vpc_endpoint_ssm_dns_entry"></a> [vpc\_endpoint\_ssm\_dns\_entry](#output\_vpc\_endpoint\_ssm\_dns\_entry) | The DNS entries for the VPC Endpoint for SSM. |
| <a name="output_vpc_endpoint_ssm_id"></a> [vpc\_endpoint\_ssm\_id](#output\_vpc\_endpoint\_ssm\_id) | The ID of VPC endpoint for SSM |
| <a name="output_vpc_endpoint_ssm_network_interface_ids"></a> [vpc\_endpoint\_ssm\_network\_interface\_ids](#output\_vpc\_endpoint\_ssm\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for SSM. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
