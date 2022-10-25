# AWS VPC Network ACL Terraform sub-module

Terraform sub-module which creates VPC Network ACL resources on AWS.

## Usage

```hcl
module "nacl" {
  source = "terraform-aws-modules/vpc/aws//modules/network-acl"

  vpc_id     = "vpc-12345678"
  subnet_ids = [ "subnet-100500abc100500ab" ]

  tags = {
    Name = "NACL-name"
  }

  inbound_acl_rules = [
    {
      rule_number = 900
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
  ]

  outbound_acl_rules = [
    {
      rule_number = 900
      rule_action = "allow"
      from_port   = 32768
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
```

## Examples

- [Network-ACL](../../examples/network-acl) with dedicated network ACL module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.36.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_network_acl_rule.inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created | `bool` | `true` | no |
| <a name="input_inbound_acl_rules"></a> [inbound\_acl\_rules](#input\_inbound\_acl\_rules) | Inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_outbound_acl_rules"></a> [outbound\_acl\_rules](#input\_outbound\_acl\_rules) | Outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of Subnet IDs to apply the ACL to | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the NACL | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the associated VPC | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_acl_arn"></a> [network\_acl\_arn](#output\_network\_acl\_arn) | The ARN of the network ACL |
| <a name="output_network_acl_id"></a> [network\_acl\_id](#output\_network\_acl\_id) | The ID of the network ACL |
<!-- END_TF_DOCS -->
