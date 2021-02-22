# VPC with enabled VPC flow log to S3 and CloudWatch logs

Configuration in this directory creates a set of VPC resources with VPC Flow Logs enabled in different configurations:

1. `cloud-watch-logs.tf` - Push logs to a new AWS CloudWatch Log group.
1. `cloud-watch-logs.tf` - Push logs to an existing AWS CloudWatch Log group using existing IAM role (created outside of this module).
1. `s3.tf` - Push logs to an existing S3 bucket (created outside of this module).

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
| aws | >= 2.70 |
| random | >= 2 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70 |
| random | >= 2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| s3_bucket | terraform-aws-modules/s3-bucket/aws | ~> 1.0 |
| vpc_with_flow_logs_cloudwatch_logs | ../../ |  |
| vpc_with_flow_logs_cloudwatch_logs_default | ../../ |  |
| vpc_with_flow_logs_s3_bucket | ../../ |  |

## Resources

| Name |
|------|
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/2.70/docs/resources/cloudwatch_log_group) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/2.70/docs/data-sources/iam_policy_document) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/2.70/docs/resources/iam_policy) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/2.70/docs/resources/iam_role_policy_attachment) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/2.70/docs/resources/iam_role) |
| [random_pet](https://registry.terraform.io/providers/hashicorp/random/2/docs/resources/pet) |

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_destination\_arn | The ARN of the destination for VPC Flow Logs |
| vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_destination\_type | The type of the destination for VPC Flow Logs |
| vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_id | The ID of the Flow Log resource |
| vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_cloudwatch\_iam\_role\_arn | The ARN of the IAM role used when pushing logs to Cloudwatch log group |
| vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_destination\_arn | The ARN of the destination for VPC Flow Logs |
| vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_destination\_type | The type of the destination for VPC Flow Logs |
| vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_id | The ID of the Flow Log resource |
| vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_cloudwatch\_iam\_role\_arn | The ARN of the IAM role used when pushing logs to Cloudwatch log group |
| vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_destination\_arn | The ARN of the destination for VPC Flow Logs |
| vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_destination\_type | The type of the destination for VPC Flow Logs |
| vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_id | The ID of the Flow Log resource |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
