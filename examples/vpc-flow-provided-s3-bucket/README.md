# VPC Flow Logs provided S3 bucket

Configuration in this directory creates set of VPC resources with VPC FLow Logs enabled and configured to push the logs to S3 using a provided (ie. pre-existing) bucket.
This configuration requires that the S3 bucket is already created before enabling the VPC FLow Logs because otherwise terraform will complain about a count attribute being computed.
This is because the conditional logic that determines if a new S3 bucket (or CloudWatch log group) should be created is dependent on the log destination ARN string being empty, which cannot be determined before the actual role is created.
To that end, we can leverage terraform targeted plans to first create the S3 bucket, and then the VPC with Flow Logs enabled.
A realist scenario for this is to have the S3 bucket created in a separate configuration (different layer or even account) and read in via terraform remote state.

One way to avoid this issue would be the introduction of new boolean arguments that control the creation logic, but that would add at least two more boolean arguments that users need to set correctly.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform apply -target aws_s3_bucket.vpf_flow_log
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Outputs

| Name | Description |
|------|-------------|
| vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_destination\_arn | The ARN of the destination for VPC Flow Logs |
| vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_destination\_type | The type of the destination for VPC Flow Logs |
| vpc\_flow\_logs\_s3\_bucket\_vpc\_flow\_log\_id | The ID of the Flow Log resource |
| vpc\_with\_flow\_logs\_to\_cloudwatch\_logs\_default\_vpc\_flow\_log\_destination\_arn | The ARN of the destination for VPC Flow Logs |
| vpc\_with\_flow\_logs\_to\_cloudwatch\_logs\_default\_vpc\_flow\_log\_destination\_type | The type of the destination for VPC Flow Logs |
| vpc\_with\_flow\_logs\_to\_cloudwatch\_logs\_default\_vpc\_flow\_log\_id | The ID of the Flow Log resource |
| vpc\_with\_flow\_logs\_to\_cloudwatch\_logs\_vpc\_flow\_log\_destination\_arn | The ARN of the destination for VPC Flow Logs |
| vpc\_with\_flow\_logs\_to\_cloudwatch\_logs\_vpc\_flow\_log\_destination\_type | The type of the destination for VPC Flow Logs |
| vpc\_with\_flow\_logs\_to\_cloudwatch\_logs\_vpc\_flow\_log\_id | The ID of the Flow Log resource |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
