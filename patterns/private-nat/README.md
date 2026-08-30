# Private NAT Gateway

Reach an on-premises network from a VPC whose own addresses are not allow-listed, by
translating traffic to an address from a range the far side does accept.

This is not a cheaper public NAT gateway. It never touches the internet, has no Elastic
IP, and needs no internet gateway.

## Architecture

```
   VPC                                              on-premises network
   primary   10.0.0.0/16    (not allow-listed)      accepts only 100.64.1.0/24
   secondary 100.64.1.0/24  (allow-listed)                     ▲
   ┌───────────────────────────────────────────┐               │
   │  workload subnets  10.0.0.0/24 …          │               │
   │    192.168.0.0/16 → private NAT gateway   │        ┌──────┴──────┐
   │                  │                        │        │     VGW     │
   │                  ▼                        │        └──────┬──────┘
   │  NAT subnet  100.64.1.0/28                │               │
   │    private NAT gateway (no EIP)           │───────────────┘
   │    192.168.0.0/16 → VGW                   │
   └───────────────────────────────────────────┘
```

Traffic leaves a workload subnet, is translated by the gateway to an address inside
`100.64.1.0/24`, and only then reaches the virtual private gateway. The far side sees a
source address it allows.

## Route tables

| Route table | Entries | Count |
| ----------- | ------- | ----- |
| Workload subnets | `192.168.0.0/16` to the private NAT gateway in that zone | one per zone |
| NAT gateways' subnets | `192.168.0.0/16` to the virtual private gateway | **1**, shared |

Two kinds of table, and the order matters: translate first, then route on-premises.
Pointing the workload subnets straight at the gateway would send un-translated addresses
that the far side drops.

The counts follow from where the routes are written. Each workload subnet points at the
gateway in its own zone, so those routes differ and each subnet takes a table. The NAT
subnets all point at the virtual private gateway, which is regional, so their routes are
identical and one table serves them.

## Why this shape

AWS: "Instead of assigning each instance a separate IP address from the allow-listed
range, you can route traffic from the subnet through a private NAT gateway with an IP
address from the allow-listed range."

The gateway takes its address from the subnet it sits in, which is why that subnet comes
from the secondary, allow-listed CIDR while the workloads stay in the primary one.

The same shape solves overlapping CIDRs between two VPCs, with a transit gateway in
place of the virtual private gateway. See the AWS reference below.

## Trade-offs and limitations

- **Regional NAT gateways cannot do this.** AWS: "Regional NAT gateways do not support
  private NAT. If you need private NAT, use zonal NAT gateways instead." This is the one
  case where zonal is required rather than merely cheaper.
- A private NAT gateway is still zonal, so it needs one per zone for availability.
- The allow-listed range must be large enough for the gateways, and it consumes a
  secondary CIDR on the VPC.

## Requests this answers

- [#1040](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1040) Private NAT Gateway provisioning is not supported
- [#1060](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1060) Enable the setup of fully private NAT Gateways
- [#1103](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1103) Alternate or optional private NAT gateways
- [#1106](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1106) Adding support for private NAT gateways

## References

- [Access your network using allow-listed IP addresses](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-scenarios.html#private-nat-allowed-range)
- [Enable communication between overlapping networks](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-scenarios.html#private-nat-overlapping-networks)

## Usage

```bash
$ terraform init && terraform apply
```

Creates a NAT gateway and a virtual private gateway, which cost money. Run
`terraform destroy` when finished.
