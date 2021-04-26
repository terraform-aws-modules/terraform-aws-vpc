# Issues

Configuration in this directory creates set of VPC resources to cover issues reported on GitHub:

- https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/44
- https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/46
- https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/102
- https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/108

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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc_issue_108"></a> [vpc\_issue\_108](#module\_vpc\_issue\_108) | ../../ |  |
| <a name="module_vpc_issue_44"></a> [vpc\_issue\_44](#module\_vpc\_issue\_44) | ../../ |  |
| <a name="module_vpc_issue_46"></a> [vpc\_issue\_46](#module\_vpc\_issue\_46) | ../../ |  |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_issue_108_database_subnets"></a> [issue\_108\_database\_subnets](#output\_issue\_108\_database\_subnets) | List of IDs of database subnets |
| <a name="output_issue_108_elasticache_subnets"></a> [issue\_108\_elasticache\_subnets](#output\_issue\_108\_elasticache\_subnets) | List of IDs of elasticache subnets |
| <a name="output_issue_108_nat_public_ips"></a> [issue\_108\_nat\_public\_ips](#output\_issue\_108\_nat\_public\_ips) | List of public Elastic IPs created for AWS NAT Gateway |
| <a name="output_issue_108_private_subnets"></a> [issue\_108\_private\_subnets](#output\_issue\_108\_private\_subnets) | List of IDs of private subnets |
| <a name="output_issue_108_public_subnets"></a> [issue\_108\_public\_subnets](#output\_issue\_108\_public\_subnets) | List of IDs of public subnets |
| <a name="output_issue_108_vpc_id"></a> [issue\_108\_vpc\_id](#output\_issue\_108\_vpc\_id) | The ID of the VPC |
| <a name="output_issue_44_database_subnets"></a> [issue\_44\_database\_subnets](#output\_issue\_44\_database\_subnets) | List of IDs of database subnets |
| <a name="output_issue_44_elasticache_subnets"></a> [issue\_44\_elasticache\_subnets](#output\_issue\_44\_elasticache\_subnets) | List of IDs of elasticache subnets |
| <a name="output_issue_44_nat_public_ips"></a> [issue\_44\_nat\_public\_ips](#output\_issue\_44\_nat\_public\_ips) | List of public Elastic IPs created for AWS NAT Gateway |
| <a name="output_issue_44_private_subnets"></a> [issue\_44\_private\_subnets](#output\_issue\_44\_private\_subnets) | List of IDs of private subnets |
| <a name="output_issue_44_public_subnets"></a> [issue\_44\_public\_subnets](#output\_issue\_44\_public\_subnets) | List of IDs of public subnets |
| <a name="output_issue_44_vpc_id"></a> [issue\_44\_vpc\_id](#output\_issue\_44\_vpc\_id) | The ID of the VPC |
| <a name="output_issue_46_database_subnets"></a> [issue\_46\_database\_subnets](#output\_issue\_46\_database\_subnets) | List of IDs of database subnets |
| <a name="output_issue_46_elasticache_subnets"></a> [issue\_46\_elasticache\_subnets](#output\_issue\_46\_elasticache\_subnets) | List of IDs of elasticache subnets |
| <a name="output_issue_46_nat_public_ips"></a> [issue\_46\_nat\_public\_ips](#output\_issue\_46\_nat\_public\_ips) | List of public Elastic IPs created for AWS NAT Gateway |
| <a name="output_issue_46_private_subnets"></a> [issue\_46\_private\_subnets](#output\_issue\_46\_private\_subnets) | List of IDs of private subnets |
| <a name="output_issue_46_public_subnets"></a> [issue\_46\_public\_subnets](#output\_issue\_46\_public\_subnets) | List of IDs of public subnets |
| <a name="output_issue_46_vpc_id"></a> [issue\_46\_vpc\_id](#output\_issue\_46\_vpc\_id) | The ID of the VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
