# Existing VPC and Security Group - create ONLY endpoint

Configuration in this directory creates set of VPC resources which may be sufficient for creating endpoints inside an existing VPC.

This configuration uses a VPC ID and Security Group ID for demonstration purposes.

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

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | n/a | `string` | `""` | no |
| sg_id | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc\_endpoint\_ec2\_id | The ID of VPC endpoint for EC2 |
| vpc\_endpoint\_ec2\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for EC2 |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
