# Simple VPC

Configuration in this directory creates set of VPC resources which may be sufficient for development environment.

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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| azs |  | list(string) | `[ "eu-west-1a", "eu-west-1b", "eu-west-1c" ]` | no |
| cidr |  | string | `"10.0.0.0/16"` | no |
| private\_subnets |  | list(string) | `[ "10.99.101.0/24", "10.99.102.0/24", "10.99.103.0/24" ]` | no |
| public\_subnets |  | list(string) | `[ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]` | no |
| region |  | string | `"eu-west-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| azs | A list of availability zones spefified as argument to this module |
| nat\_public\_ips | List of public Elastic IPs created for AWS NAT Gateway |
| private\_subnets | List of IDs of private subnets |
| private\_subnets\_cidr\_blocks | List of cidr\_blocks of private subnets |
| public\_subnets | List of IDs of public subnets |
| public\_subnets\_cidr\_blocks | List of cidr\_blocks of public subnets |
| vpc\_cidr\_block | The CIDR block of the VPC |
| vpc\_id | The ID of the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
