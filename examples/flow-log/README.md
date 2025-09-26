# AWS Flow Logs to S3 and CloudWatch logs

Configuration in this directory creates a set of VPC resources with VPC Flow Logs enabled in different configurations:

- Flow log to CloudWatch logs using module created CloudWatch log group and IAM role
- Flow log to CloudWatch logs using external CloudWatch log group and IAM role
- Flow log to S3 bucket in text format
- Flow log to S3 bucket in Parquet format

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_disabled"></a> [disabled](#module\_disabled) | ../../modules/flow-log | n/a |
| <a name="module_flow_log"></a> [flow\_log](#module\_flow\_log) | ../../modules/flow-log | n/a |
| <a name="module_flow_log_cloudwatch_external"></a> [flow\_log\_cloudwatch\_external](#module\_flow\_log\_cloudwatch\_external) | ../../modules/flow-log | n/a |
| <a name="module_flow_log_s3"></a> [flow\_log\_s3](#module\_flow\_log\_s3) | ../../modules/flow-log | n/a |
| <a name="module_flow_log_s3_parquet"></a> [flow\_log\_s3\_parquet](#module\_flow\_log\_s3\_parquet) | ../../modules/flow-log | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 5.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the Flow Log |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of CloudWatch log group created |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of CloudWatch log group created |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Flow Log |
<!-- END_TF_DOCS -->
