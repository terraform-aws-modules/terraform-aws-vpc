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

## Examples

- [Complete-VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete) with VPC Endpoints.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Determines if a security group is created | `bool` | `false` | no |
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | A map of interface and/or gateway endpoints containing their properties and configurations | <pre>map(object({<br/>    create = optional(bool, true)<br/><br/>    auto_accept = optional(bool)<br/>    dns_options = optional(object({<br/>      dns_record_ip_type                             = optional(string)<br/>      private_dns_only_for_inbound_resolver_endpoint = optional(bool)<br/>    }))<br/>    ip_address_type     = optional(string)<br/>    policy              = optional(string)<br/>    private_dns_enabled = optional(bool)<br/>    route_table_ids     = optional(list(string))<br/>    security_group_ids  = optional(list(string), [])<br/>    service             = optional(string)<br/>    service_endpoint    = optional(string)<br/>    service_name        = optional(string)<br/>    service_region      = optional(string)<br/>    service_type        = optional(string, "Interface")<br/>    subnet_configurations = optional(list(object({<br/>      ipv4      = optional(string)<br/>      ipv6      = optional(string)<br/>      subnet_id = optional(string)<br/>    })), [])<br/>    subnet_ids = optional(list(string), [])<br/>    tags       = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration. If a value is provided, `service_endpoint` must be specified due to https://github.com/hashicorp/terraform-provider-aws/issues/42462 | `string` | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group created | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Default security group IDs to associate with the VPC endpoints | `list(string)` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name to use on security group created. Conflicts with `security_group_name_prefix` | `string` | `null` | no |
| <a name="input_security_group_name_prefix"></a> [security\_group\_name\_prefix](#input\_security\_group\_name\_prefix) | Name prefix to use on security group created. Conflicts with `security_group_name` | `string` | `null` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Security group rules to add to the security group created | <pre>map(object({<br/>    cidr_blocks              = optional(list(string))<br/>    description              = optional(string)<br/>    from_port                = optional(number, 443)<br/>    ipv6_cidr_blocks         = optional(list(string))<br/>    prefix_list_ids          = optional(list(string))<br/>    protocol                 = optional(string, "tcp")<br/>    self                     = optional(bool)<br/>    source_security_group_id = optional(string)<br/>    to_port                  = optional(number, 443)<br/>    type                     = optional(string, "ingress")<br/>  }))</pre> | `{}` | no |
| <a name="input_security_group_tags"></a> [security\_group\_tags](#input\_security\_group\_tags) | A map of additional tags to add to the security group created | `map(string)` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Default subnets IDs to associate with the VPC endpoints | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to use on all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Define maximum timeout for creating, updating, and deleting VPC endpoint resources | <pre>object({<br/>    create = optional(string, "10m")<br/>    update = optional(string, "10m")<br/>    delete = optional(string, "10m")<br/>  })</pre> | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which the endpoint will be used | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | Array containing the full resource object and attributes for all endpoints created |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
<!-- END_TF_DOCS -->
