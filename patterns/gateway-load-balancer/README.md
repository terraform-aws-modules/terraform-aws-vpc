# Gateway Load Balancer Inspection

Send traffic through a fleet of third-party virtual appliances using a Gateway Load
Balancer endpoint, rather than through a managed firewall.

The routing is the same shape as [network-firewall](../network-firewall/). Only the
inspection target differs: a Gateway Load Balancer endpoint instead of a firewall
endpoint. That the two patterns share a shape is the point.

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
        │  10.0.4.0/24 → GWLB endpoint in the same AZ      │
        └────────────────────────┬─────────────────────────┘
                                 │
   VPC 10.0.0.0/16               │
   ┌─────────────────────────────┼──────────────────────────────────┐
   │   endpoint subnet 10.0.8.0/24                                  │
   │      GWLB endpoint (vpce-…)                                    │
   │      0.0.0.0/0 → IGW                                           │
   │                             │                                  │
   │   application subnet 10.0.4.0/24                               │
   │      0.0.0.0/0 → GWLB endpoint in the same AZ                  │
   └────────────────────────────────────────────────────────────────┘
```

## Route tables

| Route table | Entries |
| ----------- | ------- |
| Internet gateway (edge) | each application subnet's CIDR to the endpoint in that zone |
| Endpoint subnet | `0.0.0.0/0` to the internet gateway, returning inspected traffic |
| Application subnet | `0.0.0.0/0` to the endpoint in the same zone |

## Why this shape

AWS requires the separation explicitly: "You must create the Gateway Load Balancer
endpoint and the application servers in different subnets, which enables you to configure
the Gateway Load Balancer endpoint as the next hop in the route table for the application
subnet."

And the traffic flow it produces: "All traffic entering the service consumer VPC through
the internet gateway is first routed to the Gateway Load Balancer endpoint and then
routed to the destination subnet. Similarly, all traffic leaving the application servers
is routed to the Gateway Load Balancer endpoint before it is routed back to the internet."

The endpoint subnet's own table sends inspected traffic onward, with the local route
covering traffic bound for the application servers.

## Trade-offs

- The appliance fleet, the Gateway Load Balancer and its endpoint service all live in a
  separate provider VPC, which this pattern consumes by service name rather than creates.
- An endpoint per zone, each billed hourly plus data processing.

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

- [#1271](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1271) Gateway Load Balancer subnet association

Worth noting that this needed no new sub-module. The `route-table` sub-module built for
Network Firewall covers it unchanged, because gateway edge association is a general VPC
feature rather than a firewall one.

## References

- [Access an inspection system using a Gateway Load Balancer endpoint](https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-load-balancer-endpoints.html)
- [Configure middlebox traffic routing and inspection in a VPC](https://docs.aws.amazon.com/vpc/latest/userguide/gwlb-route.html)
- [Inspecting inbound traffic from the internet using firewall appliances with Gateway Load Balancer](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/inspecting-inbound-traffic-fa.html)

## Usage

Set `gwlb_service_name` to the endpoint service of your appliance fleet, then:

```bash
$ terraform init && terraform apply
```
