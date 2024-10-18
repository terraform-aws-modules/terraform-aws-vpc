# Downstream Changes

This is a (*small*) list of changes that exist between our version of the code and the [Upstream version](https://github.com/terraform-aws-modules/terraform-aws-vpc).

In case you want to have an actual detailed diff, please use the following link: [**Comparing `our_fork/ocp-maps-main` with `original_fork/v5.13.0`**](https://github.com/spring-media/terraform-aws-vpc/compare/ocp-maps-main...terraform-aws-modules%3Aterraform-aws-vpc%3Av5.13.0)

> [!CAUTION]
> Please not that the above comparison is using version `v5.13.0`. In case we pull more upstream changes we need to update this page and the previous link!

## Reason For Changes

There are two main changes from the upstream code that are worth discussing:
- **naming**
  - By having our naming convention in this module, we ensure it is used everywhere we create a VPC using this module
- **TGW Attachment and its subnets**
  - By having this code here, we ensure the TGW Attachment subnets are created with the same logic as the other subnets, and at the same time

## List of Changes

- **Transit Gateway Attachment Subnet Creation** - [tgw.tf](./tgw.tf)
  - We now have a separate file that creates
    - TGW Attachment subnets and associated resources (like route tables and NACLs)
    - The TGW Attachment itself
    - Routes for the TGW Attachment
- **Added CIDR Block Association for Secondary CIDR in [main.tf](./main.tf)**
- **Naming Changes**
  - [examples/vpc-flow-logs/main.tf](./examples/vpc-flow-logs/main.tf)
    - `name` -> `name_prefix`
  - [main.tf](./main.tf)
    - VPC name
    - **subnet** names, subnet **route table** names and subnet **NACLs** names for all subnets
    - IGW name
    - Egress Only IGW name
    - EIP name
    - NAT Gateway name
    - Customer Gateway name
    - VPN Gateway name
    - Default SG, NACL and Route Table names
- **Variables**
  - TGW Attachment related variables
    - Also variable to enable NAT GW for each TGW Attachment subnet
  - Secondary VPC CIDR from IPAM variable
  - name and vpc name prefix
  - short aws region
  - az name to az id map
- **Outputs**
  - TGW Attachment related outputs
  - List of Secondary CIDR Blocks from IPAM
  - AZ names and IDs for all subnets
