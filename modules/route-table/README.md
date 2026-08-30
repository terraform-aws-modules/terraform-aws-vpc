# AWS Route Table Terraform Module

Terraform module which creates an AWS VPC Route Table and its routes.

Most route tables are created by the [subnets](../subnets) and [subnet](../subnet) sub-modules,
which associate the table with the subnets it serves. This sub-module is for the tables those
cannot create: a table associated with a gateway, or a table shared by subnets that are built
somewhere else.

## Usage

### A gateway route table

Inbound traffic from an internet gateway reaches the subnets directly unless a route table is
attached to the gateway itself. Without one, an inspection appliance sees outbound traffic and
not the return leg, which a stateful engine cannot evaluate. Such a table
[must be dedicated to the gateway and associated with no subnet](https://docs.aws.amazon.com/vpc/latest/userguide/igw-ingress-routing.html),
which is why it cannot come from a subnet sub-module:

```hcl
module "igw_ingress" {
  source = "terraform-aws-modules/vpc/aws//modules/route-table"

  name   = "example-igw-ingress"
  vpc_id = module.vpc.vpc_id

  gateway_id = module.vpc.igw_id

  # traffic for each subnet goes to the endpoint in that subnet's own zone,
  # which is what keeps the flow symmetric
  routes = { for az, cidr in local.public_subnets :
    az => {
      destination_ipv4_cidr_block = cidr
      vpc_endpoint_id             = local.firewall_endpoints[az].endpoint_id
    }
  }

  tags = local.tags
}
```

### A standalone route table

Omit `gateway_id` and the table is associated with nothing, ready for subnets built elsewhere
to join with their own `route_table_id`:

```hcl
module "shared" {
  source = "terraform-aws-modules/vpc/aws//modules/route-table"

  name   = "example-shared"
  vpc_id = module.vpc.vpc_id

  routes = {
    nat = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      nat_gateway_id              = module.public.nat_gateway_ids[local.azs[0]]
    }
  }
}
```

A tier that needs one shared table does not need this: the [subnets](../subnets) sub-module
creates one itself when every subnet in the group routes identically.

See the [patterns](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/patterns)
directory for complete architectures built from these sub-modules.

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
| [aws_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created | `bool` | `true` | no |
| <a name="input_create_gateway_association"></a> [create\_gateway\_association](#input\_create\_gateway\_association) | Controls if the route table is associated with the gateway given by `gateway_id`. A separate toggle rather than deriving it from `gateway_id`, because that ID is normally a computed value and would leave the count unknown at plan time | `bool` | `false` | no |
| <a name="input_gateway_id"></a> [gateway\_id](#input\_gateway\_id) | The ID of an internet gateway or virtual private gateway to associate the route table with. Leave unset for a plain route table to be shared across subnets | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name used across the resources created | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_route_table_association_timeouts"></a> [route\_table\_association\_timeouts](#input\_route\_table\_association\_timeouts) | Create, update, and delete timeout configurations for the gateway association | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_route_table_tags"></a> [route\_table\_tags](#input\_route\_table\_tags) | Additional tags for the route table | `map(string)` | `{}` | no |
| <a name="input_route_timeouts"></a> [route\_timeouts](#input\_route\_timeouts) | Default create, update, and delete timeout configurations for routes | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | Map of route definitions to create | <pre>map(object({<br/>    destination_ipv4_cidr_block = optional(string)<br/>    destination_ipv6_cidr_block = optional(string)<br/>    destination_prefix_list_id  = optional(string)<br/>    carrier_gateway_id          = optional(string)<br/>    core_network_arn            = optional(string)<br/>    egress_only_gateway_id      = optional(string)<br/>    gateway_id                  = optional(string)<br/>    local_gateway_id            = optional(string)<br/>    nat_gateway_id              = optional(string)<br/>    odb_network_arn             = optional(string)<br/>    network_interface_id        = optional(string)<br/>    transit_gateway_id          = optional(string)<br/>    vpc_endpoint_id             = optional(string)<br/>    vpc_peering_connection_id   = optional(string)<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create, update, and delete timeout configurations for the route table | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC the resources are created within | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the route table |
| <a name="output_id"></a> [id](#output\_id) | The ID of the route table |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The ID of the AWS account that owns the route table |
| <a name="output_route_table_association_id"></a> [route\_table\_association\_id](#output\_route\_table\_association\_id) | The ID of the association between the route table and the gateway |
| <a name="output_routes"></a> [routes](#output\_routes) | Map of routes created and their attributes |
<!-- END_TF_DOCS -->
