# AWS Subnet Terraform Module

Terraform module which creates a single AWS VPC Subnet and the routing that belongs to it.

This is the primitive the composable subnet sub-modules are built from. For a whole tier of
subnets in one module block, use the [subnets](../subnets) sub-module, which wraps this one
and adds the shared route table and the network ACL a tier needs. Reach for this sub-module
directly when a tier is genuinely one subnet, or when subnets in a tier depend on each other,
such as a private subnet routing to a NAT gateway in the public subnet beside it.

## Usage

This sub-module creates a **single** subnet, together with its route table, its routes and
optionally a NAT gateway. Callers compose several with `for_each`, which is what lets a
subnet group be any shape rather than one of a fixed set of tiers.

See the [patterns](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/patterns)
directory for complete architectures built from it.

### A subnet that owns its route table

```hcl
module "public" {
  source = "terraform-aws-modules/vpc/aws//modules/subnet"

  for_each = { for i, az in local.azs : az => cidrsubnet(local.vpc_cidr, 8, i) }

  name              = "example-public-${each.key}"
  vpc_id            = module.vpc.vpc_id
  availability_zone = each.key
  ipv4_cidr_block   = each.value

  map_public_ip_on_launch = true

  routes = {
    igw = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      gateway_id                  = module.vpc.igw_id
    }
  }
}
```

### Subnets sharing one route table

Routes that are identical for every subnet do not need a table each. The [subnets](../subnets)
sub-module works this out on its own, so that is the better starting point. Where the table is
built elsewhere, a subnet joins it instead of creating one:

```hcl
module "private" {
  source = "terraform-aws-modules/vpc/aws//modules/subnet"

  for_each = { for i, az in local.azs : az => cidrsubnet(local.vpc_cidr, 8, i + 8) }

  name              = "example-private-${each.key}"
  vpc_id            = module.vpc.vpc_id
  availability_zone = each.key
  ipv4_cidr_block   = each.value

  create_route_table = false
  route_table_id     = module.private_route_table.id
}
```

### A subnet hosting a NAT gateway

```hcl
module "public" {
  source = "terraform-aws-modules/vpc/aws//modules/subnet"

  name              = "example-public"
  vpc_id            = module.vpc.vpc_id
  availability_zone = local.azs[0]
  ipv4_cidr_block   = cidrsubnet(local.vpc_cidr, 8, 0)

  create_nat_gateway = true

  routes = {
    igw = {
      destination_ipv4_cidr_block = "0.0.0.0/0"
      gateway_id                  = module.vpc.igw_id
    }
  }
}
```

Other subnets then route to it with `module.public.nat_gateway_id`.

### Network ACLs

This sub-module does not create network ACLs, because one network ACL is normally shared by
several subnets and so has no single subnet to own it. The [subnets](../subnets) sub-module
creates one for the tier. Where the ACL is built elsewhere, a subnet joins it the same way it
joins a shared route table:

