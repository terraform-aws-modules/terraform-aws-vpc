# AWS VPC Terraform module

[![Help Contribute to Open Source](https://www.codetriage.com/terraform-aws-modules/terraform-aws-vpc/badges/users.svg)](https://www.codetriage.com/terraform-aws-modules/terraform-aws-vpc)

Terraform module which creates VPC resources on AWS.

These types of resources are supported:

* [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html)
* [Route table](https://www.terraform.io/docs/providers/aws/r/route_table.html)
* [Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)
* [Network ACL](https://www.terraform.io/docs/providers/aws/r/network_acl.html)
* [NAT Gateway](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html)
* [VPN Gateway](https://www.terraform.io/docs/providers/aws/r/vpn_gateway.html)
* [VPC Endpoint](https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html):
  * Gateway: S3, DynamoDB
  * Interface: EC2, SSM, EC2 Messages, SSM Messages, SQS, ECR API, ECR DKR, API Gateway, KMS, 
ECS, ECS Agent, ECS Telemetry, SNS, CloudWatch(Monitoring, Logs, Events), Elastic Load Balancing, CloudTrail, Secrets Manager, Config, Codebuild, Codecommit, Git-Codecommit, Transfer Server, Kinesis Streams, Kinesis Firehose
* [RDS DB Subnet Group](https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html)
* [ElastiCache Subnet Group](https://www.terraform.io/docs/providers/aws/r/elasticache_subnet_group.html)
* [Redshift Subnet Group](https://www.terraform.io/docs/providers/aws/r/redshift_subnet_group.html)
* [DHCP Options Set](https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options.html)
* [Default VPC](https://www.terraform.io/docs/providers/aws/r/default_vpc.html)
* [Default Network ACL](https://www.terraform.io/docs/providers/aws/r/default_network_acl.html)

Sponsored by [Cloudcraft - the best way to draw AWS diagrams](https://cloudcraft.co/?utm_source=terraform-aws-vpc)

<a href="https://cloudcraft.co/?utm_source=terraform-aws-vpc" target="_blank"><img src="https://raw.githubusercontent.com/antonbabenko/modules.tf-lambda/master/misc/cloudcraft-logo.png" alt="Cloudcraft - the best way to draw AWS diagrams" width="211" height="56" /></a>

## Terraform versions

Terraform 0.12. Pin module version to `~> v2.0`. Submit pull-requests to `master` branch.

Terraform 0.11. Pin module version to `~> v1.0`. Submit pull-requests to `terraform011` branch.

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
  reuse_nat_ips       = true                    # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = "${aws_eip.nat.*.id}"   # <= IPs specified here as input to the module
}
```

Note that in the example we allocate 3 IPs because we will be provisioning 3 NAT Gateways (due to `single_nat_gateway = false` and having 3 subnets).
If, on the other hand, `single_nat_gateway = true`, then `aws_eip.nat` would only need to allocate 1 IP.
Passing the IPs into the module is done by setting two variables `reuse_nat_ips = true` and `external_nat_ip_ids = "${aws_eip.nat.*.id}"`.

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

## Public access to RDS instances

Sometimes it is handy to have public access to RDS instances (it is not recommended for production) by specifying these arguments:

```hcl
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true
```

## Network Access Control Lists (ACL or NACL)

This module can manage network ACL and rules. Once VPC is created, AWS creates the default network ACL, which can be controlled using this module (`manage_default_network_acl = true`).

Also, each type of subnet may have its own network ACL with custom rules per subnet. Eg, set `public_dedicated_network_acl = true` to use dedicated network ACL for the public subnets; set values of `public_inbound_acl_rules` and `public_outbound_acl_rules` to specify all the NACL rules you need to have on public subnets (see `variables.tf` for default values and structures).

By default, all subnets are associated with the default network ACL.

## Public access to Redshift cluster

Sometimes it is handy to have public access to Redshift clusters (for example if you need to access it by Kinesis - VPC endpoint for Kinesis is not yet supported by Redshift) by specifying these arguments:

```hcl
  enable_public_redshift = true  # <= By default Redshift subnets will be associated with the private route table
```

## Examples

* [Simple VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/simple-vpc)
* [Complete VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete-vpc)
* [Manage Default VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/manage-default-vpc)
* [Network ACL](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/network-acls)
* Few tests and edge cases examples: [#46](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-46-no-private-subnets), [#44](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-44-asymmetric-private-subnets), [#108](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-108-route-already-exists)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| amazon\_side\_asn | The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN. | string | `"64512"` | no |
| apigw\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for API GW endpoint | bool | `"false"` | no |
| apigw\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for API GW  endpoint | list(string) | `[]` | no |
| apigw\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for API GW endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| assign\_generated\_ipv6\_cidr\_block | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block | bool | `"false"` | no |
| azs | A list of availability zones in the region | list(string) | `[]` | no |
| cidr | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden | string | `"0.0.0.0/0"` | no |
| cloudtrail\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CloudTrail endpoint | bool | `"false"` | no |
| cloudtrail\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CloudTrail endpoint | list(string) | `[]` | no |
| cloudtrail\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CloudTrail endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| codebuild\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Codebuild endpoint | string | `"false"` | no |
| codebuild\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Codebuild endpoint | list | `[]` | no |
| codebuild\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Codebuilt endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list | `[]` | no |
| codecommit\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Codecommit endpoint | string | `"false"` | no |
| codecommit\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Codecommit endpoint | list | `[]` | no |
| codecommit\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Codecommit endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list | `[]` | no |
| config\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for config endpoint | string | `"false"` | no |
| config\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for config endpoint | list | `[]` | no |
| config\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for config endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list | `[]` | no |
| create\_database\_internet\_gateway\_route | Controls if an internet gateway route for public database access should be created | bool | `"false"` | no |
| create\_database\_nat\_gateway\_route | Controls if a nat gateway route should be created to give internet access to the database subnets | bool | `"false"` | no |
| create\_database\_subnet\_group | Controls if database subnet group should be created | bool | `"true"` | no |
| create\_database\_subnet\_route\_table | Controls if separate route table for database should be created | bool | `"false"` | no |
| create\_elasticache\_subnet\_group | Controls if elasticache subnet group should be created | bool | `"true"` | no |
| create\_elasticache\_subnet\_route\_table | Controls if separate route table for elasticache should be created | bool | `"false"` | no |
| create\_redshift\_subnet\_group | Controls if redshift subnet group should be created | bool | `"true"` | no |
| create\_redshift\_subnet\_route\_table | Controls if separate route table for redshift should be created | bool | `"false"` | no |
| create\_vpc | Controls if VPC should be created (it affects almost all resources) | bool | `"true"` | no |
| database\_acl\_tags | Additional tags for the database subnets network ACL | map(string) | `{}` | no |
| database\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for database subnets | bool | `"false"` | no |
| database\_inbound\_acl\_rules | Database subnets inbound network ACL rules | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| database\_outbound\_acl\_rules | Database subnets outbound network ACL rules | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| database\_route\_table\_tags | Additional tags for the database route tables | map(string) | `{}` | no |
| database\_subnet\_group\_tags | Additional tags for the database subnet group | map(string) | `{}` | no |
| database\_subnet\_suffix | Suffix to append to database subnets name | string | `"db"` | no |
| database\_subnet\_tags | Additional tags for the database subnets | map(string) | `{}` | no |
| database\_subnets | A list of database subnets | list(string) | `[]` | no |
| default\_network\_acl\_egress | List of maps of egress rules to set on the Default Network ACL | list(map(string)) | `[ { "action": "allow", "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_no": 100, "to_port": 0 }, { "action": "allow", "from_port": 0, "ipv6_cidr_block": "::/0", "protocol": "-1", "rule_no": 101, "to_port": 0 } ]` | no |
| default\_network\_acl\_ingress | List of maps of ingress rules to set on the Default Network ACL | list(map(string)) | `[ { "action": "allow", "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_no": 100, "to_port": 0 }, { "action": "allow", "from_port": 0, "ipv6_cidr_block": "::/0", "protocol": "-1", "rule_no": 101, "to_port": 0 } ]` | no |
| default\_network\_acl\_name | Name to be used on the Default Network ACL | string | `""` | no |
| default\_network\_acl\_tags | Additional tags for the Default Network ACL | map(string) | `{}` | no |
| default\_vpc\_enable\_classiclink | Should be true to enable ClassicLink in the Default VPC | bool | `"false"` | no |
| default\_vpc\_enable\_dns\_hostnames | Should be true to enable DNS hostnames in the Default VPC | bool | `"false"` | no |
| default\_vpc\_enable\_dns\_support | Should be true to enable DNS support in the Default VPC | bool | `"true"` | no |
| default\_vpc\_name | Name to be used on the Default VPC | string | `""` | no |
| default\_vpc\_tags | Additional tags for the Default VPC | map(string) | `{}` | no |
| dhcp\_options\_domain\_name | Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true) | string | `""` | no |
| dhcp\_options\_domain\_name\_servers | Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true) | list(string) | `[ "AmazonProvidedDNS" ]` | no |
| dhcp\_options\_netbios\_name\_servers | Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true) | list(string) | `[]` | no |
| dhcp\_options\_netbios\_node\_type | Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true) | string | `""` | no |
| dhcp\_options\_ntp\_servers | Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true) | list(string) | `[]` | no |
| dhcp\_options\_tags | Additional tags for the DHCP option set (requires enable_dhcp_options set to true) | map(string) | `{}` | no |
| ec2\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for EC2 endpoint | bool | `"false"` | no |
| ec2\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for EC2 endpoint | list(string) | `[]` | no |
| ec2\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for EC2 endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| ec2messages\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for EC2MESSAGES endpoint | bool | `"false"` | no |
| ec2messages\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for EC2MESSAGES endpoint | list(string) | `[]` | no |
| ec2messages\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for EC2MESSAGES endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| ecr\_api\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ECR API endpoint | bool | `"false"` | no |
| ecr\_api\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ECR API endpoint | list(string) | `[]` | no |
| ecr\_api\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ECR api endpoint. If omitted, private subnets will be used. | list(string) | `[]` | no |
| ecr\_dkr\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ECR DKR endpoint | bool | `"false"` | no |
| ecr\_dkr\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ECR DKR endpoint | list(string) | `[]` | no |
| ecr\_dkr\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ECR dkr endpoint. If omitted, private subnets will be used. | list(string) | `[]` | no |
| ecs\_agent\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ECS Agent endpoint | bool | `"false"` | no |
| ecs\_agent\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ECS Agent endpoint | list(string) | `[]` | no |
| ecs\_agent\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ECS Agent endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| ecs\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ECS endpoint | bool | `"false"` | no |
| ecs\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ECS endpoint | list(string) | `[]` | no |
| ecs\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ECS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| ecs\_telemetry\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ECS Telemetry endpoint | bool | `"false"` | no |
| ecs\_telemetry\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ECS Telemetry endpoint | list(string) | `[]` | no |
| ecs\_telemetry\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ECS Telemetry endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| elasticache\_acl\_tags | Additional tags for the elasticache subnets network ACL | map(string) | `{}` | no |
| elasticache\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for elasticache subnets | bool | `"false"` | no |
| elasticache\_inbound\_acl\_rules | Elasticache subnets inbound network ACL rules | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| elasticache\_outbound\_acl\_rules | Elasticache subnets outbound network ACL rules | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| elasticache\_route\_table\_tags | Additional tags for the elasticache route tables | map(string) | `{}` | no |
| elasticache\_subnet\_suffix | Suffix to append to elasticache subnets name | string | `"elasticache"` | no |
| elasticache\_subnet\_tags | Additional tags for the elasticache subnets | map(string) | `{}` | no |
| elasticache\_subnets | A list of elasticache subnets | list(string) | `[]` | no |
| elasticloadbalancing\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Elastic Load Balancing endpoint | bool | `"false"` | no |
| elasticloadbalancing\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Elastic Load Balancing endpoint | list(string) | `[]` | no |
| elasticloadbalancing\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Elastic Load Balancing endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| enable\_apigw\_endpoint | Should be true if you want to provision an api gateway endpoint to the VPC | bool | `"false"` | no |
| enable\_cloudtrail\_endpoint | Should be true if you want to provision a CloudTrail endpoint to the VPC | bool | `"false"` | no |
| enable\_codebuild\_endpoint | Should be true if you want to provision an Codebuild endpoint to the VPC | string | `"false"` | no |
| enable\_codecommit\_endpoint | Should be true if you want to provision an Codecommit endpoint to the VPC | string | `"false"` | no |
| enable\_config\_endpoint | Should be true if you want to provision an config endpoint to the VPC | string | `"false"` | no |
| enable\_dhcp\_options | Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type | bool | `"false"` | no |
| enable\_dns\_hostnames | Should be true to enable DNS hostnames in the VPC | bool | `"false"` | no |
| enable\_dns\_support | Should be true to enable DNS support in the VPC | bool | `"true"` | no |
| enable\_dynamodb\_endpoint | Should be true if you want to provision a DynamoDB endpoint to the VPC | bool | `"false"` | no |
| enable\_ec2\_endpoint | Should be true if you want to provision an EC2 endpoint to the VPC | bool | `"false"` | no |
| enable\_ec2messages\_endpoint | Should be true if you want to provision an EC2MESSAGES endpoint to the VPC | bool | `"false"` | no |
| enable\_ecr\_api\_endpoint | Should be true if you want to provision an ecr api endpoint to the VPC | bool | `"false"` | no |
| enable\_ecr\_dkr\_endpoint | Should be true if you want to provision an ecr dkr endpoint to the VPC | bool | `"false"` | no |
| enable\_ecs\_agent\_endpoint | Should be true if you want to provision a ECS Agent endpoint to the VPC | bool | `"false"` | no |
| enable\_ecs\_endpoint | Should be true if you want to provision a ECS endpoint to the VPC | bool | `"false"` | no |
| enable\_ecs\_telemetry\_endpoint | Should be true if you want to provision a ECS Telemetry endpoint to the VPC | bool | `"false"` | no |
| enable\_elasticloadbalancing\_endpoint | Should be true if you want to provision a Elastic Load Balancing endpoint to the VPC | bool | `"false"` | no |
| enable\_events\_endpoint | Should be true if you want to provision a CloudWatch Events endpoint to the VPC | bool | `"false"` | no |
| enable\_git\_codecommit\_endpoint | Should be true if you want to provision an Git Codecommit endpoint to the VPC | string | `"false"` | no |
| enable\_kinesis\_firehose\_endpoint | Should be true if you want to provision a Kinesis Firehose endpoint to the VPC | bool | `"false"` | no |
| enable\_kinesis\_streams\_endpoint | Should be true if you want to provision a Kinesis Streams endpoint to the VPC | bool | `"false"` | no |
| enable\_kms\_endpoint | Should be true if you want to provision a KMS endpoint to the VPC | bool | `"false"` | no |
| enable\_logs\_endpoint | Should be true if you want to provision a CloudWatch Logs endpoint to the VPC | bool | `"false"` | no |
| enable\_monitoring\_endpoint | Should be true if you want to provision a CloudWatch Monitoring endpoint to the VPC | bool | `"false"` | no |
| enable\_nat\_gateway | Should be true if you want to provision NAT Gateways for each of your private networks | bool | `"false"` | no |
| enable\_public\_redshift | Controls if redshift should have public routing table | bool | `"false"` | no |
| enable\_s3\_endpoint | Should be true if you want to provision an S3 endpoint to the VPC | bool | `"false"` | no |
| enable\_secretsmanager\_endpoint | Should be true if you want to provision an Secrets Manager endpoint to the VPC | bool | `"false"` | no |
| enable\_sns\_endpoint | Should be true if you want to provision a SNS endpoint to the VPC | bool | `"false"` | no |
| enable\_sqs\_endpoint | Should be true if you want to provision an SQS endpoint to the VPC | string | `"false"` | no |
| enable\_ssm\_endpoint | Should be true if you want to provision an SSM endpoint to the VPC | bool | `"false"` | no |
| enable\_ssmmessages\_endpoint | Should be true if you want to provision a SSMMESSAGES endpoint to the VPC | bool | `"false"` | no |
| enable\_transferserver\_endpoint | Should be true if you want to provision a Transer Server endpoint to the VPC | bool | `"false"` | no |
| enable\_vpn\_gateway | Should be true if you want to create a new VPN Gateway resource and attach it to the VPC | bool | `"false"` | no |
| events\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Events endpoint | bool | `"false"` | no |
| events\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CloudWatch Events endpoint | list(string) | `[]` | no |
| events\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CloudWatch Events endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| external\_nat\_ip\_ids | List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips) | list(string) | `[]` | no |
| git\_codecommit\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Git Codecommit endpoint | string | `"false"` | no |
| git\_codecommit\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Git Codecommit endpoint | list | `[]` | no |
| git\_codecommit\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Git Codecommit endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list | `[]` | no |
| igw\_tags | Additional tags for the internet gateway | map(string) | `{}` | no |
| instance\_tenancy | A tenancy option for instances launched into the VPC | string | `"default"` | no |
| intra\_acl\_tags | Additional tags for the intra subnets network ACL | map(string) | `{}` | no |
| intra\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for intra subnets | bool | `"false"` | no |
| intra\_inbound\_acl\_rules | Intra subnets inbound network ACLs | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| intra\_outbound\_acl\_rules | Intra subnets outbound network ACLs | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| intra\_route\_table\_tags | Additional tags for the intra route tables | map(string) | `{}` | no |
| intra\_subnet\_suffix | Suffix to append to intra subnets name | string | `"intra"` | no |
| intra\_subnet\_tags | Additional tags for the intra subnets | map(string) | `{}` | no |
| intra\_subnets | A list of intra subnets | list(string) | `[]` | no |
| kinesis\_firehose\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Kinesis Firehose endpoint | bool | `"false"` | no |
| kinesis\_firehose\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Kinesis Firehose endpoint | list(string) | `[]` | no |
| kinesis\_firehose\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Kinesis Firehose endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| kinesis\_streams\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Kinesis Streams endpoint | bool | `"false"` | no |
| kinesis\_streams\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Kinesis Streams endpoint | list(string) | `[]` | no |
| kinesis\_streams\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Kinesis Streams endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| kms\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for KMS endpoint | bool | `"false"` | no |
| kms\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for KMS endpoint | list(string) | `[]` | no |
| kms\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for KMS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| logs\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Logs endpoint | bool | `"false"` | no |
| logs\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CloudWatch Logs endpoint | list(string) | `[]` | no |
| logs\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CloudWatch Logs endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| manage\_default\_network\_acl | Should be true to adopt and manage Default Network ACL | bool | `"false"` | no |
| manage\_default\_vpc | Should be true to adopt and manage Default VPC | bool | `"false"` | no |
| map\_public\_ip\_on\_launch | Should be false if you do not want to auto-assign public IP on launch | bool | `"true"` | no |
| monitoring\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Monitoring endpoint | bool | `"false"` | no |
| monitoring\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CloudWatch Monitoring endpoint | list(string) | `[]` | no |
| monitoring\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CloudWatch Monitoring endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| name | Name to be used on all the resources as identifier | string | `""` | no |
| nat\_eip\_tags | Additional tags for the NAT EIP | map(string) | `{}` | no |
| nat\_gateway\_tags | Additional tags for the NAT gateways | map(string) | `{}` | no |
| one\_nat\_gateway\_per\_az | Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`. | bool | `"false"` | no |
| private\_acl\_tags | Additional tags for the private subnets network ACL | map(string) | `{}` | no |
| private\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for private subnets | bool | `"false"` | no |
| private\_inbound\_acl\_rules | Private subnets inbound network ACLs | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| private\_outbound\_acl\_rules | Private subnets outbound network ACLs | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| private\_route\_table\_tags | Additional tags for the private route tables | map(string) | `{}` | no |
| private\_subnet\_suffix | Suffix to append to private subnets name | string | `"private"` | no |
| private\_subnet\_tags | Additional tags for the private subnets | map(string) | `{}` | no |
| private\_subnets | A list of private subnets inside the VPC | list(string) | `[]` | no |
| propagate\_private\_route\_tables\_vgw | Should be true if you want route table propagation | bool | `"false"` | no |
| propagate\_public\_route\_tables\_vgw | Should be true if you want route table propagation | bool | `"false"` | no |
| public\_acl\_tags | Additional tags for the public subnets network ACL | map(string) | `{}` | no |
| public\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for public subnets | bool | `"false"` | no |
| public\_inbound\_acl\_rules | Public subnets inbound network ACLs | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| public\_outbound\_acl\_rules | Public subnets outbound network ACLs | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| public\_route\_table\_tags | Additional tags for the public route tables | map(string) | `{}` | no |
| public\_subnet\_suffix | Suffix to append to public subnets name | string | `"public"` | no |
| public\_subnet\_tags | Additional tags for the public subnets | map(string) | `{}` | no |
| public\_subnets | A list of public subnets inside the VPC | list(string) | `[]` | no |
| redshift\_acl\_tags | Additional tags for the redshift subnets network ACL | map(string) | `{}` | no |
| redshift\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for redshift subnets | bool | `"false"` | no |
| redshift\_inbound\_acl\_rules | Redshift subnets inbound network ACL rules | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| redshift\_outbound\_acl\_rules | Redshift subnets outbound network ACL rules | list(map(string)) | `[ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 } ]` | no |
| redshift\_route\_table\_tags | Additional tags for the redshift route tables | map(string) | `{}` | no |
| redshift\_subnet\_group\_tags | Additional tags for the redshift subnet group | map(string) | `{}` | no |
| redshift\_subnet\_suffix | Suffix to append to redshift subnets name | string | `"redshift"` | no |
| redshift\_subnet\_tags | Additional tags for the redshift subnets | map(string) | `{}` | no |
| redshift\_subnets | A list of redshift subnets | list(string) | `[]` | no |
| reuse\_nat\_ips | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable | bool | `"false"` | no |
| secondary\_cidr\_blocks | List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool | list(string) | `[]` | no |
| secretsmanager\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Secrets Manager endpoint | bool | `"false"` | no |
| secretsmanager\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Secrets Manager endpoint | list(string) | `[]` | no |
| secretsmanager\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Secrets Manager endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| single\_nat\_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | bool | `"false"` | no |
| sns\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SNS endpoint | bool | `"false"` | no |
| sns\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SNS endpoint | list(string) | `[]` | no |
| sns\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SNS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| sqs\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SQS endpoint | string | `"false"` | no |
| sqs\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SQS endpoint | list | `[]` | no |
| sqs\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SQS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list | `[]` | no |
| ssm\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SSM endpoint | bool | `"false"` | no |
| ssm\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SSM endpoint | list(string) | `[]` | no |
| ssm\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SSM endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| ssmmessages\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SSMMESSAGES endpoint | bool | `"false"` | no |
| ssmmessages\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SSMMESSAGES endpoint | list(string) | `[]` | no |
| ssmmessages\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SSMMESSAGES endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| tags | A map of tags to add to all resources | map(string) | `{}` | no |
| transferserver\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Transfer Server endpoint | bool | `"false"` | no |
| transferserver\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Transfer Server endpoint | list(string) | `[]` | no |
| transferserver\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Transfer Server endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | list(string) | `[]` | no |
| vpc\_tags | Additional tags for the VPC | map(string) | `{}` | no |
| vpn\_gateway\_id | ID of VPN Gateway to attach to the VPC | string | `""` | no |
| vpn\_gateway\_tags | Additional tags for the VPN gateway | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| azs | A list of availability zones specified as argument to this module |
| database\_network\_acl\_id | ID of the database network ACL |
| database\_route\_table\_ids | List of IDs of database route tables |
| database\_subnet\_arns | List of ARNs of database subnets |
| database\_subnet\_group | ID of database subnet group |
| database\_subnets | List of IDs of database subnets |
| database\_subnets\_cidr\_blocks | List of cidr_blocks of database subnets |
| default\_network\_acl\_id | The ID of the default network ACL |
| default\_route\_table\_id | The ID of the default route table |
| default\_security\_group\_id | The ID of the security group created by default on VPC creation |
| default\_vpc\_cidr\_block | The CIDR block of the VPC |
| default\_vpc\_default\_network\_acl\_id | The ID of the default network ACL |
| default\_vpc\_default\_route\_table\_id | The ID of the default route table |
| default\_vpc\_default\_security\_group\_id | The ID of the security group created by default on VPC creation |
| default\_vpc\_enable\_dns\_hostnames | Whether or not the VPC has DNS hostname support |
| default\_vpc\_enable\_dns\_support | Whether or not the VPC has DNS support |
| default\_vpc\_id | The ID of the VPC |
| default\_vpc\_instance\_tenancy | Tenancy of instances spin up within VPC |
| default\_vpc\_main\_route\_table\_id | The ID of the main route table associated with this VPC |
| elasticache\_network\_acl\_id | ID of the elasticache network ACL |
| elasticache\_route\_table\_ids | List of IDs of elasticache route tables |
| elasticache\_subnet\_arns | List of ARNs of elasticache subnets |
| elasticache\_subnet\_group | ID of elasticache subnet group |
| elasticache\_subnet\_group\_name | Name of elasticache subnet group |
| elasticache\_subnets | List of IDs of elasticache subnets |
| elasticache\_subnets\_cidr\_blocks | List of cidr_blocks of elasticache subnets |
| igw\_id | The ID of the Internet Gateway |
| intra\_network\_acl\_id | ID of the intra network ACL |
| intra\_route\_table\_ids | List of IDs of intra route tables |
| intra\_subnet\_arns | List of ARNs of intra subnets |
| intra\_subnets | List of IDs of intra subnets |
| intra\_subnets\_cidr\_blocks | List of cidr_blocks of intra subnets |
| name | The name of the VPC specified as argument to this module |
| nat\_ids | List of allocation ID of Elastic IPs created for AWS NAT Gateway |
| nat\_public\_ips | List of public Elastic IPs created for AWS NAT Gateway |
| natgw\_ids | List of NAT Gateway IDs |
| private\_network\_acl\_id | ID of the private network ACL |
| private\_route\_table\_ids | List of IDs of private route tables |
| private\_subnet\_arns | List of ARNs of private subnets |
| private\_subnets | List of IDs of private subnets |
| private\_subnets\_cidr\_blocks | List of cidr_blocks of private subnets |
| public\_network\_acl\_id | ID of the public network ACL |
| public\_route\_table\_ids | List of IDs of public route tables |
| public\_subnet\_arns | List of ARNs of public subnets |
| public\_subnets | List of IDs of public subnets |
| public\_subnets\_cidr\_blocks | List of cidr_blocks of public subnets |
| redshift\_network\_acl\_id | ID of the redshift network ACL |
| redshift\_route\_table\_ids | List of IDs of redshift route tables |
| redshift\_subnet\_arns | List of ARNs of redshift subnets |
| redshift\_subnet\_group | ID of redshift subnet group |
| redshift\_subnets | List of IDs of redshift subnets |
| redshift\_subnets\_cidr\_blocks | List of cidr_blocks of redshift subnets |
| vgw\_id | The ID of the VPN Gateway |
| vpc\_arn | The ARN of the VPC |
| vpc\_cidr\_block | The CIDR block of the VPC |
| vpc\_enable\_dns\_hostnames | Whether or not the VPC has DNS hostname support |
| vpc\_enable\_dns\_support | Whether or not the VPC has DNS support |
| vpc\_endpoint\_apigw\_dns\_entry | The DNS entries for the VPC Endpoint for APIGW. |
| vpc\_endpoint\_apigw\_id | The ID of VPC endpoint for APIGW |
| vpc\_endpoint\_apigw\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for APIGW. |
| vpc\_endpoint\_cloudtrail\_dns\_entry | The DNS entries for the VPC Endpoint for CloudTrail. |
| vpc\_endpoint\_cloudtrail\_id | The ID of VPC endpoint for CloudTrail |
| vpc\_endpoint\_cloudtrail\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for CloudTrail. |
| vpc\_endpoint\_dynamodb\_id | The ID of VPC endpoint for DynamoDB |
| vpc\_endpoint\_dynamodb\_pl\_id | The prefix list for the DynamoDB VPC endpoint. |
| vpc\_endpoint\_ec2\_dns\_entry | The DNS entries for the VPC Endpoint for EC2. |
| vpc\_endpoint\_ec2\_id | The ID of VPC endpoint for EC2 |
| vpc\_endpoint\_ec2\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for EC2 |
| vpc\_endpoint\_ec2messages\_dns\_entry | The DNS entries for the VPC Endpoint for EC2MESSAGES. |
| vpc\_endpoint\_ec2messages\_id | The ID of VPC endpoint for EC2MESSAGES |
| vpc\_endpoint\_ec2messages\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for EC2MESSAGES |
| vpc\_endpoint\_ecr\_api\_dns\_entry | The DNS entries for the VPC Endpoint for ECR API. |
| vpc\_endpoint\_ecr\_api\_id | The ID of VPC endpoint for ECR API |
| vpc\_endpoint\_ecr\_api\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for ECR API. |
| vpc\_endpoint\_ecr\_dkr\_dns\_entry | The DNS entries for the VPC Endpoint for ECR DKR. |
| vpc\_endpoint\_ecr\_dkr\_id | The ID of VPC endpoint for ECR DKR |
| vpc\_endpoint\_ecr\_dkr\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for ECR DKR. |
| vpc\_endpoint\_ecs\_agent\_dns\_entry | The DNS entries for the VPC Endpoint for ECS Agent. |
| vpc\_endpoint\_ecs\_agent\_id | The ID of VPC endpoint for ECS Agent |
| vpc\_endpoint\_ecs\_agent\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for ECS Agent. |
| vpc\_endpoint\_ecs\_dns\_entry | The DNS entries for the VPC Endpoint for ECS. |
| vpc\_endpoint\_ecs\_id | The ID of VPC endpoint for ECS |
| vpc\_endpoint\_ecs\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for ECS. |
| vpc\_endpoint\_ecs\_telemetry\_dns\_entry | The DNS entries for the VPC Endpoint for ECS Telemetry. |
| vpc\_endpoint\_ecs\_telemetry\_id | The ID of VPC endpoint for ECS Telemetry |
| vpc\_endpoint\_ecs\_telemetry\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for ECS Telemetry. |
| vpc\_endpoint\_elasticloadbalancing\_dns\_entry | The DNS entries for the VPC Endpoint for Elastic Load Balancing. |
| vpc\_endpoint\_elasticloadbalancing\_id | The ID of VPC endpoint for Elastic Load Balancing |
| vpc\_endpoint\_elasticloadbalancing\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for Elastic Load Balancing. |
| vpc\_endpoint\_events\_dns\_entry | The DNS entries for the VPC Endpoint for CloudWatch Events. |
| vpc\_endpoint\_events\_id | The ID of VPC endpoint for CloudWatch Events |
| vpc\_endpoint\_events\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for CloudWatch Events. |
| vpc\_endpoint\_kms\_dns\_entry | The DNS entries for the VPC Endpoint for KMS. |
| vpc\_endpoint\_kms\_id | The ID of VPC endpoint for KMS |
| vpc\_endpoint\_kms\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for KMS. |
| vpc\_endpoint\_logs\_dns\_entry | The DNS entries for the VPC Endpoint for CloudWatch Logs. |
| vpc\_endpoint\_logs\_id | The ID of VPC endpoint for CloudWatch Logs |
| vpc\_endpoint\_logs\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for CloudWatch Logs. |
| vpc\_endpoint\_monitoring\_dns\_entry | The DNS entries for the VPC Endpoint for CloudWatch Monitoring. |
| vpc\_endpoint\_monitoring\_id | The ID of VPC endpoint for CloudWatch Monitoring |
| vpc\_endpoint\_monitoring\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for CloudWatch Monitoring. |
| vpc\_endpoint\_s3\_id | The ID of VPC endpoint for S3 |
| vpc\_endpoint\_s3\_pl\_id | The prefix list for the S3 VPC endpoint. |
| vpc\_endpoint\_sns\_dns\_entry | The DNS entries for the VPC Endpoint for SNS. |
| vpc\_endpoint\_sns\_id | The ID of VPC endpoint for SNS |
| vpc\_endpoint\_sns\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for SNS. |
| vpc\_endpoint\_sqs\_dns\_entry | The DNS entries for the VPC Endpoint for SQS. |
| vpc\_endpoint\_sqs\_id | The ID of VPC endpoint for SQS |
| vpc\_endpoint\_sqs\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for SQS. |
| vpc\_endpoint\_ssm\_dns\_entry | The DNS entries for the VPC Endpoint for SSM. |
| vpc\_endpoint\_ssm\_id | The ID of VPC endpoint for SSM |
| vpc\_endpoint\_ssm\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for SSM. |
| vpc\_endpoint\_ssmmessages\_dns\_entry | The DNS entries for the VPC Endpoint for SSMMESSAGES. |
| vpc\_endpoint\_ssmmessages\_id | The ID of VPC endpoint for SSMMESSAGES |
| vpc\_endpoint\_ssmmessages\_network\_interface\_ids | One or more network interfaces for the VPC Endpoint for SSMMESSAGES. |
| vpc\_id | The ID of the VPC |
| vpc\_instance\_tenancy | Tenancy of instances spin up within VPC |
| vpc\_main\_route\_table\_id | The ID of the main route table associated with this VPC |
| vpc\_secondary\_cidr\_blocks | List of secondary CIDR blocks of the VPC |

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
