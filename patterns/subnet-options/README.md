# Subnet Options

This one is not an architecture. It is a coverage pattern: it exists to exercise the
inputs and outputs of [`modules/subnet`](../../modules/subnet) and
[`modules/subnets`](../../modules/subnets) that no other pattern or example reaches, so
that a change to either has something that fails when it breaks them.

The other directories under `patterns/` each start from a network shape and justify it.
This one starts from the sub-module's variable file and works backwards, so the topology
below is the smallest one that lets every argument be set to a value the provider
accepts. Do not copy it as a network design.

## Why it exists

`modules/subnet` takes 48 inputs and returns 22 outputs. Most tiers are built from the
[`subnets`](../../modules/subnets) group sub-module instead, which leaves the primitive
reached directly by only two other patterns, between them setting 9 of those inputs.
Nothing under `examples/` uses it at all. Several of the untouched arguments are ones
where bugs were found and fixed, which means the fixes were protected by nothing.

An argument that is never set is an argument that can regress silently. A dynamic block
whose `for_each` is empty is never evaluated, so `terraform validate` passing over the
other patterns says nothing about whether the block inside it is correct. All six
timeout blocks in the sub-module were in exactly that position.

With this pattern in place 30 of the 48 inputs are set and all 22 outputs are read. Of
the rest, some need something no standalone root module can create and are listed at the
bottom, and some are reached through the group sub-module rather than here.

## What it covers

| Input | Where | Why it needs saying |
| ----- | ----- | ------------------- |
| `timeouts` | `external_eip_subnet` | subnet create and delete |
| `route_table_timeouts` | `external_eip_subnet` | route table create, update and delete |
| `route_timeouts` | `external_eip_subnet` | the default every route in the map inherits |
| `routes[*].timeouts` | `external_eip_subnet`, route `ipv4` | a single route overriding that default |
| `route_table_association_timeouts` | `external_eip_subnet` | association create, update and delete |
| `cidr_reservations` | `external_eip_subnet` | one `explicit`, one `prefix` |
| `nat_gateway_allocation_id` with `create_eip = false` | `external_eip_subnet` | an address allocated outside the sub-module |
| `route_table_propagating_vgws` | `external_eip_subnet` | needs a gateway attached to the VPC |
| `availability_zone_id` | both subnets | mutually exclusive with `availability_zone` |
| `private_dns_hostname_type_on_launch` | `external_eip_subnet` | `resource-name` |
| `enable_resource_name_dns_a_record_on_launch` | `external_eip_subnet` | only accepted alongside `resource-name` |
| `enable_resource_name_dns_aaaa_record_on_launch` | `external_eip_subnet` | needs IPv6 on the subnet |
| `eip_tags` | `managed_eip_subnet` | only has something to tag when `create_eip` is true |
| `nat_gateway_tags` | both subnets | |
| `eip_timeouts` | `managed_eip_subnet` | Elastic IP read, update and delete, and it has no create |
| `nat_gateway_timeouts` | `managed_eip_subnet` | NAT gateway create, update and delete |
| `create_network_acl_association`, `network_acl_id` | `managed_eip_subnet` | joins an ACL rather than creating one |
| `create = false` | `disabled` | produces no resources and no output errors |
| `create = false` on the group | `disabled_group` | the same for `modules/subnets`, including its route table and network ACL |
| `create_network_acl`, `network_acl_rules`, `network_acl_tags` | `acl_group` | the group sub-module's own ACL, with TCP, ICMP, IPv6 and egress rules |

The outputs newly read here are `arn`, `owner_id`, `ipv6_cidr_block`, `routes`,
`network_acl_association_id`, `route_table_arn`, `route_table_association_id`,
`route_table_owner_id`, the seven `eip_*` outputs, `nat_gateway_network_interface_id`
and `nat_gateway_public_ip`. The disabled instance is read too, which is what shows that
every output degrades to null rather than erroring when nothing is created.

## The two Elastic IP arrangements

The NAT gateway address can come from either side of the sub-module boundary, and the
two are mutually exclusive, so covering both takes two subnets.

| | `external_eip_subnet` | `managed_eip_subnet` |
| --- | --- | --- |
| `create_eip` | `false` | `true`, the default |
| Address owned by | the caller, an `aws_eip` in this root module | the sub-module |
| `nat_gateway_allocation_id` | required, and the apply fails without it | must stay unset |
| `eip_tags` | has nothing to tag | tags the allocation |

Bringing your own address is what you want when the address has to survive the subnet:
an allowlist entry at a partner, a BYOIP range, or a NAT gateway being rebuilt without
its public address changing.

Note that `create_eip` is also ignored when `nat_gateway_connectivity_type` is
`private`, because a private NAT gateway takes no allocation at all. The
[private-nat](../private-nat/) pattern covers that path.

## Timeout precedence

Routes are the only resource here with two sources of timeouts, and the per-route value
wins:

```
routes = {
  ipv4 = { ..., timeouts = { create = "6m", ... } }   # uses 6m
  ipv6 = { ... }                                      # uses route_timeouts, 4m
}

route_timeouts = { create = "4m", ... }
```

Both branches are set in this pattern deliberately. With only one of them in place the
other side of the conditional is never evaluated and never checked.

## What is still not covered

These inputs need something that cannot be created from a standalone root module, so
they stay uncovered rather than making the pattern unappliable:

- `outpost_arn`, `customer_owned_ipv4_pool`, `map_customer_owned_ip_on_launch` and
  `enable_lni_at_device_index` need an Outpost. See [`examples/outpost`](../../examples/outpost).
- `eip_address`, `eip_public_ipv4_pool` and `eip_customer_owned_ipv4_pool` need a
  provisioned BYOIP or customer owned pool.
- `eip_associate_with_private_ip` names a private address that a network interface must
  already hold, and the only interface the sub-module creates belongs to the NAT gateway
  it is passed to.
- `region` overrides the Region the provider is configured with. Every pattern here runs
  in one Region, so there is nothing for it to override.

## Usage

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

This creates two NAT gateways and two Elastic IP addresses, which cost money. Run
`terraform destroy` when finished. The virtual private gateway and the network ACL are
free, and no VPN connection is created.
