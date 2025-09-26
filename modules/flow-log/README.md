# AWS Flow Log Terraform Module

Terraform module which creates AWS Flow Log resources.

## Usage

See [`examples`](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples) directory for working examples to reference:

### CloudWatch Logs

```hcl
module "flow_log" {
  source = "terraform-aws-modules/vpc/aws//modules/flow-log"

  name   = "example"
  vpc_id = "vpc-12345678"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
```

### S3 Bucket

```hcl
module "flow_log" {
  source = "terraform-aws-modules/vpc/aws//modules/flow-log"

  name   = "example"
  vpc_id = "vpc-12345678"

  log_destination_type = "s3"
  log_destination      = "arn:aws:s3:::example-20250602150510701600000001"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
```

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_class"></a> [cloudwatch\_log\_group\_class](#input\_cloudwatch\_log\_group\_class) | Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS` | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of the created CloudWatch log group | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events. Set to `0` to keep logs indefinitely | `number` | `90` | no |
| <a name="input_cloudwatch_log_group_tags"></a> [cloudwatch\_log\_group\_tags](#input\_cloudwatch\_log\_group\_tags) | Map of additional tags to add to the CloudWatch log group | `map(string)` | `{}` | no |
| <a name="input_cloudwatch_log_group_use_name_prefix"></a> [cloudwatch\_log\_group\_use\_name\_prefix](#input\_cloudwatch\_log\_group\_use\_name\_prefix) | Determines whether the log group name should be used as a prefix | `bool` | `true` | no |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether to create a CloudWatch log group for the Flow Logs | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether the ECS service IAM role should be created | `bool` | `true` | no |
| <a name="input_deliver_cross_account_role"></a> [deliver\_cross\_account\_role](#input\_deliver\_cross\_account\_role) | ARN of the IAM role in the destination account used for cross-account delivery of flow logs | `string` | `null` | no |
| <a name="input_destination_options"></a> [destination\_options](#input\_destination\_options) | Describes the destination options for a flow log | <pre>object({<br/>    file_format                = optional(string)<br/>    hive_compatible_partitions = optional(bool)<br/>    per_hour_partition         = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_eni_id"></a> [eni\_id](#input\_eni\_id) | Elastic Network Interface ID to attach to | `string` | `null` | no |
| <a name="input_flow_log_tags"></a> [flow\_log\_tags](#input\_flow\_log\_tags) | Map of additional tags to add to the flow log | `map(string)` | `{}` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions"></a> [iam\_role\_permissions](#input\_iam\_role\_permissions) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for inline policy permissions | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string, "Allow")<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_trust_policy_permissions"></a> [iam\_role\_trust\_policy\_permissions](#input\_iam\_role\_trust\_policy\_permissions) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom trust policy permissions | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string, "Allow")<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_kinesis_data_firehose_arn"></a> [kinesis\_data\_firehose\_arn](#input\_kinesis\_data\_firehose\_arn) | ARN of the existing Kinesis Data Firehose delivery stream. Required when `log_destination_type` is `kinesis-data-firehose` | `string` | `null` | no |
| <a name="input_log_destination"></a> [log\_destination](#input\_log\_destination) | ARN of the logging destination | `string` | `null` | no |
| <a name="input_log_destination_type"></a> [log\_destination\_type](#input\_log\_destination\_type) | Logging destination type. Valid values: `cloud-watch-logs`, `s3`, `kinesis-data-firehose`. Default: `cloud-watch-logs` | `string` | `"cloud-watch-logs"` | no |
| <a name="input_log_format"></a> [log\_format](#input\_log\_format) | The fields to include in the flow log record | `string` | `null` | no |
| <a name="input_max_aggregation_interval"></a> [max\_aggregation\_interval](#input\_max\_aggregation\_interval) | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds (1 minute) or `600` seconds (10 minutes). Default: `600`. When `transit_gateway_id` or `transit_gateway_attachment_id` is specified, `max_aggregation_interval` must be 60 seconds (1 minute) | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to use across resources created | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID to attach to | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_traffic_type"></a> [traffic\_type](#input\_traffic\_type) | The type of traffic to capture. Valid values: `ACCEPT`, `REJECT`, `ALL` | `string` | `"ALL"` | no |
| <a name="input_transit_gateway_attachment_id"></a> [transit\_gateway\_attachment\_id](#input\_transit\_gateway\_attachment\_id) | Transit Gateway Attachment ID to attach to | `string` | `null` | no |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | Transit Gateway ID to attach to | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to attach to | `string` | `null` | no |

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

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/LICENSE) for full details.
