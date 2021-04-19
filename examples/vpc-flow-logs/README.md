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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.15 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.15 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 1.0 |
| <a name="module_vpc_with_flow_logs_cloudwatch_logs"></a> [vpc\_with\_flow\_logs\_cloudwatch\_logs](#module\_vpc\_with\_flow\_logs\_cloudwatch\_logs) | ../../ |  |
| <a name="module_vpc_with_flow_logs_cloudwatch_logs_default"></a> [vpc\_with\_flow\_logs\_cloudwatch\_logs\_default](#module\_vpc\_with\_flow\_logs\_cloudwatch\_logs\_default) | ../../ |  |
| <a name="module_vpc_with_flow_logs_s3_bucket"></a> [vpc\_with\_flow\_logs\_s3\_bucket](#module\_vpc\_with\_flow\_logs\_s3\_bucket) | ../../ |  |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_iam_policy_document.flow_log_cloudwatch_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.flow_log_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_flow_logs_s3_bucket_vpc_flow_log_destination_arn"></a> [vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_destination\_arn](#output\_vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_destination\_arn) | The ARN of the destination for VPC Flow Logs |
| <a name="output_vpc_flow_logs_s3_bucket_vpc_flow_log_destination_type"></a> [vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_destination\_type](#output\_vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_destination\_type) | The type of the destination for VPC Flow Logs |
| <a name="output_vpc_flow_logs_s3_bucket_vpc_flow_log_id"></a> [vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_id](#output\_vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_id) | The ID of the Flow Log resource |
| <a name="output_vpc_with_flow_logs_cloudwatch_logs_default_vpc_flow_log_cloudwatch_iam_role_arn"></a> [vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_cloudwatch\_iam\_role\_arn](#output\_vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_cloudwatch\_iam\_role\_arn) | The ARN of the IAM role used when pushing logs to Cloudwatch log group |
| <a name="output_vpc_with_flow_logs_cloudwatch_logs_default_vpc_flow_log_destination_arn"></a> [vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_destination\_arn](#output\_vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_destination\_arn) | The ARN of the destination for VPC Flow Logs |
| <a name="output_vpc_with_flow_logs_cloudwatch_logs_default_vpc_flow_log_destination_type"></a> [vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_destination\_type](#output\_vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_destination\_type) | The type of the destination for VPC Flow Logs |
| <a name="output_vpc_with_flow_logs_cloudwatch_logs_default_vpc_flow_log_id"></a> [vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_id](#output\_vpc\_with\_flow\_logs\_cloudwatch\_logs\_default\_vpc\_flow\_log\_id) | The ID of the Flow Log resource |
| <a name="output_vpc_with_flow_logs_cloudwatch_logs_vpc_flow_log_cloudwatch_iam_role_arn"></a> [vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_cloudwatch\_iam\_role\_arn](#output\_vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_cloudwatch\_iam\_role\_arn) | The ARN of the IAM role used when pushing logs to Cloudwatch log group |
| <a name="output_vpc_with_flow_logs_cloudwatch_logs_vpc_flow_log_destination_arn"></a> [vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_destination\_arn](#output\_vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_destination\_arn) | The ARN of the destination for VPC Flow Logs |
| <a name="output_vpc_with_flow_logs_cloudwatch_logs_vpc_flow_log_destination_type"></a> [vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_destination\_type](#output\_vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_destination\_type) | The type of the destination for VPC Flow Logs |
| <a name="output_vpc_with_flow_logs_cloudwatch_logs_vpc_flow_log_id"></a> [vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_id](#output\_vpc\_with\_flow\_logs\_cloudwatch\_logs\_vpc\_flow\_log\_id) | The ID of the Flow Log resource |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
