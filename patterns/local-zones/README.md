# Local Zones

Subnets in a Local Zone alongside subnets in the parent Region, in one VPC.

A Local Zone subnet is an ordinary subnet in an unusual place. What makes it awkward is
that it cannot borrow the Region's egress: outbound traffic leaves from the Local Zone,
so it needs its own gateway and its own Elastic IP from that zone's network border group.

## Architecture

```
   VPC 10.0.0.0/16
   ┌──────────────────────────────────────────────────────────────────┐
   │  PARENT REGION  eu-west-1a / 1b                                  │
   │    public   → IGW                                                │
   │    private  → NAT gateway in the Region                          │
   │                                                                  │
   │  LOCAL ZONE  eu-west-1-lax-1a                                    │
   │    public   → IGW          EIP from the zone's border group      │
   │    private  → NAT gateway in the Local Zone, not the Region      │
   └──────────────────────────────────────────────────────────────────┘
```

## Why it needs its own everything

- **Egress is local.** AWS: "Outbound internet traffic leaves a Local Zone from the Local
  Zone." Routing Local Zone traffic to a Region NAT gateway sends it back to the Region
  and throws away the latency benefit that motivated the Local Zone.
- **Elastic IPs are scoped to a network border group.** An address from the Region cannot
  be attached to a gateway in the Local Zone. The `subnet` sub-module takes
  `eip_network_border_group` for exactly this.
- **Route tables work normally.** AWS: "Local Zone subnets follow the same routing rules
  as Availability Zone subnets, including the use of route tables, security groups, and
  network ACLs." Nothing special is needed beyond pointing them at local targets.

## Limitations worth knowing

- **No VPC endpoints** in Local Zone subnets.
- **No transit gateway or Cloud WAN attachment** to a Local Zone subnet; attempting it is
  an error.
- **No Site-to-Site VPN.** Use a software VPN.
- IPv6 and virtual private gateway edge association are supported only in a specific list
  of Local Zones.
- MTU differs between the Local Zone and the Region, commonly 1300 bytes.

## Requests this answers

- [#1224](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1224) Single VPC, multiple network border groups, for Local Zones

The root module cannot express this: its tiers assume every subnet in a tier shares a
network border group and an egress path, and its positional lists assume the same number
of subnets per zone.

## References

- [How AWS Local Zones work](https://docs.aws.amazon.com/local-zones/latest/ug/how-local-zones-work.html)
- [AWS Local Zones features](https://aws.amazon.com/about-aws/global-infrastructure/localzones/features/)

## Usage

Set `local_zone` to a Local Zone you have enabled, then:

```bash
$ terraform init && terraform apply
```
