# Shared VPC

One account owns the VPC and the subnets. Other accounts launch resources into them.

The networking team keeps control of addressing, routing and inspection. Application
teams get subnets they can use but cannot re-route. This is AWS's recommended answer to
VPC sprawl, and it is why both subnet sub-modules take `share_subnet` and
`resource_share_arn`. Sharing is per subnet, so the group sets a default for the tier and
any subnet in it can be held back.

## Architecture

```
   networking account                         application accounts
   ┌────────────────────────────────┐
   │  VPC, routing, NAT, inspection │
   │                                │         ┌─────────────────────┐
   │  app-team-a subnets ───────────┼────────▶│ account 1111…       │
   │  app-team-b subnets ───────────┼────────▶│ account 2222…       │
   │                                │         └─────────────────────┘
   │  shared with AWS RAM           │           launch instances,
   └────────────────────────────────┘           cannot change routes
```

## Why this shape

- **Address space is finite and routing is global.** Every extra VPC is another CIDR to
  allocate, another attachment, and another set of route table entries at the hub.
  Sharing subnets keeps one VPC per environment rather than one per team.
- **The boundary is exactly right.** A participant can create resources in a shared
  subnet but cannot modify, describe in full, or delete the subnet, the route tables, or
  the gateways. Routing stays with the owner.
- **Sharing is per subnet, not per VPC**, so different teams get different subnets in the
  same VPC, and a subnet holding sensitive infrastructure is simply not shared.

## Trade-offs and limitations

- Participants cannot see or change routing, which is the point, but it means egress
  problems are the owner's to debug.
- Some resources cannot be created in a shared subnet by a participant, and security
  group references across accounts have their own rules. Check per service.
- The owner sees the network interfaces and security groups that participants attach, so
  the blast radius of a shared subnet is shared too.
- Quotas: 100 participant accounts per VPC, and 100 subnets shared with one account, both
  adjustable.

## Requests this answers

- Not directly in the backlog, but `share_subnet` exists in the sub-module and nothing
  else exercised it. A feature with no pattern is a feature with no proof.

## References

- [Share your VPC with other accounts](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-sharing.html)
- [Building a Scalable and Secure Multi-VPC AWS Network Infrastructure](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/welcome.html)

## Applying this one

Unlike the other patterns, this applies cleanly with `participant_account_ids` left
empty. It creates the resource share and shares the subnets into it, but with no
principal attached nothing is actually shared, so the pattern demonstrates nothing. It
also needs RAM sharing enabled with AWS Organizations to share to an account by ID.

## Usage

Set `participant_account_ids` to the accounts that should receive the subnets, then:

```bash
$ terraform init && terraform apply
```
