# Simple HUB & Spoke VPC with TGW
This example creates two VPCs one being the HUB with associated TGW / Public / Private & single AZ NAT Gateway. 

The second VPC is a spoke VPC which routes all external traffic out to the TGW.
 
Spoke VPC doesn't require public subnet(s), egress is via TGW.

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
