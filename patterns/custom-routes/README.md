# Custom Routes

Add your own routes to a tier's route table: a transit gateway, a peering connection, an
on-premises prefix, an IPv6 egress-only gateway, alongside the default route.

This is the single most requested thing the root module cannot do. It owns the route set
for each tier, so there is no way to add to it.

## Architecture

```
   VPC 10.0.0.0/16
   ┌────────────────────────────────────────────────────────────┐
   │  private subnets, one shared route table:                  │
   │                                                            │
   │    0.0.0.0/0      → NAT gateway        (the usual default) │
   │    192.168.0.0/16 → transit gateway    (on-premises)       │
   │    172.16.0.0/12  → peering connection (another VPC)       │
   │    ::/0           → egress-only IGW    (IPv6 egress)       │
   └────────────────────────────────────────────────────────────┘
```

## Why this shape

`routes` is a map, so a route is added by adding a key and removed by removing one.
Nothing about the module decides which routes a tier is allowed to have, and the map key
is the Terraform address, so adding a fifth route does not disturb the other four.

That last property matters more than it sounds. With `count`-indexed routes, inserting a
route in the middle shifts every route after it, and Terraform destroys and recreates
them. That is [#1132](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1132)
and [#1070](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1070).

## Requests this answers

- [#1043](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1043) Support for custom routes
- [#1130](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1130) How do I add routes to the private route tables
- [#1226](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1226) Private route tables when using an egress VPC
- [#1265](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1265) Add a private_subnet_route_table_routes option
- [#1080](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1080) Cannot define a default route table route with an IPv6 CIDR
- [#1283](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1283) Associating the public route table to a database subnet

## References

- [Route table concepts](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html)
- [Example routing options](https://docs.aws.amazon.com/vpc/latest/userguide/route-table-options.html)

## Usage

```bash
$ terraform init && terraform apply
```
