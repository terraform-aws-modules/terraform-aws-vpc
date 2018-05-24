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

By default, the module will determine the number of NAT Gateways to create based on the the `max()` of the private subnet lists (`database_subnets`, `elasticache_subnets`, `private_subnets`, and `redshift_subnets`). For example, if your configuration looks like the following:

```hcl
database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]
elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24"]
private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
redshift_subnets    = ["10.0.41.0/24", "10.0.42.0/24"]
```

Then `5` NAT Gateways will be created since `5` private subnet CIDR blocks were specified.

### Single NAT Gateway

If `single_nat_gateway = true`, then all private subnets will route their Internet traffic through this single NAT gateway. The NAT gateway will be placed in the first public subnet in your `public_subnets` block.

### One NAT Gateway per availability zone

If `one_nat_gateway_per_az = true` and `single_nat_gateway = false`, then the module will place one NAT gateway in each availability zone you specify in `var.azs`. There are some requirements around using this feature flag:

* The variable `var.azs` **must** be specified.
* The number of public subnet CIDR blocks specified in `public_subnets` **must** be greater than or equal to the number of availability zones specified in `var.azs`. This is to ensure that each NAT Gateway has a dedicated public subnet to deploy to.

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
| azs | A list of availability zones in the region | string | `<list>` | no |
| cidr | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden | string | `0.0.0.0/0` | no |
| create_database_subnet_group | Controls if database subnet group should be created | string | `true` | no |
| create_vpc | Controls if VPC should be created (it affects almost all resources) | string | `true` | no |
| database_subnet_tags | Additional tags for the database subnets | string | `<map>` | no |
| database_subnets | A list of database subnets | list | `<list>` | no |
| default_route_table_tags | Additional tags for the default route table | string | `<map>` | no |
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
| instance_tenancy | A tenancy option for instances launched into the VPC | string | `default` | no |
| manage_default_vpc | Should be true to adopt and manage Default VPC | string | `false` | no |
| map_public_ip_on_launch | Should be false if you do not want to auto-assign public IP on launch | string | `true` | no |
| name | Name to be used on all the resources as identifier | string | `` | no |
| one_nat_gateway_per_az | Should be true if you want only one NAT Gateway per availability zone. Requires the input `azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `azs`. | string | `false` | no |
| private_route_table_tags | Additional tags for the private route tables | string | `<map>` | no |
| private_subnet_tags | Additional tags for the private subnets | string | `<map>` | no |
| private_subnets | A list of private subnets inside the VPC | string | `<list>` | no |
| propagate_private_route_tables_vgw | Should be true if you want route table propagation | string | `false` | no |
| propagate_public_route_tables_vgw | Should be true if you want route table propagation | string | `false` | no |
| public_route_table_tags | Additional tags for the public route tables | string | `<map>` | no |
| public_subnet_tags | Additional tags for the public subnets | string | `<map>` | no |
| public_subnets | A list of public subnets inside the VPC | string | `<list>` | no |
| redshift_subnet_tags | Additional tags for the redshift subnets | string | `<map>` | no |
| redshift_subnets | A list of redshift subnets | list | `<list>` | no |
| reuse_nat_ips | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable | string | `false` | no |
| single_nat_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | string | `false` | no |
| tags | A map of tags to add to all resources | string | `<map>` | no |
| vpc_tags | Additional tags for the VPC | string | `<map>` | no |
| vpn_gateway_id | ID of VPN Gateway to attach to the VPC | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
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
| default_vpc_id | Default VPC |
| default_vpc_instance_tenancy | Tenancy of instances spin up within VPC |
| default_vpc_main_route_table_id | The ID of the main route table associated with this VPC |
| elasticache_subnet_group | ID of elasticache subnet group |
| elasticache_subnet_group_name | Name of elasticache subnet group |
| elasticache_subnets | List of IDs of elasticache subnets |
| elasticache_subnets_cidr_blocks | List of cidr_blocks of elasticache subnets |
| igw_id | Internet Gateway |
| nat_ids | List of allocation ID of Elastic IPs created for AWS NAT Gateway |
| nat_public_ips | List of public Elastic IPs created for AWS NAT Gateway |
| natgw_ids | List of NAT Gateway IDs |
| private_route_table_ids | List of IDs of private route tables |
| private_subnets | Subnets |
| private_subnets_cidr_blocks | List of cidr_blocks of private subnets |
| public_route_table_ids | Route tables |
| public_subnets | List of IDs of public subnets |
| public_subnets_cidr_blocks | List of cidr_blocks of public subnets |
| redshift_subnet_group | ID of redshift subnet group |
| redshift_subnets | List of IDs of redshift subnets |
| redshift_subnets_cidr_blocks | List of cidr_blocks of redshift subnets |
| vgw_id | VPN Gateway |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_enable_dns_hostnames | Whether or not the VPC has DNS hostname support |
| vpc_enable_dns_support | Whether or not the VPC has DNS support |
| vpc_endpoint_dynamodb_id | The ID of VPC endpoint for DynamoDB |
| vpc_endpoint_dynamodb_pl_id | The prefix list for the DynamoDB VPC endpoint. |
| vpc_endpoint_s3_id | VPC Endpoints |
| vpc_endpoint_s3_pl_id | The prefix list for the S3 VPC endpoint. |
| vpc_id | VPC |
| vpc_instance_tenancy | Tenancy of instances spin up within VPC |
| vpc_main_route_table_id | The ID of the main route table associated with this VPC |

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

Migrated from `terraform-community-modules/tf_aws_vpc`, where it was maintained by [these awesome contributors](https://github.com/terraform-community-modules/tf_aws_vpc/graphs/contributors).
Module managed by [Anton Babenko](https://github.com/antonbabenko).

## License

Apache 2 Licensed. See LICENSE for full details.

