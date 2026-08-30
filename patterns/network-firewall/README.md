# Network Firewall Inspection

Inspect traffic in both directions with AWS Network Firewall, using the distributed
model where the firewall lives in the same VPC as the workloads.

## Architecture

```
                              internet
                                 │
                          ┌──────┴──────┐
                          │     IGW     │
                          └──────┬──────┘
                                 │
        ┌────────────────────────┴─────────────────────────┐
        │  EDGE ROUTE TABLE, associated with the gateway   │
        │  and with no subnet                              │
        │  10.0.4.0/24 → firewall endpoint in the same AZ  │
        └────────────────────────┬─────────────────────────┘
                                 │
   VPC 10.0.0.0/16               │
   ┌─────────────────────────────┼──────────────────────────────────┐
   │   firewall subnet 10.0.8.0/24    nothing else may live here    │
   │      firewall endpoint (vpce-…)                                │
   │      0.0.0.0/0 → IGW                                           │
   │                             │                                  │
   │   public subnet 10.0.4.0/24 │                                  │
   │      0.0.0.0/0 → firewall endpoint in the same AZ              │
   │                                                                │
   │   private subnet 10.0.0.0/24  (local routes only)              │
   └────────────────────────────────────────────────────────────────┘
```

Repeats identically in each of three zones.

## Route tables

| Route table | Entries | Why |
| ----------- | ------- | --- |
| Internet gateway (edge) | each public subnet's CIDR to the firewall endpoint in that subnet's zone | inbound reaches the firewall before the workload |
| Firewall subnets | `0.0.0.0/0` to the internet gateway | inspected outbound traffic leaves |
| Public subnets | `0.0.0.0/0` to the firewall endpoint in the same zone | outbound reaches the firewall |

**All three are required.** Omitting the edge table is the common mistake: outbound
still flows through the firewall so a plan looks right, but inbound goes straight from
the gateway to the workload. The firewall then sees one direction of each connection,
which a stateful engine cannot evaluate.

## Why this shape

- **The firewall subnet carries nothing else.** AWS: "the firewall subnet should not
  contain any other traffic because AWS Network Firewall is not able to inspect traffic
  from sources or destinations within a firewall subnet." No NAT gateway, no workloads.
- **One endpoint per zone.** AWS recommends "one firewall endpoint in each Availability
  Zone the customer is running workloads in", and traffic stays in-zone.
- **The edge route table is dedicated to the gateway.** AWS: "The internet gateway route
  table must be dedicated only to the internet gateway. Do not associate this route table
  with any VPC subnets." That is why it comes from the `route-table` sub-module rather
  than the `subnet` one, which always associates its table with its own subnet.

## Trade-offs

- A firewall endpoint per zone has an hourly cost per endpoint plus data processing.
- Distributed means one firewall per VPC. At scale, a centralised inspection VPC behind
  a transit gateway is usually cheaper. See the AWS deployment models reference.

## Interaction with VPC Block Public Access

This pattern depends on internet gateway ingress routing, and **VPC Block Public Access
disables it**. AWS is explicit that a subnet-level exclusion is not enough:

> when BPA is enabled, it will block traffic to subnets using ingress routing, even if
> you've set a subnet-level BPA exclusion. Subnet-level exclusions do not work for
> ingress routing.

To run this pattern alongside BPA you need a **VPC-level** exclusion, or BPA off. This is
easy to miss because nothing fails at apply: the routes are created, and inbound traffic
is simply dropped. See [Route internet traffic to a single network
interface](https://docs.aws.amazon.com/vpc/latest/userguide/igw-ingress-routing.html).

## Requests this answers

- [#978](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/978) This module does not integrate with the Network Firewall module
- [#1187](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1187) Feature to disable the default route for public subnets
- and it is the answer to give on [#1188](https://github.com/terraform-aws-modules/terraform-aws-vpc/pull/1188) and [#1190](https://github.com/terraform-aws-modules/terraform-aws-vpc/pull/1190), which each proposed a boolean for this

## References

- [Multi zone architecture with an internet gateway](https://docs.aws.amazon.com/network-firewall/latest/developerguide/arch-two-zone-igw.html)
- [Deployment models for AWS Network Firewall](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall/)
- [Route internet traffic to a single network interface](https://docs.aws.amazon.com/vpc/latest/userguide/igw-ingress-routing.html)
- [Using the NAT gateway with AWS Network Firewall](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/using-nat-gateway-with-firewall.html)

## Usage

```bash
$ terraform init && terraform apply
```

Creates a Network Firewall, which costs money. Run `terraform destroy` when finished.