```hcl
  create_network_acl_association = true
  network_acl_id                 = aws_network_acl.this.id
```

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
| [aws_ec2_subnet_cidr_reservation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_subnet_cidr_reservation) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_ram_resource_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_assign_ipv6_address_on_creation"></a> [assign\_ipv6\_address\_on\_creation](#input\_assign\_ipv6\_address\_on\_creation) | Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address | `bool` | `null` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | AZ for the subnet | `string` | `null` | no |
| <a name="input_availability_zone_id"></a> [availability\_zone\_id](#input\_availability\_zone\_id) | AZ ID of the subnet. This argument is not supported in all regions or partitions. If necessary, use `availability_zone` instead | `string` | `null` | no |
| <a name="input_cidr_reservations"></a> [cidr\_reservations](#input\_cidr\_reservations) | Map of CIDR reservations to create | <pre>map(object({<br/>    cidr_block       = string<br/>    description      = optional(string)<br/>    reservation_type = string<br/>  }))</pre> | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created | `bool` | `true` | no |
| <a name="input_create_eip"></a> [create\_eip](#input\_create\_eip) | Controls if an EIP should be created for the NAT gateway | `bool` | `true` | no |
| <a name="input_create_nat_gateway"></a> [create\_nat\_gateway](#input\_create\_nat\_gateway) | Controls if a NAT gateway should be created | `bool` | `false` | no |
| <a name="input_create_network_acl_association"></a> [create\_network\_acl\_association](#input\_create\_network\_acl\_association) | Controls if the subnet is associated with the network ACL given by `network_acl_id`. A separate toggle rather than deriving it from `network_acl_id`, because that ID is usually a computed value and would leave the count unknown at plan time | `bool` | `false` | no |
| <a name="input_create_route_table"></a> [create\_route\_table](#input\_create\_route\_table) | Controls if a route table should be created | `bool` | `true` | no |
| <a name="input_customer_owned_ipv4_pool"></a> [customer\_owned\_ipv4\_pool](#input\_customer\_owned\_ipv4\_pool) | The customer owned IPv4 address pool. Typically used with the `map_customer_owned_ip_on_launch` argument. The `outpost_arn` argument must be specified when configured | `string` | `null` | no |
| <a name="input_eip_address"></a> [eip\_address](#input\_eip\_address) | IP address from an EC2 BYOIP pool | `string` | `null` | no |
| <a name="input_eip_associate_with_private_ip"></a> [eip\_associate\_with\_private\_ip](#input\_eip\_associate\_with\_private\_ip) | User-specified primary or secondary private IP address to associate with the Elastic IP address. If no private IP address is specified, the Elastic IP address is associated with the primary private IP address | `string` | `null` | no |
| <a name="input_eip_customer_owned_ipv4_pool"></a> [eip\_customer\_owned\_ipv4\_pool](#input\_eip\_customer\_owned\_ipv4\_pool) | ID of a customer-owned address pool | `string` | `null` | no |
| <a name="input_eip_network_border_group"></a> [eip\_network\_border\_group](#input\_eip\_network\_border\_group) | Location from which the IP address is advertised. Use this parameter to limit the address to this location | `string` | `null` | no |
| <a name="input_eip_public_ipv4_pool"></a> [eip\_public\_ipv4\_pool](#input\_eip\_public\_ipv4\_pool) | EC2 IPv4 address pool identifier or `amazon` | `string` | `null` | no |
| <a name="input_eip_tags"></a> [eip\_tags](#input\_eip\_tags) | Additional tags for the Elastic IP created for the NAT gateway | `map(string)` | `{}` | no |
| <a name="input_eip_timeouts"></a> [eip\_timeouts](#input\_eip\_timeouts) | Read, update, and delete timeout configurations for the Elastic IP. The Elastic IP resource has no create timeout | <pre>object({<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_enable_dns64"></a> [enable\_dns64](#input\_enable\_dns64) | Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations | `bool` | `null` | no |
| <a name="input_enable_lni_at_device_index"></a> [enable\_lni\_at\_device\_index](#input\_enable\_lni\_at\_device\_index) | Indicates the device position for local network interfaces in this subnet | `number` | `null` | no |
| <a name="input_enable_resource_name_dns_a_record_on_launch"></a> [enable\_resource\_name\_dns\_a\_record\_on\_launch](#input\_enable\_resource\_name\_dns\_a\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS A records | `bool` | `null` | no |
| <a name="input_enable_resource_name_dns_aaaa_record_on_launch"></a> [enable\_resource\_name\_dns\_aaaa\_record\_on\_launch](#input\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records | `bool` | `null` | no |
| <a name="input_ipv4_cidr_block"></a> [ipv4\_cidr\_block](#input\_ipv4\_cidr\_block) | The IPv4 CIDR block for the subnet | `string` | `null` | no |
| <a name="input_ipv6_cidr_block"></a> [ipv6\_cidr\_block](#input\_ipv6\_cidr\_block) | The IPv6 network range for the subnet, in CIDR notation. The subnet size must use a /64 prefix length | `string` | `null` | no |
| <a name="input_ipv6_native"></a> [ipv6\_native](#input\_ipv6\_native) | Indicates whether to create an IPv6-only subnet | `bool` | `null` | no |
| <a name="input_map_customer_owned_ip_on_launch"></a> [map\_customer\_owned\_ip\_on\_launch](#input\_map\_customer\_owned\_ip\_on\_launch) | Specify true to indicate that network interfaces created in the subnet should be assigned a customer owned IP address. The `customer_owned_ipv4_pool` and `outpost_arn` arguments must be specified when set to `true` | `bool` | `null` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Specify true to indicate that instances launched into the subnet should be assigned a public IP address | `bool` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name used across the resources created | `string` | `""` | no |
| <a name="input_nat_gateway_allocation_id"></a> [nat\_gateway\_allocation\_id](#input\_nat\_gateway\_allocation\_id) | The Allocation ID of the Elastic IP address for the gateway. Required when `nat_gateway_connectivity_type` is `public` and `create_eip` is `false` | `string` | `null` | no |
| <a name="input_nat_gateway_connectivity_type"></a> [nat\_gateway\_connectivity\_type](#input\_nat\_gateway\_connectivity\_type) | Connectivity type for the gateway. Valid values are `private` and `public`. Defaults to `public` | `string` | `null` | no |
| <a name="input_nat_gateway_tags"></a> [nat\_gateway\_tags](#input\_nat\_gateway\_tags) | Additional tags for the NAT gateway | `map(string)` | `{}` | no |
| <a name="input_nat_gateway_timeouts"></a> [nat\_gateway\_timeouts](#input\_nat\_gateway\_timeouts) | Create, update, and delete timeout configurations for the NAT gateway | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_network_acl_id"></a> [network\_acl\_id](#input\_network\_acl\_id) | The ID of an existing network ACL to associate the subnet with. A network ACL is normally shared by several subnets, so this sub-module joins one rather than creating one. Leave unset to stay on the VPC default network ACL | `string` | `null` | no |
| <a name="input_outpost_arn"></a> [outpost\_arn](#input\_outpost\_arn) | The Amazon Resource Name (ARN) of the Outpost | `string` | `null` | no |
| <a name="input_private_dns_hostname_type_on_launch"></a> [private\_dns\_hostname\_type\_on\_launch](#input\_private\_dns\_hostname\_type\_on\_launch) | The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values are `ip-name` and `resource-name` | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_resource_share_arn"></a> [resource\_share\_arn](#input\_resource\_share\_arn) | Amazon Resource Name (ARN) of the RAM Resource Share | `string` | `null` | no |
| <a name="input_route_table_association_timeouts"></a> [route\_table\_association\_timeouts](#input\_route\_table\_association\_timeouts) | Create, update, and delete timeout configurations for route table association | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | The ID of an existing route table to associate with the subnet | `string` | `null` | no |
| <a name="input_route_table_propagating_vgws"></a> [route\_table\_propagating\_vgws](#input\_route\_table\_propagating\_vgws) | List of virtual gateways for route propagation | `list(string)` | `[]` | no |
| <a name="input_route_table_tags"></a> [route\_table\_tags](#input\_route\_table\_tags) | Additional tags for the VPC | `map(string)` | `{}` | no |
| <a name="input_route_table_timeouts"></a> [route\_table\_timeouts](#input\_route\_table\_timeouts) | Create, update, and delete timeout configurations for route table | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_route_timeouts"></a> [route\_timeouts](#input\_route\_timeouts) | Default create, update, and delete timeout configurations for routes | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | Map of route definitions to create | <pre>map(object({<br/>    destination_ipv4_cidr_block = optional(string)<br/>    destination_ipv6_cidr_block = optional(string)<br/>    destination_prefix_list_id  = optional(string)<br/>    carrier_gateway_id          = optional(string)<br/>    core_network_arn            = optional(string)<br/>    egress_only_gateway_id      = optional(string)<br/>    # this_egress_only_gateway  = optional(bool)<br/>    gateway_id = optional(string)<br/>    # this_internet_gateway     = optional(bool)<br/>    local_gateway_id          = optional(string)<br/>    nat_gateway_id            = optional(string)<br/>    odb_network_arn           = optional(string)<br/>    network_interface_id      = optional(string)<br/>    transit_gateway_id        = optional(string)<br/>    vpc_endpoint_id           = optional(string)<br/>    vpc_peering_connection_id = optional(string)<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_share_subnet"></a> [share\_subnet](#input\_share\_subnet) | Controls if the subnet should be shared via RAM resource association | `bool` | `false` | no |
| <a name="input_subnet_tags"></a> [subnet\_tags](#input\_subnet\_tags) | Additional tags for the subnet | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create and delete timeout configurations for subnet | <pre>object({<br/>    create = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC the resources are created within | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the subnet |
| <a name="output_eip_carrier_ip"></a> [eip\_carrier\_ip](#output\_eip\_carrier\_ip) | Carrier IP address |
| <a name="output_eip_customer_owned_ip"></a> [eip\_customer\_owned\_ip](#output\_eip\_customer\_owned\_ip) | Customer owned IP |
| <a name="output_eip_id"></a> [eip\_id](#output\_eip\_id) | Contains the EIP allocation ID |
| <a name="output_eip_private_dns"></a> [eip\_private\_dns](#output\_eip\_private\_dns) | The Private DNS associated with the Elastic IP address |
| <a name="output_eip_private_ip"></a> [eip\_private\_ip](#output\_eip\_private\_ip) | Contains the private IP address |
| <a name="output_eip_public_dns"></a> [eip\_public\_dns](#output\_eip\_public\_dns) | Public DNS associated with the Elastic IP address |
| <a name="output_eip_public_ip"></a> [eip\_public\_ip](#output\_eip\_public\_ip) | Contains the public IP address |
| <a name="output_id"></a> [id](#output\_id) | The ID of the subnet |
| <a name="output_ipv4_cidr_block"></a> [ipv4\_cidr\_block](#output\_ipv4\_cidr\_block) | IPv4 CIDR block assigned to the subnet |
| <a name="output_ipv6_cidr_block"></a> [ipv6\_cidr\_block](#output\_ipv6\_cidr\_block) | IPv6 CIDR block assigned to the subnet |
| <a name="output_nat_gateway_id"></a> [nat\_gateway\_id](#output\_nat\_gateway\_id) | The ID of the NAT Gateway |
| <a name="output_nat_gateway_network_interface_id"></a> [nat\_gateway\_network\_interface\_id](#output\_nat\_gateway\_network\_interface\_id) | The ID of the network interface associated with the NAT gateway |
| <a name="output_nat_gateway_private_ip"></a> [nat\_gateway\_private\_ip](#output\_nat\_gateway\_private\_ip) | The private IP address of the NAT Gateway |
| <a name="output_nat_gateway_public_ip"></a> [nat\_gateway\_public\_ip](#output\_nat\_gateway\_public\_ip) | The public IP address of the NAT Gateway |
| <a name="output_network_acl_association_id"></a> [network\_acl\_association\_id](#output\_network\_acl\_association\_id) | The ID of the association between the subnet and its network ACL |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The ID of the AWS account that owns the subnet |
| <a name="output_route_table_arn"></a> [route\_table\_arn](#output\_route\_table\_arn) | The ARN of the route table |
| <a name="output_route_table_association_id"></a> [route\_table\_association\_id](#output\_route\_table\_association\_id) | The ID of the association between the route table and the subnet |
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | The ID of the route table |
| <a name="output_route_table_owner_id"></a> [route\_table\_owner\_id](#output\_route\_table\_owner\_id) | The ID of the AWS account that owns the route table |
| <a name="output_routes"></a> [routes](#output\_routes) | Map of routes created and their attributes |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/LICENSE) for full details.
