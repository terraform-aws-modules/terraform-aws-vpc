# IPAM Driven Addressing

The VPC CIDR and every subnet CIDR come from Amazon VPC IP Address Manager rather than
being written by hand.

Hand-allocated CIDRs are how organisations end up with overlapping address space they
cannot route between. IPAM allocates from a hierarchy, tracks what is in use, and refuses
to hand out an overlap.

## Architecture

```
   IPAM pool  10.0.0.0/8        top level, the whole private estate
     └── regional pool 10.0.0.0/16   eu-west-1
           └── VPC  allocated a /20 automatically
                 ├── public  subnets   carved from the allocation
                 └── private subnets   carved from the allocation
```

## Why this shape

The multi-VPC whitepaper puts address planning first, before connectivity or security:
"In order to build a scalable multi-account multi-VPC network design, IP address planning
and management is imperative." Its guidance is to plan up front, use a hierarchy, keep
on-premises and cloud ranges distinct, and "proactively prevent and track overlapping IP
CIDRs".

IPAM is how that is enforced rather than documented. Asking for a netmask length instead
of a CIDR means the module cannot be given an overlapping range in the first place.

## The awkward part, stated plainly

Subnet CIDRs have to be derived from the allocated VPC CIDR, and that CIDR is not known
until apply. Anything that uses it to decide **how many** subnets to create fails with
`Invalid count argument`, because the count would depend on an unknown value.

The way around it is to keep the subnet **keys** static, taken from the availability zone
list, and let only the CIDR **values** be unknown. That is what this pattern does, and it
is another argument for map keys over positional lists: a list of CIDRs derived from an
IPAM allocation cannot be counted at plan time, but a map keyed by zone can.

## Trade-offs

- The VPC CIDR is not visible until after apply, which makes review harder.
- Changing the netmask length replaces the VPC.
- IPAM pools are themselves shared infrastructure, usually owned by a networking account,
  so this pattern creates them only to be self-contained.

## Requests this answers

- [#1277](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1277) Support for VPC resource planning IPAM pools and IPAM-based subnet provisioning
- [#1153](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1153) Ability to configure IPAM exclusively for IPv4 or IPv6
- [#1175](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1175) IPv6 IPAM allocation

## References

- [What is IPAM?](https://docs.aws.amazon.com/vpc/latest/ipam/what-it-is-ipam.html)
- [Amazon VPC IP Address Manager Best Practices](https://aws.amazon.com/blogs/networking-and-content-delivery/amazon-vpc-ip-address-manager-best-practices/)
- [IP address planning and management](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/ip-address-planning-and-management.html)

## Usage

```bash
$ terraform init && terraform apply
```
