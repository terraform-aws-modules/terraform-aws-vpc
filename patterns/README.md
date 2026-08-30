# Patterns

Architecture patterns built from this module's sub-modules. Each one starts from a real
network architecture, cites the AWS guidance that shapes it, names the requests it
answers, and then shows the configuration that produces it.

These are not the same thing as `examples/`. An example demonstrates inputs. A pattern
demonstrates an architecture, and is expected to justify why the topology is the way it
is rather than only that it plans.

Every pattern directory contains a `README.md` with the architecture, the route tables it
produces, the AWS guidance it follows and the issues it answers, plus a runnable root
module. The one exception is [subnet-options](subnet-options/), which is a coverage
pattern rather than an architecture and says so in its opening line.

**Self-contained** means the pattern can be applied and destroyed on its own. The rest
need something that exists outside this repository, so they are validated but cannot be
part of an apply sweep.

## Egress

| Pattern | Self-contained | Answers |
| ------- | -------------- | ------- |
| [regional-nat](regional-nat/) | yes | [#1269](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1269), [#1281](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1281), [#1270](https://github.com/terraform-aws-modules/terraform-aws-vpc/pull/1270) |
| [nat-per-zone](nat-per-zone/) | yes | the highly available default |
| [single-nat](single-nat/) | yes | [#1065](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1065), [#1196](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1196), [#1257](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1257) |
| [private-nat](private-nat/) | yes | [#1040](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1040), [#1060](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1060), [#1103](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1103), [#1106](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1106) |
| [centralized-egress-spoke](centralized-egress-spoke/) | yes | [#1226](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1226), [#1031](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1031) |

## Inspection

| Pattern | Self-contained | Answers |
| ------- | -------------- | ------- |
| [network-firewall](network-firewall/) | yes | [#978](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/978), [#1187](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1187) |
| [east-west-inspection](east-west-inspection/) | yes | inter-subnet inspection, which the module cannot express today |
| [gateway-load-balancer](gateway-load-balancer/) | **no**, needs an appliance endpoint service | [#1271](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1271) |

## Routing

| Pattern | Self-contained | Answers |
| ------- | -------------- | ------- |
| [custom-routes](custom-routes/) | yes | [#1043](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1043), [#1130](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1130), [#1226](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1226), [#1265](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1265), [#1080](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1080) |
| [shared-route-tables](shared-route-tables/) | yes | [#1083](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1083), [#1119](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1119), [#1171](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1171) |

## Subnet layout

| Pattern | Self-contained | Answers |
| ------- | -------------- | ------- |
| [named-subnets](named-subnets/) | yes | [#1284](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1284), [#1180](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1180), [#1102](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1102), [#1111](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1111) |
| [dual-stack](dual-stack/) | yes | [#972](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/972), [#1049](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1049), [#1185](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1185) |
| [ipam](ipam/) | yes | [#1277](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1277), [#1153](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1153), [#1175](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1175) |
| [local-zones](local-zones/) | **no**, needs an opted-in Local Zone | [#1224](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1224) |
| [subnets-into-existing-vpc](subnets-into-existing-vpc/) | **no**, needs a pre-existing VPC | [#1034](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1034), [#1191](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/1191) |

## Sharing

| Pattern | Self-contained | Answers |
| ------- | -------------- | ------- |
| [shared-vpc](shared-vpc/) | **no**, needs participant account IDs | exercises `share_subnet`, which nothing else did |

## Coverage

Not an architecture. This one works backwards from a sub-module's variable file to make
sure the arguments no other pattern sets are still exercised by something.

| Pattern | Self-contained | Answers |
| ------- | -------------- | ------- |
| [subnet-options](subnet-options/) | yes | the inputs and outputs of both subnet sub-modules that no other pattern reaches, including all six timeout paths, the group network ACL rules, and `create = false` on both |

## Not covered here

Multi-VPC architectures (centralized ingress, Cloud WAN, transit gateway hub design)
belong to the modules that own those services. The VPC side of centralized egress is
covered by [centralized-egress-spoke](centralized-egress-spoke/).
