# Edge Case Topologies

Configuration in this directory creates VPCs in shapes that have caused problems in the past,
and exists to keep them working:

- **Asymmetrical subnets** - a different number of subnets in each tier
- **No private subnets** - an empty private tier with other tiers still defined
- **Overlapping public subnets** - adjacent small public subnets sharing one NAT gateway

Each is linked to the issue that prompted it in `main.tf`.

## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

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
| <a name="module_asymmetrical_subnets"></a> [asymmetrical\_subnets](#module\_asymmetrical\_subnets) | ../../ | n/a |
| <a name="module_disabled"></a> [disabled](#module\_disabled) | ../../ | n/a |
| <a name="module_no_private_subnets"></a> [no\_private\_subnets](#module\_no\_private\_subnets) | ../../ | n/a |
| <a name="module_overlapping_public_subnets"></a> [overlapping\_public\_subnets](#module\_overlapping\_public\_subnets) | ../../ | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
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
<!-- END_TF_DOCS -->
