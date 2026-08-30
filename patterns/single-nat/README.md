# Single NAT Gateway

One NAT gateway for the whole VPC. The cheapest egress arrangement, and the one that
trades availability for cost.

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
   │  ┌─────────────────┴──┐                                      │
   │  │ public   NAT + EIP │   (no gateway in b or c)             │
   │  └─────────┬──────────┘                                      │
   │            │                                                 │
   │   ONE route table:  0.0.0.0/0 → the single NAT gateway       │
   │       │             │                    │                   │
   │  private a     private b            private c                │
   └──────────────────────────────────────────────────────────────┘
```

## Route tables

| Route table | Entries | Count |
| ----------- | ------- | ----- |
| Public subnets | `0.0.0.0/0` to the internet gateway | **1**, shared |
| Private subnets | `0.0.0.0/0` to the one NAT gateway | **1**, shared: every subnet routes to the same target |

Because every private subnet routes to the same gateway, the routes are identical again
and one table serves all of them. Both tiers declare their routes once on the group, and
that is what produces the single shared table.

## Why this shape

AWS describes the trade directly: "if the instances in the private subnet in
Availability Zone A also need to reach the internet, you can create a route from this
subnet to the NAT gateway in Availability Zone B. Alternatively, you can improve
resiliency by creating a NAT gateway in each Availability Zone."

This pattern takes the first option deliberately. It is the right choice for
development and test environments, and for any workload where an hour of lost egress
costs less than two extra gateways.

## Trade-offs

- **A zone failure removes egress for the entire VPC**, not just for one zone.
- **Cross-zone data processing charges** apply to traffic from the other two zones.
- All egress concentrates on one gateway's port and bandwidth limits.

If you want one gateway's simplicity without the availability cost, use
[regional-nat](../regional-nat/) instead, which is a single ID that spans zones.

## Requests this answers

- [#1065](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1065) Custom amount of NAT gateways
- [#1196](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1196) One NAT per subnet, docs update or code fix
- [#1257](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1257) NAT gateways created in the wrong subnets, should be able to choose

Placement here is just which subnet sets `create_nat_gateway`, so "the wrong subnet"
stops being possible.

## References

- [NAT gateway use cases](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-scenarios.html)

## Usage

```bash
$ terraform init && terraform apply
```

Creates a NAT gateway, which costs money. Run `terraform destroy` when finished.
