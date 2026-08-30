# AWS Subnets Terraform Module

Terraform module which creates a tier of AWS VPC Subnets: the subnets, their route tables and
routes, any NAT gateways, and the tier's network ACL.

One module block is one tier. A caller writes one for public subnets, one for private, one for
databases, and composes them into whatever topology the architecture calls for, rather than
choosing from a fixed set the root module offers.

## Usage

```hcl
module "private" {
  source = "terraform-aws-modules/vpc/aws//modules/subnets"

  name   = "example-private"
  vpc_id = module.vpc.vpc_id

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i)
  } }

  routes = {
    nat = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      nat_gateway_id              = module.public.nat_gateway_ids[local.azs[0]]
    }
  }

  tags = local.tags
}
```

See the [patterns](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/patterns)
directory for complete architectures built this way.

### Route tables are inferred, not configured

Whether the tier shares one route table follows from where the routes are written.

Routes declared on the group, as above, mean every subnet routes identically, so one table is
created and every subnet in the tier is associated with it.

As soon as any subnet declares routes of its own the tier is no longer uniform, so the shared
table is not created and every subnet gets one of its own. A subnet that declares none still
gets its own table, carrying the group's routes:

```hcl
  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i)

    # a gateway in every zone, so each subnet needs a table of its own
    routes = {
      nat = {
        destination_ipv4_cidr_block = "0.0.0.0/0"
        nat_gateway_id              = module.public.nat_gateway_ids[az]
      }
    }
  } }
```

This reads the structure of the configuration rather than the values in it, which matters more
than it looks. Route targets are almost always computed: a NAT gateway ID or a firewall endpoint
ID is not known until the resource exists. Terraform has to know how many resources it is
creating before it creates any of them, so a count decided by a route target fails the plan with
`Invalid count argument`. Where the routes are *written* is configuration, and is known.

A tier that wants a table per subnet without any of them routing anywhere in particular says so
with an empty map on one entry, `routes = {}`. That is different from omitting the argument,
which is what leaves the tier uniform.

### Group settings and per subnet overrides

Arguments on the group are defaults for every subnet in it, and a subnet entry can override
them. A tier where one zone differs stays a single module block:

```hcl
  # every subnet is public
  map_public_ip_on_launch = true

  subnets = { for i, az in local.azs : az => {
    availability_zone = az
    ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, i)

    # but only the first zone hosts the gateway
    create_nat_gateway = az == local.azs[0]
  } }
```

### Network ACLs

The network ACL belongs to this layer. One network ACL is associated with several subnets, so
no single subnet owns it, which is the strongest reason this layer exists at all:

```hcl
  create_network_acl = true

  network_acl_rules = {
    inbound_https = {
      rule_number = 100
      egress      = false
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
    }
  }
```

Leave `create_network_acl` off and the subnets stay on the VPC's default ACL. To join an ACL
created elsewhere, pass its ID as `network_acl_id`.

### Gateway route tables

