# NAT Gateway Per Availability Zone

The highly available egress arrangement: a NAT gateway in every zone, and private
subnets that egress through the gateway in their own zone.

## Architecture

```
                    internet
                        │
                 ┌──────┴──────┐
                 │     IGW     │
                 └──────┬──────┘
   VPC 10.0.0.0/16      │
   ┌────────────────────┼─────────────────────────────────────────┐
   │   zone a           │       zone b              zone c        │
   │  ┌─────────────────┴──┐  ┌──────────────┐  ┌──────────────┐  │
   │  │ public   NAT + EIP │  │ public  NAT  │  │ public  NAT  │  │
   │  │ 0.0.0.0/0 → IGW    │  │              │  │              │  │
   │  └─────────┬──────────┘  └──────┬───────┘  └──────┬───────┘  │
   │            │                    │                 │          │
   │  ┌─────────┴──────────┐  ┌──────┴───────┐  ┌──────┴───────┐  │
   │  │ private            │  │ private      │  │ private      │  │
   │  │ 0.0.0.0/0 → NAT a  │  │ → NAT b      │  │ → NAT c      │  │
   │  └────────────────────┘  └──────────────┘  └──────────────┘  │
   └──────────────────────────────────────────────────────────────┘
```

## Route tables

| Route table | Entries | Count |
| ----------- | ------- | ----- |
| Public subnets | `0.0.0.0/0` to the internet gateway | **1**, shared: every public subnet routes identically |
| Private subnets | `0.0.0.0/0` to the NAT gateway in the same zone | **3**, one per subnet: the target differs per zone |

This is the case that makes per subnet route tables necessary. The moment each zone
egresses through its own gateway, the routes stop being identical and a shared table
cannot express them. It is why `subnet` creates a route table per subnet by default.

## Why this shape

AWS: "you can improve resiliency by creating a NAT gateway in each Availability Zone
that contains resources that require internet access." A zonal NAT gateway lives in one
zone, so a zone failure takes egress with it for anything routed through it. Keeping
traffic in-zone also avoids cross-zone data processing charges.

## Trade-offs

- One NAT gateway and one Elastic IP per zone, billed hourly each.
- Every new zone means another gateway, another address and another route, added by
  hand. [Regional NAT](../regional-nat/) removes that work.

## Requests this answers

- The default arrangement the root module produces with `one_nat_gateway_per_az`

## References

- [NAT gateway use cases](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-scenarios.html)
- [Example: VPC with servers in private subnets and NAT](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-example-private-subnets-nat.html)

## Usage

```bash
$ terraform init && terraform apply
```

Creates NAT gateways, which cost money. Run `terraform destroy` when finished.
