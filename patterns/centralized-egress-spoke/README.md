# Centralized Egress Spoke

A spoke VPC with **no NAT gateway and no internet gateway at all**. Everything leaves
through a transit gateway to a shared egress VPC owned by the networking team.

This is the most common VPC shape in a large organisation, and the root module cannot
express it: it will create NAT gateways or nothing, and gives no way to point the private
route table somewhere else.

## Architecture

```
   spoke VPC 10.0.0.0/16                        egress VPC (elsewhere)
   ┌──────────────────────────────────┐         ┌──────────────────────┐
   │  private subnets                 │         │  NAT gateways        │
   │    0.0.0.0/0    → TGW ───────────┼────────▶│  internet gateway    │
   │    10.0.0.0/8   → TGW            │   TGW   │  inspection          │
   │                                  │         └──────────────────────┘
   │  tgw attachment subnets  /28     │
   │    local only                    │
   │                                  │
   │  NO internet gateway             │
   │  NO NAT gateway                  │
   └──────────────────────────────────┘
```

## Route tables

| Route table | Entries |
| ----------- | ------- |
| Private subnets | `0.0.0.0/0` to the transit gateway, plus the internal summary route |
| Attachment subnets | local only |

Separate small subnets hold the transit gateway attachment. AWS recommends a dedicated
`/28` per zone for attachments so the attachment ENIs do not consume workload address
space and so the attachment subnet's routing can differ from the workloads'.

## Why this shape

AWS: centralized egress means "building centralized egress points for accessing the
internet" so that NAT gateways, inspection and public addresses are owned and paid for
once rather than per VPC. The spoke's job is to have no egress of its own.

Two consequences worth stating:

- **No internet gateway.** `create_igw` is left at its default, so none is created. A
  spoke with an internet gateway is a spoke that can bypass inspection.
- **The default route target is the transit gateway**, which means the spoke depends on
  the hub's route tables to actually reach anything.

## Trade-offs

- Every byte crosses the transit gateway and is billed per gigabyte in addition to NAT
  processing at the hub.
- The spoke cannot reach the internet if the hub is misconfigured, which is the point,
  but it makes the hub a hard dependency.
- Attachment subnets consume a `/28` per zone.

## Requests this answers

- [#1226](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1226) Private route tables when using an egress VPC
- [#1031](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1031) NAT routing tables and associations are still created even when `enable_nat_gateway = false`

## References

- [Building a Scalable and Secure Multi-VPC AWS Network Infrastructure](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/welcome.html)
- [Centralized egress](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/centralized-egress-to-internet.html)

## Usage

```bash
$ terraform init && terraform apply
```
