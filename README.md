# AWS VPC Terraform module

[![Help Contribute to Open Source](https://www.codetriage.com/terraform-aws-modules/terraform-aws-vpc/badges/users.svg)](https://www.codetriage.com/terraform-aws-modules/terraform-aws-vpc)

Terraform module which creates VPC resources on AWS.

These types of resources are supported:

* [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html)
* [Route table](https://www.terraform.io/docs/providers/aws/r/route_table.html)
* [Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)
* [NAT Gateway](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html)
* [VPN Gateway](https://www.terraform.io/docs/providers/aws/r/vpn_gateway.html)
* [VPC Endpoint](https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html) (S3 and DynamoDB)
* [RDS DB Subnet Group](https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html)
* [ElastiCache Subnet Group](https://www.terraform.io/docs/providers/aws/r/elasticache_subnet_group.html)
* [Redshift Subnet Group](https://www.terraform.io/docs/providers/aws/r/redshift_subnet_group.html)
* [DHCP Options Set](https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options.html)
* [Default VPC](https://www.terraform.io/docs/providers/aws/r/default_vpc.html)

Sponsored by [Cloudcraft - the best way to draw AWS diagrams](https://cloudcraft.co/?utm_source=terraform-aws-vpc)

<a href="https://cloudcraft.co/?utm_source=terraform-aws-vpc" target="_blank"><img src="https://raw.githubusercontent.com/antonbabenko/modules.tf-lambda/master/misc/cloudcraft-logo.png" alt="Cloudcraft - the best way to draw AWS diagrams" width="211" height="56" /></a>

## Usage

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
```

## External NAT Gateway IPs

By default this module will provision new Elastic IPs for the VPC's NAT Gateways.
This means that when creating a new VPC, new IPs are allocated, and when that VPC is destroyed those IPs are released.
Sometimes it is handy to keep the same IPs even after the VPC is destroyed and re-created.
To that end, it is possible to assign existing IPs to the NAT Gateways.
This prevents the destruction of the VPC from releasing those IPs, while making it possible that a re-created VPC uses the same IPs.

To achieve this, allocate the IPs outside the VPC module declaration.
```hcl
resource "aws_eip" "nat" {
  count = 3

  vpc = true
}
```

Then, pass the allocated IPs as a parameter to this module.
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # The rest of arguments are omitted for brevity

  enable_nat_gateway  = true
  single_nat_gateway  = false
  reuse_nat_ips       = true                      # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = ["${aws_eip.nat.*.id}"]   # <= IPs specified here as input to the module
}
```

Note that in the example we allocate 3 IPs because we will be provisioning 3 NAT Gateways (due to `single_nat_gateway = false` and having 3 subnets).
If, on the other hand, `single_nat_gateway = true`, then `aws_eip.nat` would only need to allocate 1 IP.
Passing the IPs into the module is done by setting two variables `reuse_nat_ips = true` and `external_nat_ip_ids = ["${aws_eip.nat.*.id}"]`.

## NAT Gateway Scenarios

This module supports three scenarios for creating NAT gateways. Each will be explained in further detail in the corresponding sections.

* One NAT Gateway per subnet (default behavior)
    * `enable_nat_gateway = true`
    * `single_nat_gateway = false`
    * `one_nat_gateway_per_az = false`
* Single NAT Gateway
    * `enable_nat_gateway = true`
    * `single_nat_gateway = true`
    * `one_nat_gateway_per_az = false`
* One NAT Gateway per availability zone
    * `enable_nat_gateway = true`
    * `single_nat_gateway = false`
    * `one_nat_gateway_per_az = true`

If both `single_nat_gateway` and `one_nat_gateway_per_az` are set to `true`, then `single_nat_gateway` takes precedence.

### One NAT Gateway per subnet (default)

By default, the module will determine the number of NAT Gateways to create based on the the `max()` of the private subnet lists (`database_subnets`, `elasticache_subnets`, `private_subnets`, and `redshift_subnets`). The module **does not** take into account the number of `intra_subnets`, since the latter are designed to have no Internet access via NAT Gateway.  For example, if your configuration looks like the following:

```hcl
database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]
elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24"]
private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
redshift_subnets    = ["10.0.41.0/24", "10.0.42.0/24"]
intra_subnets       = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]
```

Then `5` NAT Gateways will be created since `5` private subnet CIDR blocks were specified.

### Single NAT Gateway

If `single_nat_gateway = true`, then all private subnets will route their Internet traffic through this single NAT gateway. The NAT gateway will be placed in the first public subnet in your `public_subnets` block.

### One NAT Gateway per availability zone

If `one_nat_gateway_per_az = true` and `single_nat_gateway = false`, then the module will place one NAT gateway in each availability zone you specify in `var.azs`. There are some requirements around using this feature flag:

* The variable `var.azs` **must** be specified.
* The number of public subnet CIDR blocks specified in `public_subnets` **must** be greater than or equal to the number of availability zones specified in `var.azs`. This is to ensure that each NAT Gateway has a dedicated public subnet to deploy to.

## "private" versus "intra" subnets

By default, if NAT Gateways are enabled, private subnets will be configured with routes for Internet traffic that point at the NAT Gateways configured by use of the above options.

If you need private subnets that should have no Internet routing (in the sense of [RFC1918 Category 1 subnets](https://tools.ietf.org/html/rfc1918)), `intra_subnets` should be specified. An example use case is configuration of AWS Lambda functions within a VPC, where AWS Lambda functions only need to pass traffic to internal resources or VPC endpoints for AWS services.
 
Since AWS Lambda functions allocate Elastic Network Interfaces in proportion to the traffic received ([read more](https://docs.aws.amazon.com/lambda/latest/dg/vpc.html)), it can be useful to allocate a large private subnet for such allocations, while keeping the traffic they generate entirely internal to the VPC.

You can add additional tags with `intra_subnet_tags` as with other subnet types.

## Conditional creation

Sometimes you need to have a way to create VPC resources conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `create_vpc`.

```hcl
# This VPC will not be created
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  create_vpc = false
  # ... omitted
}
```

## Terraform version

Terraform version 0.10.3 or newer is required for this module to work.

## Examples

* [Simple VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/simple-vpc)
* [Complete VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete-vpc)
* [Manage Default VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/manage-default-vpc)
* Few tests and edge cases examples: [#46](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-46-no-private-subnets), [#44](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-44-asymmetric-private-subnets), [#108](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-108-route-already-exists)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| amazon_side_asn | The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN. | string | `64512` | no |
| assign_generated_ipv6_cidr_block | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block | string | `false` | no |
| azs | A list of availability zones in the region | string | `<list>` | no |
| cidr | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden | string | `0.0.0.0/0` | no |
| create_database_subnet_group | Controls if database subnet group should be created | string | `true` | no |
| create_database_subnet_route_table | Controls if separate route table for database should be created | string | `false` | no |
| create_elasticache_subnet_route_table | Controls if separate route table for elasticache should be created | string | `false` | no |
| create_redshift_subnet_route_table | Controls if separate route table for redshift should be created | string | `false` | no |
| create_vpc | Controls if VPC should be created (it affects almost all resources) | string | `true` | no |
| database_route_table_tags | Additional tags for the database route tables | string | `<map>` | no |
| database_subnet_group_tags | Additional tags for the database subnet group | string | `<map>` | no |
| database_subnet_suffix | Suffix to append to database subnets name | string | `db` | no |
| database_subnet_tags | Additional tags for the database subnets | string | `<map>` | no |
| database_subnets | A list of database subnets | list | `<list>` | no |
| default_vpc_enable_classiclink | Should be true to enable ClassicLink in the Default VPC | string | `false` | no |
| default_vpc_enable_dns_hostnames | Should be true to enable DNS hostnames in the Default VPC | string | `false` | no |
| default_vpc_enable_dns_support | Should be true to enable DNS support in the Default VPC | string | `true` | no |
| default_vpc_name | Name to be used on the Default VPC | string | `` | no |
| default_vpc_tags | Additional tags for the Default VPC | string | `<map>` | no |
| dhcp_options_domain_name | Specifies DNS name for DHCP options set | string | `` | no |
| dhcp_options_domain_name_servers | Specify a list of DNS server addresses for DHCP options set, default to AWS provided | list | `<list>` | no |
| dhcp_options_netbios_name_servers | Specify a list of netbios servers for DHCP options set | list | `<list>` | no |
| dhcp_options_netbios_node_type | Specify netbios node_type for DHCP options set | string | `` | no |
| dhcp_options_ntp_servers | Specify a list of NTP servers for DHCP options set | list | `<list>` | no |
| dhcp_options_tags | Additional tags for the DHCP option set | string | `<map>` | no |
| elasticache_route_table_tags | Additional tags for the elasticache route tables | string | `<map>` | no |
| elasticache_subnet_suffix | Suffix to append to elasticache subnets name | string | `elasticache` | no |
| elasticache_subnet_tags | Additional tags for the elasticache subnets | string | `<map>` | no |
| elasticache_subnets | A list of elasticache subnets | list | `<list>` | no |
| enable_dhcp_options | Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type | string | `false` | no |
| enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC | string | `false` | no |
| enable_dns_support | Should be true to enable DNS support in the VPC | string | `true` | no |
| enable_dynamodb_endpoint | Should be true if you want to provision a DynamoDB endpoint to the VPC | string | `false` | no |
| enable_nat_gateway | Should be true if you want to provision NAT Gateways for each of your private networks | string | `false` | no |
| enable_s3_endpoint | Should be true if you want to provision an S3 endpoint to the VPC | string | `false` | no |
| enable_vpn_gateway | Should be true if you want to create a new VPN Gateway resource and attach it to the VPC | string | `false` | no |
| external_nat_ip_ids | List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips) | list | `<list>` | no |
| igw_tags | Additional tags for the internet gateway | string | `<map>` | no |
| instance_tenancy | A tenancy option for instances launched into the VPC | string | `default` | no |
| intra_route_table_tags | Additional tags for the intra route tables | string | `<map>` | no |
| intra_subnet_tags | Additional tags for the intra subnets | string | `<map>` | no |
| intra_subnets | A list of intra subnets | list | `<list>` | no |
| manage_default_vpc | Should be true to adopt and manage Default VPC | string | `false` | no |
| map_public_ip_on_launch | Should be false if you do not want to auto-assign public IP on launch | string | `true` | no |
| name | Name to be used on all the resources as identifier | string | `` | no |
| nat_eip_tags | Additional tags for the NAT EIP | string | `<map>` | no |
| nat_gateway_tags | Additional tags for the NAT gateways | string | `<map>` | no |
| one_nat_gateway_per_az | Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`. | string | `false` | no |
| private_route_table_tags | Additional tags for the private route tables | string | `<map>` | no |
| private_subnet_suffix | Suffix to append to private subnets name | string | `private` | no |
| private_subnet_tags | Additional tags for the private subnets | string | `<map>` | no |
| private_subnets | A list of private subnets inside the VPC | string | `<list>` | no |
| propagate_private_route_tables_vgw | Should be true if you want route table propagation | string | `false` | no |
| propagate_public_route_tables_vgw | Should be true if you want route table propagation | string | `false` | no |
| public_route_table_tags | Additional tags for the public route tables | string | `<map>` | no |
| public_subnet_suffix | Suffix to append to public subnets name | string | `public` | no |
| public_subnet_tags | Additional tags for the public subnets | string | `<map>` | no |
| public_subnets | A list of public subnets inside the VPC | string | `<list>` | no |
| redshift_route_table_tags | Additional tags for the redshift route tables | string | `<map>` | no |
| redshift_subnet_group_tags | Additional tags for the redshift subnet group | string | `<map>` | no |
| redshift_subnet_suffix | Suffix to append to redshift subnets name | string | `redshift` | no |
| redshift_subnet_tags | Additional tags for the redshift subnets | string | `<map>` | no |
| redshift_subnets | A list of redshift subnets | list | `<list>` | no |
| reuse_nat_ips | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable | string | `false` | no |
| secondary_cidr_blocks | List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool | string | `<list>` | no |
| single_nat_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | string | `false` | no |
| tags | A map of tags to add to all resources | string | `<map>` | no |
| vpc_tags | Additional tags for the VPC | string | `<map>` | no |
| vpn_gateway_id | ID of VPN Gateway to attach to the VPC | string | `` | no |
| vpn_gateway_tags | Additional tags for the VPN gateway | string | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| database_route_table_ids | List of IDs of database route tables |
| database_subnet_group | ID of database subnet group |
| database_subnets | List of IDs of database subnets |
| database_subnets_cidr_blocks | List of cidr_blocks of database subnets |
| default_network_acl_id | The ID of the default network ACL |
| default_route_table_id | The ID of the default route table |
| default_security_group_id | The ID of the security group created by default on VPC creation |
| default_vpc_cidr_block | The CIDR block of the VPC |
| default_vpc_default_network_acl_id | The ID of the default network ACL |
| default_vpc_default_route_table_id | The ID of the default route table |
| default_vpc_default_security_group_id | The ID of the security group created by default on VPC creation |
| default_vpc_enable_dns_hostnames | Whether or not the VPC has DNS hostname support |
| default_vpc_enable_dns_support | Whether or not the VPC has DNS support |
| default_vpc_id | The ID of the VPC |
| default_vpc_instance_tenancy | Tenancy of instances spin up within VPC |
| default_vpc_main_route_table_id | The ID of the main route table associated with this VPC |
| elasticache_route_table_ids | List of IDs of elasticache route tables |
| elasticache_subnet_group | ID of elasticache subnet group |
| elasticache_subnet_group_name | Name of elasticache subnet group |
| elasticache_subnets | List of IDs of elasticache subnets |
| elasticache_subnets_cidr_blocks | List of cidr_blocks of elasticache subnets |
| igw_id | The ID of the Internet Gateway |
| intra_route_table_ids | List of IDs of intra route tables |
| intra_subnets | List of IDs of intra subnets |
| intra_subnets_cidr_blocks | List of cidr_blocks of intra subnets |
| nat_ids | List of allocation ID of Elastic IPs created for AWS NAT Gateway |
| nat_public_ips | List of public Elastic IPs created for AWS NAT Gateway |
| natgw_ids | List of NAT Gateway IDs |
| private_route_table_ids | List of IDs of private route tables |
| private_subnets | List of IDs of private subnets |
| private_subnets_cidr_blocks | List of cidr_blocks of private subnets |
| public_route_table_ids | List of IDs of public route tables |
| public_subnets | List of IDs of public subnets |
| public_subnets_cidr_blocks | List of cidr_blocks of public subnets |
| redshift_route_table_ids | List of IDs of redshift route tables |
| redshift_subnet_group | ID of redshift subnet group |
| redshift_subnets | List of IDs of redshift subnets |
| redshift_subnets_cidr_blocks | List of cidr_blocks of redshift subnets |
| vgw_id | The ID of the VPN Gateway |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_enable_dns_hostnames | Whether or not the VPC has DNS hostname support |
| vpc_enable_dns_support | Whether or not the VPC has DNS support |
| vpc_endpoint_dynamodb_id | The ID of VPC endpoint for DynamoDB |
| vpc_endpoint_dynamodb_pl_id | The prefix list for the DynamoDB VPC endpoint. |
| vpc_endpoint_s3_id | The ID of VPC endpoint for S3 |
| vpc_endpoint_s3_pl_id | The prefix list for the S3 VPC endpoint. |
| vpc_id | The ID of the VPC |
| vpc_instance_tenancy | Tenancy of instances spin up within VPC |
| vpc_main_route_table_id | The ID of the main route table associated with this VPC |
| vpc_secondary_cidr_blocks | List of secondary CIDR blocks of the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Tests

This module has been packaged with [awspec](https://github.com/k1LoW/awspec) tests through test kitchen. To run them:

1. Install [rvm](https://rvm.io/rvm/install) and the ruby version specified in the [Gemfile](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/Gemfile).
2. Install bundler and the gems from our Gemfile:
```
gem install bundler; bundle install
```
3. Test using `bundle exec kitchen test` from the root of the repo.


## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-vpc/graphs/contributors).

## License

Apache 2 Licensed. See LICENSE for full details.

