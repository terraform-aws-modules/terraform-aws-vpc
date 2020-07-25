# Simple VPC with Network ACLs

Configuration in this directory creates set of VPC resources along with network ACLs for several subnets.

Network ACL rules for inbound and outbound traffic are defined as the following:
1. Public and elasticache subnets will have network ACL rules provided
1. Private subnets will be associated with the default network ACL rules (IPV4-only ingress and egress is open for all)

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

No requirements.

## Providers

No provider.

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| default\_network\_acl\_id | The ID of the default network ACL |
| elasticache\_network\_acl\_arn | ARN of the elasticache network ACL |
| elasticache\_network\_acl\_id | ID of the elasticache network ACL |
| module\_vpc | Module VPC |
| nat\_public\_ips | List of public Elastic IPs created for AWS NAT Gateway |
| private\_network\_acl\_arn | ARN of the private network ACL |
| private\_network\_acl\_id | ID of the private network ACL |
| private\_subnets | List of IDs of private subnets |
| public\_network\_acl\_arn | ARN of the public network ACL |
| public\_network\_acl\_id | ID of the public network ACL |
| public\_subnets | List of IDs of public subnets |
| vpc\_cidr\_block | The CIDR block of the VPC |
| vpc\_id | The ID of the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
