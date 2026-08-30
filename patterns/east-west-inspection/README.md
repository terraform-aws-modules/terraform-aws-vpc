# East-West Inspection

Inspect traffic **between two subnets in the same VPC**, not just traffic leaving it.

Historically this was impossible. Same-VPC traffic always took the implicit local route
and there was no way to interpose anything. VPC routing enhancements changed that: you
can now add routes more specific than local, and send subnet-to-subnet traffic through a
middlebox first.

## Architecture

```
   VPC 10.0.0.0/16
   ┌────────────────────────────────────────────────────────────────────┐
   │   app subnet 10.0.0.0/24                                           │
   │     10.0.1.0/24 → firewall endpoint      (not the local route)     │
   │            │                                                       │
   │            ▼                                                       │
   │   firewall subnet 10.0.8.0/24                                      │
   │     keeps only the local route, so inspected traffic continues     │
   │            │                                                       │
   │            ▼                                                       │
   │   db subnet  10.0.1.0/24                                           │
   │     10.0.0.0/24 → firewall endpoint      (the return leg)          │
   └────────────────────────────────────────────────────────────────────┘
```

Both directions are redirected, which is what makes the path symmetric. Inspecting only
one leg gives a stateful engine half a conversation, which it cannot evaluate.

## Route tables

| Subnet | Entry | Purpose |
| ------ | ----- | ------- |
| app | `10.0.1.0/24` to the firewall endpoint | outbound leg to the database tier |
| db | `10.0.0.0/24` to the firewall endpoint | return leg back to the app tier |
| firewall | local only | inspected traffic carries on to its real destination |

The firewall subnet **must** keep its plain local route. Giving it a redirect too would
loop traffic back into the firewall.

## Why this shape

AWS describes the enhancement as being able to "configure more specific routes at a
subnet route table level" and to "replace target for the local destination with a
middlebox such as firewall endpoint", with the key use case being "insertion of a
middlebox between two subnets for inter-subnet traffic (east-west) inspection".

This pattern uses the more specific route form, which is the simpler of the two and
sufficient when you know which tiers must be inspected against each other. Replacing the
local route target is the broader hammer, useful when every subnet in the VPC must be
inspected against every other.

AWS frames the motivating case as tiers at different trust levels: "web tier (low trust),
application tier (medium trust) and database tier (high trust)".

## Trade-offs

- Every inspected flow crosses the firewall endpoint twice, once per direction, and is
  billed for data processing both times.
- The routes are per subnet pair. Inspecting many tiers against each other grows
  quadratically unless you replace the local route instead.
- The firewall subnet still cannot host anything else.

## Requests this answers

This is not in the issue backlog, which is itself the finding: users have not asked for
it because the module gave them no way to imagine it. It is standard practice in
regulated environments and the module cannot express it at all today.

## References

- [Deployment models for AWS Network Firewall with VPC routing enhancements](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall-with-vpc-routing-enhancements/)
- [Configure middlebox traffic routing and inspection in a VPC](https://docs.aws.amazon.com/vpc/latest/userguide/gwlb-route.html)

## Usage

```bash
$ terraform init && terraform apply
```

Creates a Network Firewall, which costs money. Run `terraform destroy` when finished.
