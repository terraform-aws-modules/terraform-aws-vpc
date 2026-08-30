# Dual Stack and IPv6

Subnets that carry both IPv4 and IPv6, plus an IPv6-only subnet, with the right egress
path for each.

IPv6 egress is not NAT. There is no address translation, so a private IPv6 subnet uses an
**egress-only internet gateway** instead, and an IPv6-only subnet needs **DNS64 and NAT64**
to reach anything that is still IPv4.

## Architecture

```
   VPC 10.0.0.0/16 + 2001:db8::/56
   ┌────────────────────────────────────────────────────────────────────┐
   │  public       dual stack                                           │
   │    0.0.0.0/0 → IGW          ::/0 → IGW        NAT gateway lives here│
   │                                                                    │
   │  private      dual stack                                           │
   │    0.0.0.0/0 → NAT gateway  ::/0 → egress-only IGW                  │
   │                                                                    │
   │  ipv6-only    no IPv4 address at all                               │
   │    ::/0            → egress-only IGW                               │
   │    64:ff9b::/96    → NAT gateway     NAT64, to reach IPv4 hosts    │
   └────────────────────────────────────────────────────────────────────┘
```

## Route tables

| Subnet | IPv4 default | IPv6 default | NAT64 |
| ------ | ------------ | ------------ | ----- |
| public | internet gateway | internet gateway | not needed |
| private | NAT gateway | egress-only internet gateway | not needed |
| ipv6-only | none, there is no IPv4 | egress-only internet gateway | `64:ff9b::/96` to the NAT gateway |

## Why this shape

- **An egress-only internet gateway is the IPv6 equivalent of a NAT gateway** for
  outbound-only traffic. It is stateful and free, and it exists because IPv6 addresses are
  globally routable so translation is unnecessary, but you still want to block inbound.
- **DNS64 and NAT64 are how an IPv6-only subnet reaches IPv4.** With `enable_dns64` the
  resolver synthesises an IPv6 address inside `64:ff9b::/96` for IPv4-only destinations,
  and a route sends that prefix to a NAT gateway, which performs the translation.
- **DNS64 without the NAT64 route is a trap.** Names resolve, connections hang. That is
  issue [#972](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/972), and
  it is why the route is explicit here rather than implied by the flag.

## Trade-offs

- An IPv6-only subnet still needs a NAT gateway for NAT64, so it does not remove the NAT
  gateway bill, it only shrinks IPv4 consumption.
- Not every AWS service supports IPv6-only subnets. Check before committing a tier.
- `64:ff9b::/96` is the well-known prefix and is not configurable.

## Requests this answers

- [#972](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/972) Confusing DNS64 behaviour with public subnets
- [#1049](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1049) Unable to migrate from IPv4 to IPv6
- [#1185](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1185) How to switch an IPv4 VPC to dual-stack

## References

- [IPv6 support for your VPC](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-migrate-ipv6.html)
- [Egress-only internet gateways](https://docs.aws.amazon.com/vpc/latest/userguide/egress-only-internet-gateway.html)
- [Design and build IPv6 internet inspection architectures on AWS](https://aws.amazon.com/blogs/networking-and-content-delivery/design-and-build-ipv6-internet-inspection-architectures-on-aws/)

## Usage

```bash
$ terraform init && terraform apply
```
