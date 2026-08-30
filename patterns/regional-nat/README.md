# Regional NAT Gateway

Private subnets across every availability zone egress through a single NAT gateway that
is scoped to the VPC rather than to a subnet.

## Architecture

```
                             internet
                                 │
                          ┌──────┴──────┐
                          │     IGW     │   required, but no public subnet is
                          └──────┬──────┘
                                 │
                  ┌──────────────┴──────────────┐
                  │  regional NAT gateway       │   one resource, spans all zones
                  │  (AWS manages its own       │   expands and contracts with
                  │   route table to the IGW)   │   where your workloads are
                  └──────────────┬──────────────┘
                                 │
   VPC 10.0.0.0/16               │
   ┌─────────────────────────────┼──────────────────────────────────┐
   │                             │                                  │
   │  ONE route table:  0.0.0.0/0 → the regional NAT gateway        │
   │        │                    │                    │             │
   │  private 1a           private 1b           private 1c          │
   │  10.0.0.0/24          10.0.1.0/24          10.0.2.0/24         │
   └────────────────────────────────────────────────────────────────┘
```

Compare with the zonal arrangement, which needs a public subnet, a NAT gateway, an
Elastic IP and a route table *per zone*, and needs all four added again by hand every
time workloads reach a new zone.

## Route tables

| Route table | Entries | Count |
| ----------- | ------- | ----- |
| Private subnets | `0.0.0.0/0` to the regional NAT gateway | **1**, shared by every zone |
| Regional NAT gateway's own table | pre-configured route to the internet gateway | created and managed by AWS, not by Terraform |

The private tier needs only one route table because every subnet routes to the same
gateway ID. AWS states this directly: "Use a single NAT ID across all Availability Zones
that have network interfaces, so you can use the same route entry for subnets across
different Availability Zones."

## Why this shape

- **No public subnets.** "You do not need a public subnet in your VPC to host a regional
  NAT Gateway, which reduces chances of misconfiguring private resources in subnets with
  public connectivity." The VPC still needs an internet gateway, because AWS gives the
  gateway its own route table pre-configured with a route to it.
- **Automatic zone expansion.** The gateway detects an interface in a new zone and
  expands into it, then contracts when the zone empties. Nothing to add by hand.
- **It is the recommended default.** "Consider using Regional NAT Gateways for all use
  cases except those that require private connectivity."
- **Higher limits.** 32 IP addresses per zone against 8 for a zonal gateway, each worth
  another 55,000 concurrent connections to a given destination.

Automatic mode is used here, which AWS recommends. Supplying
`availability_zone_addresses` switches the gateway to manual mode, where you own IP
address management and zone expansion yourself.

## Trade-offs and limitations

- **No private NAT.** Regional gateways do not offer private connectivity. Use a zonal
  NAT gateway for that, which in this module means `create_nat_gateway` on a subnet.
- **Expansion is not instant.** Up to 60 minutes to reach a newly used zone. Until then
  that zone's traffic is processed cross-zone by an existing one.
- **Not available in constrained availability zones.**
- **Cross-zone data processing** applies while the gateway has not yet expanded.

## Requests this answers

- [#1269](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1269) Support for Regional NAT Gateway
- [#1281](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1281) Include Regional NAT Gateway Feature
- [#1270](https://github.com/terraform-aws-modules/terraform-aws-vpc/pull/1270) the pending pull request against the root module

## References

- [Regional NAT gateways for automatic multi-AZ expansion](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html)
- [Introducing Amazon VPC Regional NAT Gateway](https://aws.amazon.com/blogs/networking-and-content-delivery/introducing-amazon-vpc-regional-nat-gateway/)

## Usage

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

This creates a NAT gateway, which costs money. Run `terraform destroy` when finished.
