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
| terraform | >= 0.12.21 |
| aws | >= 3.10 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.10 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vpc | ../../ |  |

## Resources

| Name |
|------|
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) |
| [aws_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint) |

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| cgw\_ids | List of IDs of Customer Gateway |
| database\_subnets | List of IDs of database subnets |
| elasticache\_subnets | List of IDs of elasticache subnets |
| intra\_subnets | List of IDs of intra subnets |
| nat\_public\_ips | List of public Elastic IPs created for AWS NAT Gateway |
| private\_subnets | List of IDs of private subnets |
| public\_subnets | List of IDs of public subnets |
| redshift\_subnets | List of IDs of redshift subnets |
| this\_customer\_gateway | Map of Customer Gateway attributes |
| vpc\_endpoint\_lambda\_dns\_entry | The DNS entries for the VPC Endpoint for Lambda. |
| vpc\_endpoint\_lambda\_id | The ID of VPC endpoint for Lambda |
| vpc\_endpoint\_lambda\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for Lambda. |
| vpc\_endpoint\_redshift\_dns\_entry | The DNS entries for the VPC Endpoint for Redshift. |
| vpc\_endpoint\_redshift\_id | The ID of VPC endpoint for Redshift. |
| vpc\_endpoint\_redshift\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for Redhsift. |
| vpc\_endpoint\_ssm\_dns\_entry | The DNS entries for the VPC Endpoint for SSM. |
| vpc\_endpoint\_ssm\_id | The ID of VPC endpoint for SSM |
| vpc\_endpoint\_ssm\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for SSM. |
| vpc\_id | The ID of the VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
