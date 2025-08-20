# AWS VPC Endpoints Terraform sub-module

Terraform sub-module which creates VPC endpoint resources on AWS.

## Usage

See [`examples`](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples) directory for working examples to reference:

```hcl
module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = "vpc-12345678"
  security_group_ids = ["sg-12345678"]

  endpoints = {
    s3 = {
      # interface endpoint
      service             = "s3"
      tags                = { Name = "s3-vpc-endpoint" }
    },
    dynamodb = {
      # gateway endpoint
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = ["rt-12322456", "rt-43433343", "rt-11223344"]
      tags            = { Name = "dynamodb-vpc-endpoint" }
    },
    sns = {
      service               = "sns"
      subnet_ids            = ["subnet-12345678", "subnet-87654321"]
      subnet_configurations = [
        {
          ipv4      = "10.8.34.10"
          subnet_id = "subnet-12345678"
        },
        {
          ipv4      = "10.8.35.10"
          subnet_id = "subnet-87654321"
        }
      ]
      tags = { Name = "sns-vpc-endpoint" }
    },
    sqs = {
      service             = "sqs"
      private_dns_enabled = true
      security_group_ids  = ["sg-987654321"]
      subnet_ids          = ["subnet-12345678", "subnet-87654321"]
      tags                = { Name = "sqs-vpc-endpoint" }
    },
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
```

### Region Support Limitation

When using this sub-module with the [region parameter](https://registry.terraform.io/providers/hashicorp/aws/6.0.0/docs/guides/enhanced-region-support), it will still try to look up the service endpoint in the default region that's set in aws provider configuration. When you have this config:

* aws provider region: us-east-1
* module region: eu-central-1

It leads to an API error as shown:

```plaintext
│ Error: creating EC2 VPC Endpoint (com.amazonaws.us-east-1.s3): operation error EC2: CreateVpcEndpoint, https response error StatusCode: 400, RequestID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx, api error InvalidServiceName: The Vpc Endpoint Service 'com.amazonaws.us-east-1.s3' does not exist
│
│   with module.vpc-endpoints-regions["eu-central-1"].aws_vpc_endpoint.this["s3"],
│   on .terraform/modules/vpc-endpoints-regions/modules/vpc-endpoints/main.tf line 24, in resource "aws_vpc_endpoint" "this":
│   24: resource "aws_vpc_endpoint" "this" {
```

This happens because the [aws_vpc_endpoint_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) data source used in this sub-module does not support the [region parameter](https://registry.terraform.io/providers/hashicorp/aws/6.0.0/docs/guides/enhanced-region-support#non%E2%80%93region-aware-resources) yet.

As a workaround, we have added the option `enable_service_endpoint_lookup = false` to disable the data source, but you will have to provide fully-qualified service endpoint instead of just the short service name, as shown in the example below.

Before:

```hcl
module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  for_each = toset([
    "us-east-1",
    "eu-west-1",
    "eu-central-1",
  ])
  region = each.value

  vpc_id             = var.regional_vpc_ids[each.value]
  security_group_ids = [var.regional_sg_ids[each.value]]

  endpoints = {
    s3 = {
      service = "s3"
      # …
    }
  }
}
```

After:

```hcl
module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  for_each = toset([
    "us-east-1",
    "eu-west-1",
    "eu-central-1",
  ])
  region = each.value

  vpc_id             = var.regional_vpc_ids[each.value]
  security_group_ids = [var.regional_sg_ids[each.value]]

  enable_service_endpoint_lookup = false # <-- THIS
  endpoints = {
    s3 = {
      service_endpoint = "com.amazonaws.${each.value}.s3" # <-- THIS
      service_region   = each.value                       # <-- THIS
      # …
    }
  }
}
```

## Examples

- [Complete-VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete) with VPC Endpoints.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines if a security group is created | `bool` | `false` | no |
| <a name="input_enable_service_endpoint_lookup"></a> [enable\_service\_endpoint\_lookup](#input\_enable\_service\_endpoint\_lookup) | Determines whether to look up the service endpoint in the AWS API. If set to false, the `service_endpoint` attribute (usually in the form of `com.amazonaws.<region>.<service>`) must be provided in the `endpoints` map | `bool` | `true` | no |
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | A map of interface and/or gateway endpoints containing their properties and configurations | `any` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the region set in the provider configuration | `string` | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group created | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Default security group IDs to associate with the VPC endpoints | `list(string)` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created. Conflicts with `security_group_name_prefix` | `string` | `null` | no |
| <a name="input_security_group_name_prefix"></a> [security\_group\_name\_prefix](#input\_security\_group\_name\_prefix) | Name prefix to use on security group created. Conflicts with `security_group_name` | `string` | `null` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Security group rules to add to the security group created | `any` | `{}` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Default subnets IDs to associate with the VPC endpoints | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to use on all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Define maximum timeout for creating, updating, and deleting VPC endpoint resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which the endpoint will be used | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | Array containing the full resource object and attributes for all endpoints created |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
<!-- END_TF_DOCS -->
