# Example: Database Subnet Route Table

Example script for provisioning dedicated database subnets, route table and NAT gateways alongside public and private subnets. It was originally created to resolve issue [#476](https://github.com/terraform-aws-modules/terraform-aws-vpc/pull/476) where the database route table failed to provision a route for the NAT gateway.
