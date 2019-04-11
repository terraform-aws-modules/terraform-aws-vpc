# Simple HUB & Spoke VPC with TGW Across AWS Org / OU / Account

This example creates a Cross AWS Account HUB & Spoke using TGW. 

Creates two VPCs one for the HUB and set's up TGW, the second is to attach the TGW. Utilizing [AWS RAM service](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html)

To use AWS RAM across an Organization you need to configure RAM in the master account of the Organization. [Sharing with AWS Organizations](https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html)

This example also uses two providers, one for the HUB account and one for the spoke account. So you'll need to configure the spoke provider accordingly.

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
| azs | A list of availability zones spefified as argument to this module |
| nat\_public\_ips | List of public Elastic IPs created for AWS NAT Gateway |
| hub\_private\_subnets | List of IDs of private subnets in the HUB account |
| hub\_public\_subnets | List of IDs of public subnets in the HUB |
| hub\_vpc\_cidr\_block | The CIDR block of the HUB VPC |
| hub\_vpc\_id | The ID of the HUB VPC |
| tgw\_id | The ID of the TGW |
| spoke\_private\_subnets | List of IDs of private subnets in the Spoke account |
| spoke\_vpc\_cidr\_block | The CIDR block of the Spoke VPC |
| spoke\_vpc\_id | The ID of the Spoke VPC |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