This sub-module does not create them. A route table associated with an internet gateway
[must be dedicated to that gateway and associated with no subnet](https://docs.aws.amazon.com/vpc/latest/userguide/igw-ingress-routing.html),
whereas every table created here is associated with the subnets of its tier. The
[route-table](../route-table) sub-module covers that case.

### A single subnet

Where a tier is genuinely one subnet, or where subnets in a tier depend on each other, the
[subnet](../subnet) sub-module is the primitive underneath this one and is the better fit.

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

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_route_table"></a> [route\_table](#module\_route\_table) | ../route-table | n/a |
| <a name="module_subnet"></a> [subnet](#module\_subnet) | ../subnet | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_assign_ipv6_address_on_creation"></a> [assign\_ipv6\_address\_on\_creation](#input\_assign\_ipv6\_address\_on\_creation) | Specify true to indicate that network interfaces created in the subnets should be assigned an IPv6 address | `bool` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created | `bool` | `true` | no |
| <a name="input_create_eip"></a> [create\_eip](#input\_create\_eip) | Controls if an Elastic IP is created for each NAT gateway. A subnet can override this | `bool` | `true` | no |
| <a name="input_create_nat_gateway"></a> [create\_nat\_gateway](#input\_create\_nat\_gateway) | Controls if a NAT gateway is created in every subnet of the group. A subnet can override this | `bool` | `false` | no |
| <a name="input_create_network_acl"></a> [create\_network\_acl](#input\_create\_network\_acl) | Controls if a dedicated network ACL is created for the group. A network ACL is associated with many subnets, so it belongs to the group rather than to any one subnet | `bool` | `false` | no |
| <a name="input_create_route_table"></a> [create\_route\_table](#input\_create\_route\_table) | Controls if route table(s) are created for the subnets. Set to `false` and supply `route_table_id` to join a table created elsewhere | `bool` | `true` | no |
| <a name="input_enable_dns64"></a> [enable\_dns64](#input\_enable\_dns64) | Indicates whether DNS queries made to the Amazon-provided DNS Resolver in these subnets should return synthetic IPv6 addresses for IPv4-only destinations. Needs a `64:ff9b::/96` route to a NAT gateway to be reachable | `bool` | `null` | no |
| <a name="input_enable_resource_name_dns_a_record_on_launch"></a> [enable\_resource\_name\_dns\_a\_record\_on\_launch](#input\_enable\_resource\_name\_dns\_a\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS A records | `bool` | `null` | no |
| <a name="input_enable_resource_name_dns_aaaa_record_on_launch"></a> [enable\_resource\_name\_dns\_aaaa\_record\_on\_launch](#input\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records | `bool` | `null` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Specify true to indicate that instances launched into the subnets should be assigned a public IP address | `bool` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name used across the resources created. Each subnet is named `<name>-<key>` unless it sets its own | `string` | `""` | no |
| <a name="input_nat_gateway_connectivity_type"></a> [nat\_gateway\_connectivity\_type](#input\_nat\_gateway\_connectivity\_type) | Connectivity type for each NAT gateway created in the group. Valid values are `private` or `public`. A subnet can override this | `string` | `null` | no |
| <a name="input_nat_gateway_tags"></a> [nat\_gateway\_tags](#input\_nat\_gateway\_tags) | Additional tags for the NAT gateway(s) | `map(string)` | `{}` | no |
| <a name="input_network_acl_id"></a> [network\_acl\_id](#input\_network\_acl\_id) | The ID of an existing network ACL for every subnet to join. Ignored when `create_network_acl` is `true` | `string` | `null` | no |
| <a name="input_network_acl_rules"></a> [network\_acl\_rules](#input\_network\_acl\_rules) | Map of network ACL rules. Set `egress` to distinguish outbound rules from inbound | <pre>map(object({<br/>    egress          = optional(bool, false)<br/>    rule_number     = number<br/>    rule_action     = string<br/>    protocol        = string<br/>    from_port       = optional(number)<br/>    to_port         = optional(number)<br/>    icmp_code       = optional(number)<br/>    icmp_type       = optional(number)<br/>    cidr_block      = optional(string)<br/>    ipv6_cidr_block = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_network_acl_tags"></a> [network\_acl\_tags](#input\_network\_acl\_tags) | Additional tags for the network ACL | `map(string)` | `{}` | no |
| <a name="input_private_dns_hostname_type_on_launch"></a> [private\_dns\_hostname\_type\_on\_launch](#input\_private\_dns\_hostname\_type\_on\_launch) | The type of hostnames to assign to instances in the subnets at launch. Valid values are `ip-name` and `resource-name` | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_resource_share_arn"></a> [resource\_share\_arn](#input\_resource\_share\_arn) | ARN of the RAM resource share to associate shared subnets with | `string` | `null` | no |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | The ID of an existing route table for every subnet to join. Used when `create_route_table` is `false` | `string` | `null` | no |
| <a name="input_route_table_tags"></a> [route\_table\_tags](#input\_route\_table\_tags) | Additional tags for the route table(s) | `map(string)` | `{}` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | Routes shared by every subnet in the group. A subnet that declares its own `routes` overrides these and takes its own route table | <pre>map(object({<br/>    destination_ipv4_cidr_block = optional(string)<br/>    destination_ipv6_cidr_block = optional(string)<br/>    destination_prefix_list_id  = optional(string)<br/>    carrier_gateway_id          = optional(string)<br/>    core_network_arn            = optional(string)<br/>    egress_only_gateway_id      = optional(string)<br/>    gateway_id                  = optional(string)<br/>    local_gateway_id            = optional(string)<br/>    nat_gateway_id              = optional(string)<br/>    network_interface_id        = optional(string)<br/>    odb_network_arn             = optional(string)<br/>    transit_gateway_id          = optional(string)<br/>    vpc_endpoint_id             = optional(string)<br/>    vpc_peering_connection_id   = optional(string)<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_share_subnet"></a> [share\_subnet](#input\_share\_subnet) | Controls if every subnet in the group is shared via RAM. A subnet can override this | `bool` | `false` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnets to create. The key names the subnet and is the key of every output. A subnet that sets its own `routes` gets its own route table, and one that does not shares the group's | <pre>map(object({<br/>    name                 = optional(string)<br/>    availability_zone    = optional(string)<br/>    availability_zone_id = optional(string)<br/>    ipv4_cidr_block      = optional(string)<br/>    ipv6_cidr_block      = optional(string)<br/>    ipv6_native          = optional(bool)<br/>    create_nat_gateway   = optional(bool)<br/>    tags                 = optional(map(string), {})<br/>    # Tags for this subnet's own route table, when it has one<br/>    route_table_tags = optional(map(string), {})<br/>    # Sharing this subnet through RAM, which is per subnet rather than per group<br/>    share_subnet       = optional(bool)<br/>    resource_share_arn = optional(string)<br/>    # NAT gateway shape, when this subnet hosts one. A private NAT gateway takes no<br/>    # address, and a Local Zone gateway needs one from that zone's border group<br/>    create_eip                    = optional(bool)<br/>    eip_network_border_group      = optional(string)<br/>    nat_gateway_allocation_id     = optional(string)<br/>    nat_gateway_connectivity_type = optional(string)<br/>    routes = optional(map(object({<br/>      destination_ipv4_cidr_block = optional(string)<br/>      destination_ipv6_cidr_block = optional(string)<br/>      destination_prefix_list_id  = optional(string)<br/>      carrier_gateway_id          = optional(string)<br/>      core_network_arn            = optional(string)<br/>      egress_only_gateway_id      = optional(string)<br/>      gateway_id                  = optional(string)<br/>      local_gateway_id            = optional(string)<br/>      nat_gateway_id              = optional(string)<br/>      network_interface_id        = optional(string)<br/>      odb_network_arn             = optional(string)<br/>      transit_gateway_id          = optional(string)<br/>      vpc_endpoint_id             = optional(string)<br/>      vpc_peering_connection_id   = optional(string)<br/>      timeouts = optional(object({<br/>        create = optional(string)<br/>        update = optional(string)<br/>        delete = optional(string)<br/>      }))<br/>    })))<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC the resources are created within | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arns"></a> [arns](#output\_arns) | Map of subnet keys to subnet ARNs |
| <a name="output_ids"></a> [ids](#output\_ids) | Map of subnet keys to subnet IDs |
| <a name="output_ipv4_cidr_blocks"></a> [ipv4\_cidr\_blocks](#output\_ipv4\_cidr\_blocks) | Map of subnet keys to IPv4 CIDR blocks |
| <a name="output_ipv6_cidr_blocks"></a> [ipv6\_cidr\_blocks](#output\_ipv6\_cidr\_blocks) | Map of subnet keys to IPv6 CIDR blocks |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | Map of subnet keys to the NAT gateway created in that subnet |
| <a name="output_network_acl_id"></a> [network\_acl\_id](#output\_network\_acl\_id) | The ID of the network ACL created for the group |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | Map of subnet keys to the route table associated with that subnet |
| <a name="output_shared_route_table_id"></a> [shared\_route\_table\_id](#output\_shared\_route\_table\_id) | The route table shared by every subnet, when the group's routes are identical |
| <a name="output_shared_route_table_routes"></a> [shared\_route\_table\_routes](#output\_shared\_route\_table\_routes) | Map of the routes on the shared route table, when one was created |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Map of subnet keys to all attributes of the subnet sub-module |
<!-- END_TF_DOCS -->
