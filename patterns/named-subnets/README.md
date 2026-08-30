# Named Subnets

Subnets named and shaped by the caller, rather than drawn from a fixed set of tiers.

The root module offers seven tiers: public, private, database, redshift, elasticache,
intra and outpost. If what you need is not one of those, there is no way to ask for it.
Here the subnet keys are whatever you call them.

## Architecture

```
   VPC 10.0.0.0/16
   ┌──────────────────────────────────────────────────────────────────┐
   │  eks-pods-a      10.0.128.0/18   zone a   large, for pod ENIs    │
   │  eks-pods-b      10.0.192.0/18   zone b   large, for pod ENIs    │
   │  eks-nodes-a     10.0.0.0/24     zone a   small, for nodes       │
   │  eks-nodes-b     10.0.1.0/24     zone b   small, for nodes       │
   │  cache-public    10.0.2.0/24     zone c   public elasticache     │
   │  transit         10.0.3.0/28     zone a   /28 for a TGW ENI      │
   └──────────────────────────────────────────────────────────────────┘
```

Different sizes, different zones, different counts per zone, and names that mean
something to the people running it. None of that is expressible as seven fixed tiers.

## Why this shape

Three things fall out of the caller owning the keys:

- **Any number of groups.** There is no seventh-tier limit because there are no tiers.
- **Asymmetric zones.** `eks-pods` exists in two zones while `cache-public` exists in
  one. A positional list forces the same count everywhere.
- **Stable addresses.** The Terraform address is
  `module.subnets.module.subnet["eks-pods-a"]`, so removing `transit` does not renumber
  anything else. With positional lists, removing a subnet from the middle shifts every
  subnet after it and Terraform replaces them.

That last point is [#1018](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1018)
and [#1081](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1081).

## Requests this answers

- [#1284](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1284) Support explicit mapping of subnet CIDRs to specific AZs
- [#1180](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1180) Dedicated subnets for EKS/Kubernetes
- [#1102](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1102) Subnets for EKS
- [#1111](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1111) Support public Elasticache subnets
- [#1193](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1193) Can I create extra private subnets without tagging them
- [#1160](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1160) Dynamic subnet names are not being assigned

## References

- [Subnets for your VPC](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html)

## Usage

```bash
$ terraform init && terraform apply
```
