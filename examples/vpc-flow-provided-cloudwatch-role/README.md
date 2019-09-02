# VPC Flow Logs provided IAM role for CloudWatch

Configuration in this directory creates set of VPC resources with VPC FLow Logs enabled and configured to push the logs to CloudWatch using a provided (ie. pre-existing) IAM role.
This configuration requires that the IAM role is already created before enabling the VPC FLow Logs because otherwise terraform will complain about a count attribute being computed.
This is because the conditional logic that determines if a new IAM role should be created is dependent on the ARN string being empty, which cannot be determined before the actual role is created.
To that end, we can leverage terraform targeted plans to first create the role, and then the VPC with Flow Logs enabled.
A realist scenario for this is to have the IAM role created in a separate configuration (different layer or even account) and read in via terraform remote state.

One way to avoid this issue would be the introduction of new boolean arguments that control the creation logic, but that would add at least two more boolean arguments that users need to set correctly.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform apply -target aws_iam_role.vpc_flow_log_cloudwatch
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
| private\_subnets | List of IDs of private subnets |
| public\_subnets | List of IDs of public subnets |
| vpc\_cidr\_block | The CIDR block of the VPC |
| vpc\_id | The ID of the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
