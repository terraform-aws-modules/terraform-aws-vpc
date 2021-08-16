# AWS VPC Terraform module

[![Help Contribute to Open Source](https://www.codetriage.com/terraform-aws-modules/terraform-aws-vpc/badges/users.svg)](https://www.codetriage.com/terraform-aws-modules/terraform-aws-vpc)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/terraform-aws-modules/terraform-aws-vpc)


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
* [VPC Flow Log](https://www.terraform.io/docs/providers/aws/r/flow_log.html)
* [VPC Endpoint](https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html):
  * Gateway: S3, DynamoDB
  * Interface: S3, EC2, SSM, EC2 Messages, SSM Messages, SQS, ECR API, ECR DKR, API Gateway, KMS,
ECS, ECS Agent, ECS Telemetry, SES, SNS, STS, Glue, CloudWatch(Monitoring, Logs, Events),
Elastic Load Balancing, CloudTrail, Secrets Manager, Config, Codeartifact(API, Repositories), CodeBuild, CodeCommit,
Git-Codecommit, Textract, Transfer Server, Kinesis Streams, Kinesis Firehose, SageMaker(Notebook, Runtime, API),
CloudFormation, CodePipeline, Storage Gateway, AppMesh, Transfer, Service Catalog, AppStream API, AppStream Streaming,
Athena, Rekognition, Elastic File System (EFS), Cloud Directory, Elastic Beanstalk (+ Health), Elastic Map Reduce(EMR),
DataSync, EBS, SMS, Elastic Inference Runtime, QLDB Session, Step Functions, Access Analyzer, Auto Scaling Plans,
Application Auto Scaling, Workspaces, ACM PCA, RDS, CodeDeploy, CodeDeploy Commands Secure, DMS

* [RDS DB Subnet Group](https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html)
* [ElastiCache Subnet Group](https://www.terraform.io/docs/providers/aws/r/elasticache_subnet_group.html)
* [Redshift Subnet Group](https://www.terraform.io/docs/providers/aws/r/redshift_subnet_group.html)
* [DHCP Options Set](https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options.html)
* [Default VPC](https://www.terraform.io/docs/providers/aws/r/default_vpc.html)
* [Default Network ACL](https://www.terraform.io/docs/providers/aws/r/default_network_acl.html)

Sponsored by [Cloudcraft - the best way to draw AWS diagrams](https://www.cloudcraft.co/?utm_source=terraform-aws-vpc)

<a href="https://www.cloudcraft.co/?utm_source=terraform-aws-vpc" target="_blank"><img src="https://raw.githubusercontent.com/antonbabenko/modules.tf-lambda/master/misc/cloudcraft-logo.png" alt="Cloudcraft - the best way to draw AWS diagrams" width="211" height="56" /></a>

## Terraform versions

Terraform 0.12 and newer. Pin module version to `~> v2.0`. Submit pull-requests to `master` branch.

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

## VPC Flow Log

VPC Flow Log allows to capture IP traffic for a specific network interface (ENI), subnet, or entire VPC. This module supports enabling or disabling VPC Flow Logs for entire VPC. If you need to have VPC Flow Logs for subnet or ENI, you have to manage it outside of this module with [aws_flow_log resource](https://www.terraform.io/docs/providers/aws/r/flow_log.html).

### Permissions Boundary

If your organization requires a permissions boundary to be attached to the VPC Flow Log role, make sure that you specify an ARN of the permissions boundary policy as `vpc_flow_log_permissions_boundary` argument. Read more about required [IAM policy for publishing flow logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html#flow-logs-iam).

## Conditional creation

Prior to Terraform 0.13, you were unable to specify `count` in a module block. If you wish to toggle the creation of the module's resources in an older (pre 0.13) version of Terraform, you can use the `create_vpc` argument.

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

## Transit Gateway (TGW) integration

It is possible to integrate this VPC module with [terraform-aws-transit-gateway module](https://github.com/terraform-aws-modules/terraform-aws-transit-gateway) which handles the creation of TGW resources and VPC attachments. See [complete example there](https://github.com/terraform-aws-modules/terraform-aws-transit-gateway/tree/master/examples/complete).

## Examples

* [Simple VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/simple-vpc)
* [Simple VPC with secondary CIDR blocks](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/secondary-cidr-blocks)
* [Complete VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete-vpc)
* [VPC with IPv6 enabled](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/ipv6)
* [Network ACL](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/network-acls)
* [VPC Flow Logs](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/vpc-flow-logs)
* [Manage Default VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/manage-default-vpc)
* Few tests and edge cases examples: [#46](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-46-no-private-subnets), [#44](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-44-asymmetric-private-subnets), [#108](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-108-route-already-exists)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.21 |
| aws | >= 2.70 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) |
| [aws_customer_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) |
| [aws_db_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) |
| [aws_default_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) |
| [aws_default_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) |
| [aws_default_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) |
| [aws_default_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) |
| [aws_egress_only_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/egress_only_internet_gateway) |
| [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) |
| [aws_elasticache_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) |
| [aws_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) |
| [aws_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) |
| [aws_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) |
| [aws_network_acl_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) |
| [aws_redshift_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_subnet_group) |
| [aws_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) |
| [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) |
| [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) |
| [aws_vpc_dhcp_options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) |
| [aws_vpc_dhcp_options_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) |
| [aws_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) |
| [aws_vpc_endpoint_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) |
| [aws_vpc_endpoint_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) |
| [aws_vpc_ipv4_cidr_block_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) |
| [aws_vpn_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) |
| [aws_vpn_gateway_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_attachment) |
| [aws_vpn_gateway_route_propagation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_analyzer\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| access\_analyzer\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Access Analyzer endpoint | `bool` | `false` | no |
| access\_analyzer\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Access Analyzer endpoint | `list(string)` | `[]` | no |
| access\_analyzer\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Access Analyzer endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| acm\_pca\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| acm\_pca\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ACM PCA endpoint | `bool` | `false` | no |
| acm\_pca\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ACM PCA endpoint | `list(string)` | `[]` | no |
| acm\_pca\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ACM PCA endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| amazon\_side\_asn | The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN. | `string` | `"64512"` | no |
| apigw\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| apigw\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for API GW endpoint | `bool` | `false` | no |
| apigw\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for API GW  endpoint | `list(string)` | `[]` | no |
| apigw\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for API GW endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| appmesh\_envoy\_management\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for AppMesh endpoint | `bool` | `false` | no |
| appmesh\_envoy\_management\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for AppMesh endpoint | `list(string)` | `[]` | no |
| appmesh\_envoy\_management\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for AppMesh endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| appstream\_api\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for AppStream API endpoint | `bool` | `false` | no |
| appstream\_api\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for AppStream API endpoint | `list(string)` | `[]` | no |
| appstream\_api\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for AppStream API endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| appstream\_streaming\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for AppStream Streaming endpoint | `bool` | `false` | no |
| appstream\_streaming\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for AppStream Streaming endpoint | `list(string)` | `[]` | no |
| appstream\_streaming\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for AppStream Streaming endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| assign\_ipv6\_address\_on\_creation | Assign IPv6 address on subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `false` | no |
| athena\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| athena\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Athena endpoint | `bool` | `false` | no |
| athena\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Athena endpoint | `list(string)` | `[]` | no |
| athena\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Athena endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| auto\_scaling\_plans\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| auto\_scaling\_plans\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Auto Scaling Plans endpoint | `bool` | `false` | no |
| auto\_scaling\_plans\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Auto Scaling Plans endpoint | `list(string)` | `[]` | no |
| auto\_scaling\_plans\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Auto Scaling Plans endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| azs | A list of availability zones names or ids in the region | `list(string)` | `[]` | no |
| cidr | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden | `string` | `"0.0.0.0/0"` | no |
| cloud\_directory\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| cloud\_directory\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Cloud Directory endpoint | `bool` | `false` | no |
| cloud\_directory\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Cloud Directory endpoint | `list(string)` | `[]` | no |
| cloud\_directory\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Cloud Directory endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| cloudformation\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Cloudformation endpoint | `bool` | `false` | no |
| cloudformation\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Cloudformation endpoint | `list(string)` | `[]` | no |
| cloudformation\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Cloudformation endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| cloudtrail\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CloudTrail endpoint | `bool` | `false` | no |
| cloudtrail\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CloudTrail endpoint | `list(string)` | `[]` | no |
| cloudtrail\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CloudTrail endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| codeartifact\_api\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Codeartifact API endpoint | `bool` | `false` | no |
| codeartifact\_api\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Codeartifact API endpoint | `list(string)` | `[]` | no |
| codeartifact\_api\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Codeartifact API endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| codeartifact\_repositories\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Codeartifact repositories endpoint | `bool` | `false` | no |
| codeartifact\_repositories\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Codeartifact repositories endpoint | `list(string)` | `[]` | no |
| codeartifact\_repositories\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Codeartifact repositories endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| codebuild\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| codebuild\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Codebuild endpoint | `bool` | `false` | no |
| codebuild\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Codebuild endpoint | `list(string)` | `[]` | no |
| codebuild\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Codebuilt endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| codecommit\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| codecommit\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Codecommit endpoint | `bool` | `false` | no |
| codecommit\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Codecommit endpoint | `list(string)` | `[]` | no |
| codecommit\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Codecommit endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| codedeploy\_commands\_secure\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CodeDeploy Commands Secure endpoint | `bool` | `false` | no |
| codedeploy\_commands\_secure\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CodeDeploy Commands Secure endpoint | `list(string)` | `[]` | no |
| codedeploy\_commands\_secure\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CodeDeploy Commands Secure endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| codedeploy\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CodeDeploy endpoint | `bool` | `false` | no |
| codedeploy\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CodeDeploy endpoint | `list(string)` | `[]` | no |
| codedeploy\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CodeDeploy endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| codepipeline\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CodePipeline endpoint | `bool` | `false` | no |
| codepipeline\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CodePipeline endpoint | `list(string)` | `[]` | no |
| codepipeline\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CodePipeline endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| config\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for config endpoint | `bool` | `false` | no |
| config\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for config endpoint | `list(string)` | `[]` | no |
| config\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for config endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| create\_database\_internet\_gateway\_route | Controls if an internet gateway route for public database access should be created | `bool` | `false` | no |
| create\_database\_nat\_gateway\_route | Controls if a nat gateway route should be created to give internet access to the database subnets | `bool` | `false` | no |
| create\_database\_subnet\_group | Controls if database subnet group should be created (n.b. database\_subnets must also be set) | `bool` | `true` | no |
| create\_database\_subnet\_route\_table | Controls if separate route table for database should be created | `bool` | `false` | no |
| create\_egress\_only\_igw | Controls if an Egress Only Internet Gateway is created and its related routes. | `bool` | `true` | no |
| create\_elasticache\_subnet\_group | Controls if elasticache subnet group should be created | `bool` | `true` | no |
| create\_elasticache\_subnet\_route\_table | Controls if separate route table for elasticache should be created | `bool` | `false` | no |
| create\_flow\_log\_cloudwatch\_iam\_role | Whether to create IAM role for VPC Flow Logs | `bool` | `false` | no |
| create\_flow\_log\_cloudwatch\_log\_group | Whether to create CloudWatch log group for VPC Flow Logs | `bool` | `false` | no |
| create\_igw | Controls if an Internet Gateway is created for public subnets and the related routes that connect them. | `bool` | `true` | no |
| create\_redshift\_subnet\_group | Controls if redshift subnet group should be created | `bool` | `true` | no |
| create\_redshift\_subnet\_route\_table | Controls if separate route table for redshift should be created | `bool` | `false` | no |
| create\_vpc | Controls if VPC should be created (it affects almost all resources) | `bool` | `true` | no |
| customer\_gateway\_tags | Additional tags for the Customer Gateway | `map(string)` | `{}` | no |
| customer\_gateways | Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address) | `map(map(any))` | `{}` | no |
| database\_acl\_tags | Additional tags for the database subnets network ACL | `map(string)` | `{}` | no |
| database\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for database subnets | `bool` | `false` | no |
| database\_inbound\_acl\_rules | Database subnets inbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| database\_outbound\_acl\_rules | Database subnets outbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| database\_route\_table\_tags | Additional tags for the database route tables | `map(string)` | `{}` | no |
| database\_subnet\_assign\_ipv6\_address\_on\_creation | Assign IPv6 address on database subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| database\_subnet\_group\_tags | Additional tags for the database subnet group | `map(string)` | `{}` | no |
| database\_subnet\_ipv6\_prefixes | Assigns IPv6 database subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| database\_subnet\_suffix | Suffix to append to database subnets name | `string` | `"db"` | no |
| database\_subnet\_tags | Additional tags for the database subnets | `map(string)` | `{}` | no |
| database\_subnets | A list of database subnets | `list(string)` | `[]` | no |
| datasync\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Data Sync endpoint | `bool` | `false` | no |
| datasync\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Data Sync endpoint | `list(string)` | `[]` | no |
| datasync\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Data Sync endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| default\_network\_acl\_egress | List of maps of egress rules to set on the Default Network ACL | `list(map(string))` | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  },<br>  {<br>    "action": "allow",<br>    "from_port": 0,<br>    "ipv6_cidr_block": "::/0",<br>    "protocol": "-1",<br>    "rule_no": 101,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| default\_network\_acl\_ingress | List of maps of ingress rules to set on the Default Network ACL | `list(map(string))` | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  },<br>  {<br>    "action": "allow",<br>    "from_port": 0,<br>    "ipv6_cidr_block": "::/0",<br>    "protocol": "-1",<br>    "rule_no": 101,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| default\_network\_acl\_name | Name to be used on the Default Network ACL | `string` | `""` | no |
| default\_network\_acl\_tags | Additional tags for the Default Network ACL | `map(string)` | `{}` | no |
| default\_route\_table\_propagating\_vgws | List of virtual gateways for propagation | `list(string)` | `[]` | no |
| default\_route\_table\_routes | Configuration block of routes. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table#route | `list(map(string))` | `[]` | no |
| default\_route\_table\_tags | Additional tags for the default route table | `map(string)` | `{}` | no |
| default\_security\_group\_egress | List of maps of egress rules to set on the default security group | `list(map(string))` | `null` | no |
| default\_security\_group\_ingress | List of maps of ingress rules to set on the default security group | `list(map(string))` | `null` | no |
| default\_security\_group\_name | Name to be used on the default security group | `string` | `"default"` | no |
| default\_security\_group\_tags | Additional tags for the default security group | `map(string)` | `{}` | no |
| default\_vpc\_enable\_classiclink | Should be true to enable ClassicLink in the Default VPC | `bool` | `false` | no |
| default\_vpc\_enable\_dns\_hostnames | Should be true to enable DNS hostnames in the Default VPC | `bool` | `false` | no |
| default\_vpc\_enable\_dns\_support | Should be true to enable DNS support in the Default VPC | `bool` | `true` | no |
| default\_vpc\_name | Name to be used on the Default VPC | `string` | `""` | no |
| default\_vpc\_tags | Additional tags for the Default VPC | `map(string)` | `{}` | no |
| dhcp\_options\_domain\_name | Specifies DNS name for DHCP options set (requires enable\_dhcp\_options set to true) | `string` | `""` | no |
| dhcp\_options\_domain\_name\_servers | Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable\_dhcp\_options set to true) | `list(string)` | <pre>[<br>  "AmazonProvidedDNS"<br>]</pre> | no |
| dhcp\_options\_netbios\_name\_servers | Specify a list of netbios servers for DHCP options set (requires enable\_dhcp\_options set to true) | `list(string)` | `[]` | no |
| dhcp\_options\_netbios\_node\_type | Specify netbios node\_type for DHCP options set (requires enable\_dhcp\_options set to true) | `string` | `""` | no |
| dhcp\_options\_ntp\_servers | Specify a list of NTP servers for DHCP options set (requires enable\_dhcp\_options set to true) | `list(string)` | `[]` | no |
| dhcp\_options\_tags | Additional tags for the DHCP option set (requires enable\_dhcp\_options set to true) | `map(string)` | `{}` | no |
| dms\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for DMS endpoint | `bool` | `false` | no |
| dms\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for DMS endpoint | `list(string)` | `[]` | no |
| dms\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for DMS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| dynamodb\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| dynamodb\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for DynamoDB interface endpoint | `bool` | `false` | no |
| dynamodb\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for DynamoDB interface endpoint | `list(string)` | `[]` | no |
| dynamodb\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for DynamoDB interface endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| dynamodb\_endpoint\_type | DynamoDB VPC endpoint type. Note - DynamoDB Interface type support is not yet available | `string` | `"Gateway"` | no |
| ebs\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for EBS endpoint | `bool` | `false` | no |
| ebs\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for EBS endpoint | `list(string)` | `[]` | no |
| ebs\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for EBS endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| ec2\_autoscaling\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| ec2\_autoscaling\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for EC2 Autoscaling endpoint | `bool` | `false` | no |
| ec2\_autoscaling\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for EC2 Autoscaling endpoint | `list(string)` | `[]` | no |
| ec2\_autoscaling\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for EC2 Autoscaling endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| ec2\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| ec2\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for EC2 endpoint | `bool` | `false` | no |
| ec2\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for EC2 endpoint | `list(string)` | `[]` | no |
| ec2\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for EC2 endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| ec2messages\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for EC2MESSAGES endpoint | `bool` | `false` | no |
| ec2messages\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for EC2MESSAGES endpoint | `list(string)` | `[]` | no |
| ec2messages\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for EC2MESSAGES endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| ecr\_api\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| ecr\_api\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ECR API endpoint | `bool` | `false` | no |
| ecr\_api\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ECR API endpoint | `list(string)` | `[]` | no |
| ecr\_api\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ECR api endpoint. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| ecr\_dkr\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| ecr\_dkr\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ECR DKR endpoint | `bool` | `false` | no |
| ecr\_dkr\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ECR DKR endpoint | `list(string)` | `[]` | no |
| ecr\_dkr\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ECR dkr endpoint. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| ecs\_agent\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ECS Agent endpoint | `bool` | `false` | no |
| ecs\_agent\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ECS Agent endpoint | `list(string)` | `[]` | no |
| ecs\_agent\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ECS Agent endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| ecs\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ECS endpoint | `bool` | `false` | no |
| ecs\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ECS endpoint | `list(string)` | `[]` | no |
| ecs\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ECS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| ecs\_telemetry\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for ECS Telemetry endpoint | `bool` | `false` | no |
| ecs\_telemetry\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for ECS Telemetry endpoint | `list(string)` | `[]` | no |
| ecs\_telemetry\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for ECS Telemetry endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| efs\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| efs\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for EFS endpoint | `bool` | `false` | no |
| efs\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for EFS endpoint | `list(string)` | `[]` | no |
| efs\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for EFS endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| elastic\_inference\_runtime\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Elastic Inference Runtime endpoint | `bool` | `false` | no |
| elastic\_inference\_runtime\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Elastic Inference Runtime endpoint | `list(string)` | `[]` | no |
| elastic\_inference\_runtime\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Elastic Inference Runtime endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| elasticache\_acl\_tags | Additional tags for the elasticache subnets network ACL | `map(string)` | `{}` | no |
| elasticache\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for elasticache subnets | `bool` | `false` | no |
| elasticache\_inbound\_acl\_rules | Elasticache subnets inbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| elasticache\_outbound\_acl\_rules | Elasticache subnets outbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| elasticache\_route\_table\_tags | Additional tags for the elasticache route tables | `map(string)` | `{}` | no |
| elasticache\_subnet\_assign\_ipv6\_address\_on\_creation | Assign IPv6 address on elasticache subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| elasticache\_subnet\_ipv6\_prefixes | Assigns IPv6 elasticache subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| elasticache\_subnet\_suffix | Suffix to append to elasticache subnets name | `string` | `"elasticache"` | no |
| elasticache\_subnet\_tags | Additional tags for the elasticache subnets | `map(string)` | `{}` | no |
| elasticache\_subnets | A list of elasticache subnets | `list(string)` | `[]` | no |
| elasticbeanstalk\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| elasticbeanstalk\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Elastic Beanstalk endpoint | `bool` | `false` | no |
| elasticbeanstalk\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Elastic Beanstalk endpoint | `list(string)` | `[]` | no |
| elasticbeanstalk\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Elastic Beanstalk endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| elasticbeanstalk\_health\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Elastic Beanstalk Health endpoint | `bool` | `false` | no |
| elasticbeanstalk\_health\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Elastic Beanstalk Health endpoint | `list(string)` | `[]` | no |
| elasticbeanstalk\_health\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Elastic Beanstalk Health endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| elasticloadbalancing\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| elasticloadbalancing\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Elastic Load Balancing endpoint | `bool` | `false` | no |
| elasticloadbalancing\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Elastic Load Balancing endpoint | `list(string)` | `[]` | no |
| elasticloadbalancing\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Elastic Load Balancing endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| emr\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| emr\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for EMR endpoint | `bool` | `false` | no |
| emr\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for EMR endpoint | `list(string)` | `[]` | no |
| emr\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for EMR endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| enable\_access\_analyzer\_endpoint | Should be true if you want to provision an Access Analyzer endpoint to the VPC | `bool` | `false` | no |
| enable\_acm\_pca\_endpoint | Should be true if you want to provision an ACM PCA endpoint to the VPC | `bool` | `false` | no |
| enable\_apigw\_endpoint | Should be true if you want to provision an api gateway endpoint to the VPC | `bool` | `false` | no |
| enable\_appmesh\_envoy\_management\_endpoint | Should be true if you want to provision a AppMesh endpoint to the VPC | `bool` | `false` | no |
| enable\_appstream\_api\_endpoint | Should be true if you want to provision a AppStream API endpoint to the VPC | `bool` | `false` | no |
| enable\_appstream\_streaming\_endpoint | Should be true if you want to provision a AppStream Streaming endpoint to the VPC | `bool` | `false` | no |
| enable\_athena\_endpoint | Should be true if you want to provision a Athena endpoint to the VPC | `bool` | `false` | no |
| enable\_auto\_scaling\_plans\_endpoint | Should be true if you want to provision an Auto Scaling Plans endpoint to the VPC | `bool` | `false` | no |
| enable\_classiclink | Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic. | `bool` | `null` | no |
| enable\_classiclink\_dns\_support | Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic. | `bool` | `null` | no |
| enable\_cloud\_directory\_endpoint | Should be true if you want to provision an Cloud Directory endpoint to the VPC | `bool` | `false` | no |
| enable\_cloudformation\_endpoint | Should be true if you want to provision a Cloudformation endpoint to the VPC | `bool` | `false` | no |
| enable\_cloudtrail\_endpoint | Should be true if you want to provision a CloudTrail endpoint to the VPC | `bool` | `false` | no |
| enable\_codeartifact\_api\_endpoint | Should be true if you want to provision an Codeartifact API endpoint to the VPC | `bool` | `false` | no |
| enable\_codeartifact\_repositories\_endpoint | Should be true if you want to provision an Codeartifact repositories endpoint to the VPC | `bool` | `false` | no |
| enable\_codebuild\_endpoint | Should be true if you want to provision an Codebuild endpoint to the VPC | `bool` | `false` | no |
| enable\_codecommit\_endpoint | Should be true if you want to provision an Codecommit endpoint to the VPC | `bool` | `false` | no |
| enable\_codedeploy\_commands\_secure\_endpoint | Should be true if you want to provision an CodeDeploy Commands Secure endpoint to the VPC | `bool` | `false` | no |
| enable\_codedeploy\_endpoint | Should be true if you want to provision an CodeDeploy endpoint to the VPC | `bool` | `false` | no |
| enable\_codepipeline\_endpoint | Should be true if you want to provision a CodePipeline endpoint to the VPC | `bool` | `false` | no |
| enable\_config\_endpoint | Should be true if you want to provision an config endpoint to the VPC | `bool` | `false` | no |
| enable\_datasync\_endpoint | Should be true if you want to provision an Data Sync endpoint to the VPC | `bool` | `false` | no |
| enable\_dhcp\_options | Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type | `bool` | `false` | no |
| enable\_dms\_endpoint | Should be true if you want to provision a DMS endpoint to the VPC | `bool` | `false` | no |
| enable\_dns\_hostnames | Should be true to enable DNS hostnames in the VPC | `bool` | `false` | no |
| enable\_dns\_support | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| enable\_dynamodb\_endpoint | Should be true if you want to provision a DynamoDB endpoint to the VPC | `bool` | `false` | no |
| enable\_ebs\_endpoint | Should be true if you want to provision an EBS endpoint to the VPC | `bool` | `false` | no |
| enable\_ec2\_autoscaling\_endpoint | Should be true if you want to provision an EC2 Autoscaling endpoint to the VPC | `bool` | `false` | no |
| enable\_ec2\_endpoint | Should be true if you want to provision an EC2 endpoint to the VPC | `bool` | `false` | no |
| enable\_ec2messages\_endpoint | Should be true if you want to provision an EC2MESSAGES endpoint to the VPC | `bool` | `false` | no |
| enable\_ecr\_api\_endpoint | Should be true if you want to provision an ecr api endpoint to the VPC | `bool` | `false` | no |
| enable\_ecr\_dkr\_endpoint | Should be true if you want to provision an ecr dkr endpoint to the VPC | `bool` | `false` | no |
| enable\_ecs\_agent\_endpoint | Should be true if you want to provision a ECS Agent endpoint to the VPC | `bool` | `false` | no |
| enable\_ecs\_endpoint | Should be true if you want to provision a ECS endpoint to the VPC | `bool` | `false` | no |
| enable\_ecs\_telemetry\_endpoint | Should be true if you want to provision a ECS Telemetry endpoint to the VPC | `bool` | `false` | no |
| enable\_efs\_endpoint | Should be true if you want to provision an EFS endpoint to the VPC | `bool` | `false` | no |
| enable\_elastic\_inference\_runtime\_endpoint | Should be true if you want to provision an Elastic Inference Runtime endpoint to the VPC | `bool` | `false` | no |
| enable\_elasticbeanstalk\_endpoint | Should be true if you want to provision a Elastic Beanstalk endpoint to the VPC | `bool` | `false` | no |
| enable\_elasticbeanstalk\_health\_endpoint | Should be true if you want to provision a Elastic Beanstalk Health endpoint to the VPC | `bool` | `false` | no |
| enable\_elasticloadbalancing\_endpoint | Should be true if you want to provision a Elastic Load Balancing endpoint to the VPC | `bool` | `false` | no |
| enable\_emr\_endpoint | Should be true if you want to provision an EMR endpoint to the VPC | `bool` | `false` | no |
| enable\_events\_endpoint | Should be true if you want to provision a CloudWatch Events endpoint to the VPC | `bool` | `false` | no |
| enable\_flow\_log | Whether or not to enable VPC Flow Logs | `bool` | `false` | no |
| enable\_git\_codecommit\_endpoint | Should be true if you want to provision an Git Codecommit endpoint to the VPC | `bool` | `false` | no |
| enable\_glue\_endpoint | Should be true if you want to provision a Glue endpoint to the VPC | `bool` | `false` | no |
| enable\_ipv6 | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block. | `bool` | `false` | no |
| enable\_kinesis\_firehose\_endpoint | Should be true if you want to provision a Kinesis Firehose endpoint to the VPC | `bool` | `false` | no |
| enable\_kinesis\_streams\_endpoint | Should be true if you want to provision a Kinesis Streams endpoint to the VPC | `bool` | `false` | no |
| enable\_kms\_endpoint | Should be true if you want to provision a KMS endpoint to the VPC | `bool` | `false` | no |
| enable\_lambda\_endpoint | Should be true if you want to provision a Lambda endpoint to the VPC | `bool` | `false` | no |
| enable\_logs\_endpoint | Should be true if you want to provision a CloudWatch Logs endpoint to the VPC | `bool` | `false` | no |
| enable\_monitoring\_endpoint | Should be true if you want to provision a CloudWatch Monitoring endpoint to the VPC | `bool` | `false` | no |
| enable\_nat\_gateway | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `false` | no |
| enable\_public\_redshift | Controls if redshift should have public routing table | `bool` | `false` | no |
| enable\_public\_s3\_endpoint | Whether to enable S3 VPC Endpoint for public subnets | `bool` | `true` | no |
| enable\_qldb\_session\_endpoint | Should be true if you want to provision an QLDB Session endpoint to the VPC | `bool` | `false` | no |
| enable\_rds\_endpoint | Should be true if you want to provision an RDS endpoint to the VPC | `bool` | `false` | no |
| enable\_rekognition\_endpoint | Should be true if you want to provision a Rekognition endpoint to the VPC | `bool` | `false` | no |
| enable\_s3\_endpoint | Should be true if you want to provision an S3 endpoint to the VPC | `bool` | `false` | no |
| enable\_sagemaker\_api\_endpoint | Should be true if you want to provision a SageMaker API endpoint to the VPC | `bool` | `false` | no |
| enable\_sagemaker\_notebook\_endpoint | Should be true if you want to provision a Sagemaker Notebook endpoint to the VPC | `bool` | `false` | no |
| enable\_sagemaker\_runtime\_endpoint | Should be true if you want to provision a SageMaker Runtime endpoint to the VPC | `bool` | `false` | no |
| enable\_secretsmanager\_endpoint | Should be true if you want to provision an Secrets Manager endpoint to the VPC | `bool` | `false` | no |
| enable\_servicecatalog\_endpoint | Should be true if you want to provision a Service Catalog endpoint to the VPC | `bool` | `false` | no |
| enable\_ses\_endpoint | Should be true if you want to provision an SES endpoint to the VPC | `bool` | `false` | no |
| enable\_sms\_endpoint | Should be true if you want to provision an SMS endpoint to the VPC | `bool` | `false` | no |
| enable\_sns\_endpoint | Should be true if you want to provision a SNS endpoint to the VPC | `bool` | `false` | no |
| enable\_sqs\_endpoint | Should be true if you want to provision an SQS endpoint to the VPC | `bool` | `false` | no |
| enable\_ssm\_endpoint | Should be true if you want to provision an SSM endpoint to the VPC | `bool` | `false` | no |
| enable\_ssmmessages\_endpoint | Should be true if you want to provision a SSMMESSAGES endpoint to the VPC | `bool` | `false` | no |
| enable\_states\_endpoint | Should be true if you want to provision a Step Function endpoint to the VPC | `bool` | `false` | no |
| enable\_storagegateway\_endpoint | Should be true if you want to provision a Storage Gateway endpoint to the VPC | `bool` | `false` | no |
| enable\_sts\_endpoint | Should be true if you want to provision a STS endpoint to the VPC | `bool` | `false` | no |
| enable\_textract\_endpoint | Should be true if you want to provision an Textract endpoint to the VPC | `bool` | `false` | no |
| enable\_transfer\_endpoint | Should be true if you want to provision a Transfer endpoint to the VPC | `bool` | `false` | no |
| enable\_transferserver\_endpoint | Should be true if you want to provision a Transfer Server endpoint to the VPC | `bool` | `false` | no |
| enable\_vpn\_gateway | Should be true if you want to create a new VPN Gateway resource and attach it to the VPC | `bool` | `false` | no |
| enable\_workspaces\_endpoint | Should be true if you want to provision an Workspaces endpoint to the VPC | `bool` | `false` | no |
| events\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| events\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Events endpoint | `bool` | `false` | no |
| events\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CloudWatch Events endpoint | `list(string)` | `[]` | no |
| events\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CloudWatch Events endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| external\_nat\_ip\_ids | List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse\_nat\_ips) | `list(string)` | `[]` | no |
| external\_nat\_ips | List of EIPs to be used for `nat_public_ips` output (used in combination with reuse\_nat\_ips and external\_nat\_ip\_ids) | `list(string)` | `[]` | no |
| flow\_log\_cloudwatch\_iam\_role\_arn | The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When flow\_log\_destination\_arn is set to ARN of Cloudwatch Logs, this argument needs to be provided. | `string` | `""` | no |
| flow\_log\_cloudwatch\_log\_group\_kms\_key\_id | The ARN of the KMS Key to use when encrypting log data for VPC flow logs. | `string` | `null` | no |
| flow\_log\_cloudwatch\_log\_group\_name\_prefix | Specifies the name prefix of CloudWatch Log Group for VPC flow logs. | `string` | `"/aws/vpc-flow-log/"` | no |
| flow\_log\_cloudwatch\_log\_group\_retention\_in\_days | Specifies the number of days you want to retain log events in the specified log group for VPC flow logs. | `number` | `null` | no |
| flow\_log\_destination\_arn | The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create\_flow\_log\_cloudwatch\_log\_group is set to false this argument must be provided. | `string` | `""` | no |
| flow\_log\_destination\_type | Type of flow log destination. Can be s3 or cloud-watch-logs. | `string` | `"cloud-watch-logs"` | no |
| flow\_log\_log\_format | The fields to include in the flow log record, in the order in which they should appear. | `string` | `null` | no |
| flow\_log\_max\_aggregation\_interval | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds. | `number` | `600` | no |
| flow\_log\_traffic\_type | The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL. | `string` | `"ALL"` | no |
| git\_codecommit\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Git Codecommit endpoint | `bool` | `false` | no |
| git\_codecommit\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Git Codecommit endpoint | `list(string)` | `[]` | no |
| git\_codecommit\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Git Codecommit endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| glue\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Glue endpoint | `bool` | `false` | no |
| glue\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Glue endpoint | `list(string)` | `[]` | no |
| glue\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Glue endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| igw\_tags | Additional tags for the internet gateway | `map(string)` | `{}` | no |
| instance\_tenancy | A tenancy option for instances launched into the VPC | `string` | `"default"` | no |
| intra\_acl\_tags | Additional tags for the intra subnets network ACL | `map(string)` | `{}` | no |
| intra\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for intra subnets | `bool` | `false` | no |
| intra\_inbound\_acl\_rules | Intra subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| intra\_outbound\_acl\_rules | Intra subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| intra\_route\_table\_tags | Additional tags for the intra route tables | `map(string)` | `{}` | no |
| intra\_subnet\_assign\_ipv6\_address\_on\_creation | Assign IPv6 address on intra subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| intra\_subnet\_ipv6\_prefixes | Assigns IPv6 intra subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| intra\_subnet\_suffix | Suffix to append to intra subnets name | `string` | `"intra"` | no |
| intra\_subnet\_tags | Additional tags for the intra subnets | `map(string)` | `{}` | no |
| intra\_subnets | A list of intra subnets | `list(string)` | `[]` | no |
| kinesis\_firehose\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| kinesis\_firehose\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Kinesis Firehose endpoint | `bool` | `false` | no |
| kinesis\_firehose\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Kinesis Firehose endpoint | `list(string)` | `[]` | no |
| kinesis\_firehose\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Kinesis Firehose endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| kinesis\_streams\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| kinesis\_streams\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Kinesis Streams endpoint | `bool` | `false` | no |
| kinesis\_streams\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Kinesis Streams endpoint | `list(string)` | `[]` | no |
| kinesis\_streams\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Kinesis Streams endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| kms\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| kms\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for KMS endpoint | `bool` | `false` | no |
| kms\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for KMS endpoint | `list(string)` | `[]` | no |
| kms\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for KMS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| lambda\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Lambda endpoint | `bool` | `false` | no |
| lambda\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Lambda endpoint | `list(string)` | `[]` | no |
| lambda\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Lambda endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| logs\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| logs\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Logs endpoint | `bool` | `false` | no |
| logs\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CloudWatch Logs endpoint | `list(string)` | `[]` | no |
| logs\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CloudWatch Logs endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| manage\_default\_network\_acl | Should be true to adopt and manage Default Network ACL | `bool` | `false` | no |
| manage\_default\_route\_table | Should be true to manage default route table | `bool` | `false` | no |
| manage\_default\_security\_group | Should be true to adopt and manage default security group | `bool` | `false` | no |
| manage\_default\_vpc | Should be true to adopt and manage Default VPC | `bool` | `false` | no |
| map\_public\_ip\_on\_launch | Should be false if you do not want to auto-assign public IP on launch | `bool` | `true` | no |
| monitoring\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| monitoring\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Monitoring endpoint | `bool` | `false` | no |
| monitoring\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for CloudWatch Monitoring endpoint | `list(string)` | `[]` | no |
| monitoring\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for CloudWatch Monitoring endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| name | Name to be used on all the resources as identifier | `string` | `""` | no |
| nat\_eip\_tags | Additional tags for the NAT EIP | `map(string)` | `{}` | no |
| nat\_gateway\_tags | Additional tags for the NAT gateways | `map(string)` | `{}` | no |
| one\_nat\_gateway\_per\_az | Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`. | `bool` | `false` | no |
| private\_acl\_tags | Additional tags for the private subnets network ACL | `map(string)` | `{}` | no |
| private\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for private subnets | `bool` | `false` | no |
| private\_inbound\_acl\_rules | Private subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| private\_outbound\_acl\_rules | Private subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| private\_route\_table\_tags | Additional tags for the private route tables | `map(string)` | `{}` | no |
| private\_subnet\_assign\_ipv6\_address\_on\_creation | Assign IPv6 address on private subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| private\_subnet\_ipv6\_prefixes | Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| private\_subnet\_suffix | Suffix to append to private subnets name | `string` | `"private"` | no |
| private\_subnet\_tags | Additional tags for the private subnets | `map(string)` | `{}` | no |
| private\_subnets | A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| propagate\_intra\_route\_tables\_vgw | Should be true if you want route table propagation | `bool` | `false` | no |
| propagate\_private\_route\_tables\_vgw | Should be true if you want route table propagation | `bool` | `false` | no |
| propagate\_public\_route\_tables\_vgw | Should be true if you want route table propagation | `bool` | `false` | no |
| public\_acl\_tags | Additional tags for the public subnets network ACL | `map(string)` | `{}` | no |
| public\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for public subnets | `bool` | `false` | no |
| public\_inbound\_acl\_rules | Public subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| public\_outbound\_acl\_rules | Public subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| public\_route\_table\_tags | Additional tags for the public route tables | `map(string)` | `{}` | no |
| public\_subnet\_assign\_ipv6\_address\_on\_creation | Assign IPv6 address on public subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| public\_subnet\_ipv6\_prefixes | Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| public\_subnet\_suffix | Suffix to append to public subnets name | `string` | `"public"` | no |
| public\_subnet\_tags | Additional tags for the public subnets | `map(string)` | `{}` | no |
| public\_subnets | A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| qldb\_session\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for QLDB Session endpoint | `bool` | `false` | no |
| qldb\_session\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for QLDB Session endpoint | `list(string)` | `[]` | no |
| qldb\_session\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for QLDB Session endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| rds\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for RDS endpoint | `bool` | `false` | no |
| rds\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for RDS endpoint | `list(string)` | `[]` | no |
| rds\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for RDS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| redshift\_acl\_tags | Additional tags for the redshift subnets network ACL | `map(string)` | `{}` | no |
| redshift\_dedicated\_network\_acl | Whether to use dedicated network ACL (not default) and custom rules for redshift subnets | `bool` | `false` | no |
| redshift\_inbound\_acl\_rules | Redshift subnets inbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| redshift\_outbound\_acl\_rules | Redshift subnets outbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| redshift\_route\_table\_tags | Additional tags for the redshift route tables | `map(string)` | `{}` | no |
| redshift\_subnet\_assign\_ipv6\_address\_on\_creation | Assign IPv6 address on redshift subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| redshift\_subnet\_group\_tags | Additional tags for the redshift subnet group | `map(string)` | `{}` | no |
| redshift\_subnet\_ipv6\_prefixes | Assigns IPv6 redshift subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| redshift\_subnet\_suffix | Suffix to append to redshift subnets name | `string` | `"redshift"` | no |
| redshift\_subnet\_tags | Additional tags for the redshift subnets | `map(string)` | `{}` | no |
| redshift\_subnets | A list of redshift subnets | `list(string)` | `[]` | no |
| rekognition\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| rekognition\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Rekognition endpoint | `bool` | `false` | no |
| rekognition\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Rekognition endpoint | `list(string)` | `[]` | no |
| rekognition\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Rekognition endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| reuse\_nat\_ips | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external\_nat\_ip\_ids' variable | `bool` | `false` | no |
| s3\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| s3\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for S3 interface endpoint | `bool` | `false` | no |
| s3\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for S3 interface endpoint | `list(string)` | `[]` | no |
| s3\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for S3 interface endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| s3\_endpoint\_type | S3 VPC endpoint type. Note - S3 Interface type support is only available on AWS provider 3.10 and later | `string` | `"Gateway"` | no |
| sagemaker\_api\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| sagemaker\_api\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SageMaker API endpoint | `bool` | `false` | no |
| sagemaker\_api\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SageMaker API endpoint | `list(string)` | `[]` | no |
| sagemaker\_api\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SageMaker API endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| sagemaker\_notebook\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| sagemaker\_notebook\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Sagemaker Notebook endpoint | `bool` | `false` | no |
| sagemaker\_notebook\_endpoint\_region | Region to use for Sagemaker Notebook endpoint | `string` | `""` | no |
| sagemaker\_notebook\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Sagemaker Notebook endpoint | `list(string)` | `[]` | no |
| sagemaker\_notebook\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Sagemaker Notebook endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| sagemaker\_runtime\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| sagemaker\_runtime\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SageMaker Runtime endpoint | `bool` | `false` | no |
| sagemaker\_runtime\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SageMaker Runtime endpoint | `list(string)` | `[]` | no |
| sagemaker\_runtime\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SageMaker Runtime endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| secondary\_cidr\_blocks | List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool | `list(string)` | `[]` | no |
| secretsmanager\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| secretsmanager\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Secrets Manager endpoint | `bool` | `false` | no |
| secretsmanager\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Secrets Manager endpoint | `list(string)` | `[]` | no |
| secretsmanager\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Secrets Manager endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| servicecatalog\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Service Catalog endpoint | `bool` | `false` | no |
| servicecatalog\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Service Catalog endpoint | `list(string)` | `[]` | no |
| servicecatalog\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Service Catalog endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| ses\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SES endpoint | `bool` | `false` | no |
| ses\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SES endpoint | `list(string)` | `[]` | no |
| ses\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SES endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| single\_nat\_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `false` | no |
| sms\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SMS endpoint | `bool` | `false` | no |
| sms\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SMS endpoint | `list(string)` | `[]` | no |
| sms\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SMS endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| sns\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| sns\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SNS endpoint | `bool` | `false` | no |
| sns\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SNS endpoint | `list(string)` | `[]` | no |
| sns\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SNS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| sqs\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| sqs\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SQS endpoint | `bool` | `false` | no |
| sqs\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SQS endpoint | `list(string)` | `[]` | no |
| sqs\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SQS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| ssm\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SSM endpoint | `bool` | `false` | no |
| ssm\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SSM endpoint | `list(string)` | `[]` | no |
| ssm\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SSM endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| ssmmessages\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for SSMMESSAGES endpoint | `bool` | `false` | no |
| ssmmessages\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for SSMMESSAGES endpoint | `list(string)` | `[]` | no |
| ssmmessages\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for SSMMESSAGES endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| states\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| states\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Step Function endpoint | `bool` | `false` | no |
| states\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Step Function endpoint | `list(string)` | `[]` | no |
| states\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Step Function endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| storagegateway\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Storage Gateway endpoint | `bool` | `false` | no |
| storagegateway\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Storage Gateway endpoint | `list(string)` | `[]` | no |
| storagegateway\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Storage Gateway endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| sts\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| sts\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for STS endpoint | `bool` | `false` | no |
| sts\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for STS endpoint | `list(string)` | `[]` | no |
| sts\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for STS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| textract\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Textract endpoint | `bool` | `false` | no |
| textract\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Textract endpoint | `list(string)` | `[]` | no |
| textract\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Textract endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| transfer\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Transfer endpoint | `bool` | `false` | no |
| transfer\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Transfer endpoint | `list(string)` | `[]` | no |
| transfer\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Transfer endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| transferserver\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Transfer Server endpoint | `bool` | `false` | no |
| transferserver\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Transfer Server endpoint | `list(string)` | `[]` | no |
| transferserver\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Transfer Server endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| vpc\_endpoint\_tags | Additional tags for the VPC Endpoints | `map(string)` | `{}` | no |
| vpc\_flow\_log\_permissions\_boundary | The ARN of the Permissions Boundary for the VPC Flow Log IAM Role | `string` | `null` | no |
| vpc\_flow\_log\_tags | Additional tags for the VPC Flow Logs | `map(string)` | `{}` | no |
| vpc\_tags | Additional tags for the VPC | `map(string)` | `{}` | no |
| vpn\_gateway\_az | The Availability Zone for the VPN Gateway | `string` | `null` | no |
| vpn\_gateway\_id | ID of VPN Gateway to attach to the VPC | `string` | `""` | no |
| vpn\_gateway\_tags | Additional tags for the VPN gateway | `map(string)` | `{}` | no |
| workspaces\_endpoint\_policy | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| workspaces\_endpoint\_private\_dns\_enabled | Whether or not to associate a private hosted zone with the specified VPC for Workspaces endpoint | `bool` | `false` | no |
| workspaces\_endpoint\_security\_group\_ids | The ID of one or more security groups to associate with the network interface for Workspaces endpoint | `list(string)` | `[]` | no |
| workspaces\_endpoint\_subnet\_ids | The ID of one or more subnets in which to create a network interface for Workspaces endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_amazon_side_asn"></a> [amazon\_side\_asn](#input\_amazon\_side\_asn) | The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN. | `string` | `"64512"` | no |
| <a name="input_assign_ipv6_address_on_creation"></a> [assign\_ipv6\_address\_on\_creation](#input\_assign\_ipv6\_address\_on\_creation) | Assign IPv6 address on subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `false` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones names or ids in the region | `list(string)` | `[]` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden | `string` | `"0.0.0.0/0"` | no |
| <a name="input_create_database_internet_gateway_route"></a> [create\_database\_internet\_gateway\_route](#input\_create\_database\_internet\_gateway\_route) | Controls if an internet gateway route for public database access should be created | `bool` | `false` | no |
| <a name="input_create_database_nat_gateway_route"></a> [create\_database\_nat\_gateway\_route](#input\_create\_database\_nat\_gateway\_route) | Controls if a nat gateway route should be created to give internet access to the database subnets | `bool` | `false` | no |
| <a name="input_create_database_subnet_group"></a> [create\_database\_subnet\_group](#input\_create\_database\_subnet\_group) | Controls if database subnet group should be created (n.b. database\_subnets must also be set) | `bool` | `true` | no |
| <a name="input_create_database_subnet_route_table"></a> [create\_database\_subnet\_route\_table](#input\_create\_database\_subnet\_route\_table) | Controls if separate route table for database should be created | `bool` | `false` | no |
| <a name="input_create_egress_only_igw"></a> [create\_egress\_only\_igw](#input\_create\_egress\_only\_igw) | Controls if an Egress Only Internet Gateway is created and its related routes. | `bool` | `true` | no |
| <a name="input_create_elasticache_subnet_group"></a> [create\_elasticache\_subnet\_group](#input\_create\_elasticache\_subnet\_group) | Controls if elasticache subnet group should be created | `bool` | `true` | no |
| <a name="input_create_elasticache_subnet_route_table"></a> [create\_elasticache\_subnet\_route\_table](#input\_create\_elasticache\_subnet\_route\_table) | Controls if separate route table for elasticache should be created | `bool` | `false` | no |
| <a name="input_create_flow_log_cloudwatch_iam_role"></a> [create\_flow\_log\_cloudwatch\_iam\_role](#input\_create\_flow\_log\_cloudwatch\_iam\_role) | Whether to create IAM role for VPC Flow Logs | `bool` | `false` | no |
| <a name="input_create_flow_log_cloudwatch_log_group"></a> [create\_flow\_log\_cloudwatch\_log\_group](#input\_create\_flow\_log\_cloudwatch\_log\_group) | Whether to create CloudWatch log group for VPC Flow Logs | `bool` | `false` | no |
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | Controls if an Internet Gateway is created for public subnets and the related routes that connect them. | `bool` | `true` | no |
| <a name="input_create_redshift_subnet_group"></a> [create\_redshift\_subnet\_group](#input\_create\_redshift\_subnet\_group) | Controls if redshift subnet group should be created | `bool` | `true` | no |
| <a name="input_create_redshift_subnet_route_table"></a> [create\_redshift\_subnet\_route\_table](#input\_create\_redshift\_subnet\_route\_table) | Controls if separate route table for redshift should be created | `bool` | `false` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Controls if VPC should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_customer_gateway_tags"></a> [customer\_gateway\_tags](#input\_customer\_gateway\_tags) | Additional tags for the Customer Gateway | `map(string)` | `{}` | no |
| <a name="input_customer_gateways"></a> [customer\_gateways](#input\_customer\_gateways) | Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address) | `map(map(any))` | `{}` | no |
| <a name="input_database_acl_tags"></a> [database\_acl\_tags](#input\_database\_acl\_tags) | Additional tags for the database subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_database_dedicated_network_acl"></a> [database\_dedicated\_network\_acl](#input\_database\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for database subnets | `bool` | `false` | no |
| <a name="input_database_inbound_acl_rules"></a> [database\_inbound\_acl\_rules](#input\_database\_inbound\_acl\_rules) | Database subnets inbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_database_outbound_acl_rules"></a> [database\_outbound\_acl\_rules](#input\_database\_outbound\_acl\_rules) | Database subnets outbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_database_route_table_tags"></a> [database\_route\_table\_tags](#input\_database\_route\_table\_tags) | Additional tags for the database route tables | `map(string)` | `{}` | no |
| <a name="input_database_subnet_assign_ipv6_address_on_creation"></a> [database\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_database\_subnet\_assign\_ipv6\_address\_on\_creation) | Assign IPv6 address on database subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| <a name="input_database_subnet_group_name"></a> [database\_subnet\_group\_name](#input\_database\_subnet\_group\_name) | Name of database subnet group | `string` | `null` | no |
| <a name="input_database_subnet_group_tags"></a> [database\_subnet\_group\_tags](#input\_database\_subnet\_group\_tags) | Additional tags for the database subnet group | `map(string)` | `{}` | no |
| <a name="input_database_subnet_ipv6_prefixes"></a> [database\_subnet\_ipv6\_prefixes](#input\_database\_subnet\_ipv6\_prefixes) | Assigns IPv6 database subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_database_subnet_suffix"></a> [database\_subnet\_suffix](#input\_database\_subnet\_suffix) | Suffix to append to database subnets name | `string` | `"db"` | no |
| <a name="input_database_subnet_tags"></a> [database\_subnet\_tags](#input\_database\_subnet\_tags) | Additional tags for the database subnets | `map(string)` | `{}` | no |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | A list of database subnets | `list(string)` | `[]` | no |
| <a name="input_default_network_acl_egress"></a> [default\_network\_acl\_egress](#input\_default\_network\_acl\_egress) | List of maps of egress rules to set on the Default Network ACL | `list(map(string))` | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  },<br>  {<br>    "action": "allow",<br>    "from_port": 0,<br>    "ipv6_cidr_block": "::/0",<br>    "protocol": "-1",<br>    "rule_no": 101,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_default_network_acl_ingress"></a> [default\_network\_acl\_ingress](#input\_default\_network\_acl\_ingress) | List of maps of ingress rules to set on the Default Network ACL | `list(map(string))` | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  },<br>  {<br>    "action": "allow",<br>    "from_port": 0,<br>    "ipv6_cidr_block": "::/0",<br>    "protocol": "-1",<br>    "rule_no": 101,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_default_network_acl_name"></a> [default\_network\_acl\_name](#input\_default\_network\_acl\_name) | Name to be used on the Default Network ACL | `string` | `""` | no |
| <a name="input_default_network_acl_tags"></a> [default\_network\_acl\_tags](#input\_default\_network\_acl\_tags) | Additional tags for the Default Network ACL | `map(string)` | `{}` | no |
| <a name="input_default_route_table_propagating_vgws"></a> [default\_route\_table\_propagating\_vgws](#input\_default\_route\_table\_propagating\_vgws) | List of virtual gateways for propagation | `list(string)` | `[]` | no |
| <a name="input_default_route_table_routes"></a> [default\_route\_table\_routes](#input\_default\_route\_table\_routes) | Configuration block of routes. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table#route | `list(map(string))` | `[]` | no |
| <a name="input_default_route_table_tags"></a> [default\_route\_table\_tags](#input\_default\_route\_table\_tags) | Additional tags for the default route table | `map(string)` | `{}` | no |
| <a name="input_default_security_group_egress"></a> [default\_security\_group\_egress](#input\_default\_security\_group\_egress) | List of maps of egress rules to set on the default security group | `list(map(string))` | `null` | no |
| <a name="input_default_security_group_ingress"></a> [default\_security\_group\_ingress](#input\_default\_security\_group\_ingress) | List of maps of ingress rules to set on the default security group | `list(map(string))` | `null` | no |
| <a name="input_default_security_group_name"></a> [default\_security\_group\_name](#input\_default\_security\_group\_name) | Name to be used on the default security group | `string` | `"default"` | no |
| <a name="input_default_security_group_tags"></a> [default\_security\_group\_tags](#input\_default\_security\_group\_tags) | Additional tags for the default security group | `map(string)` | `{}` | no |
| <a name="input_default_vpc_enable_classiclink"></a> [default\_vpc\_enable\_classiclink](#input\_default\_vpc\_enable\_classiclink) | Should be true to enable ClassicLink in the Default VPC | `bool` | `false` | no |
| <a name="input_default_vpc_enable_dns_hostnames"></a> [default\_vpc\_enable\_dns\_hostnames](#input\_default\_vpc\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the Default VPC | `bool` | `false` | no |
| <a name="input_default_vpc_enable_dns_support"></a> [default\_vpc\_enable\_dns\_support](#input\_default\_vpc\_enable\_dns\_support) | Should be true to enable DNS support in the Default VPC | `bool` | `true` | no |
| <a name="input_default_vpc_name"></a> [default\_vpc\_name](#input\_default\_vpc\_name) | Name to be used on the Default VPC | `string` | `""` | no |
| <a name="input_default_vpc_tags"></a> [default\_vpc\_tags](#input\_default\_vpc\_tags) | Additional tags for the Default VPC | `map(string)` | `{}` | no |
| <a name="input_dhcp_options_domain_name"></a> [dhcp\_options\_domain\_name](#input\_dhcp\_options\_domain\_name) | Specifies DNS name for DHCP options set (requires enable\_dhcp\_options set to true) | `string` | `""` | no |
| <a name="input_dhcp_options_domain_name_servers"></a> [dhcp\_options\_domain\_name\_servers](#input\_dhcp\_options\_domain\_name\_servers) | Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable\_dhcp\_options set to true) | `list(string)` | <pre>[<br>  "AmazonProvidedDNS"<br>]</pre> | no |
| <a name="input_dhcp_options_netbios_name_servers"></a> [dhcp\_options\_netbios\_name\_servers](#input\_dhcp\_options\_netbios\_name\_servers) | Specify a list of netbios servers for DHCP options set (requires enable\_dhcp\_options set to true) | `list(string)` | `[]` | no |
| <a name="input_dhcp_options_netbios_node_type"></a> [dhcp\_options\_netbios\_node\_type](#input\_dhcp\_options\_netbios\_node\_type) | Specify netbios node\_type for DHCP options set (requires enable\_dhcp\_options set to true) | `string` | `""` | no |
| <a name="input_dhcp_options_ntp_servers"></a> [dhcp\_options\_ntp\_servers](#input\_dhcp\_options\_ntp\_servers) | Specify a list of NTP servers for DHCP options set (requires enable\_dhcp\_options set to true) | `list(string)` | `[]` | no |
| <a name="input_dhcp_options_tags"></a> [dhcp\_options\_tags](#input\_dhcp\_options\_tags) | Additional tags for the DHCP option set (requires enable\_dhcp\_options set to true) | `map(string)` | `{}` | no |
| <a name="input_elasticache_acl_tags"></a> [elasticache\_acl\_tags](#input\_elasticache\_acl\_tags) | Additional tags for the elasticache subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_elasticache_dedicated_network_acl"></a> [elasticache\_dedicated\_network\_acl](#input\_elasticache\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for elasticache subnets | `bool` | `false` | no |
| <a name="input_elasticache_inbound_acl_rules"></a> [elasticache\_inbound\_acl\_rules](#input\_elasticache\_inbound\_acl\_rules) | Elasticache subnets inbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_elasticache_outbound_acl_rules"></a> [elasticache\_outbound\_acl\_rules](#input\_elasticache\_outbound\_acl\_rules) | Elasticache subnets outbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_elasticache_route_table_tags"></a> [elasticache\_route\_table\_tags](#input\_elasticache\_route\_table\_tags) | Additional tags for the elasticache route tables | `map(string)` | `{}` | no |
| <a name="input_elasticache_subnet_assign_ipv6_address_on_creation"></a> [elasticache\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_elasticache\_subnet\_assign\_ipv6\_address\_on\_creation) | Assign IPv6 address on elasticache subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| <a name="input_elasticache_subnet_ipv6_prefixes"></a> [elasticache\_subnet\_ipv6\_prefixes](#input\_elasticache\_subnet\_ipv6\_prefixes) | Assigns IPv6 elasticache subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_elasticache_subnet_suffix"></a> [elasticache\_subnet\_suffix](#input\_elasticache\_subnet\_suffix) | Suffix to append to elasticache subnets name | `string` | `"elasticache"` | no |
| <a name="input_elasticache_subnet_tags"></a> [elasticache\_subnet\_tags](#input\_elasticache\_subnet\_tags) | Additional tags for the elasticache subnets | `map(string)` | `{}` | no |
| <a name="input_elasticache_subnets"></a> [elasticache\_subnets](#input\_elasticache\_subnets) | A list of elasticache subnets | `list(string)` | `[]` | no |
| <a name="input_enable_classiclink"></a> [enable\_classiclink](#input\_enable\_classiclink) | Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic. | `bool` | `null` | no |
| <a name="input_enable_classiclink_dns_support"></a> [enable\_classiclink\_dns\_support](#input\_enable\_classiclink\_dns\_support) | Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic. | `bool` | `null` | no |
| <a name="input_enable_dhcp_options"></a> [enable\_dhcp\_options](#input\_enable\_dhcp\_options) | Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type | `bool` | `false` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the VPC | `bool` | `false` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | Whether or not to enable VPC Flow Logs | `bool` | `false` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block. | `bool` | `false` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `false` | no |
| <a name="input_enable_public_redshift"></a> [enable\_public\_redshift](#input\_enable\_public\_redshift) | Controls if redshift should have public routing table | `bool` | `false` | no |
| <a name="input_enable_vpn_gateway"></a> [enable\_vpn\_gateway](#input\_enable\_vpn\_gateway) | Should be true if you want to create a new VPN Gateway resource and attach it to the VPC | `bool` | `false` | no |
| <a name="input_external_nat_ip_ids"></a> [external\_nat\_ip\_ids](#input\_external\_nat\_ip\_ids) | List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse\_nat\_ips) | `list(string)` | `[]` | no |
| <a name="input_external_nat_ips"></a> [external\_nat\_ips](#input\_external\_nat\_ips) | List of EIPs to be used for `nat_public_ips` output (used in combination with reuse\_nat\_ips and external\_nat\_ip\_ids) | `list(string)` | `[]` | no |
| <a name="input_flow_log_cloudwatch_iam_role_arn"></a> [flow\_log\_cloudwatch\_iam\_role\_arn](#input\_flow\_log\_cloudwatch\_iam\_role\_arn) | The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When flow\_log\_destination\_arn is set to ARN of Cloudwatch Logs, this argument needs to be provided. | `string` | `""` | no |
| <a name="input_flow_log_cloudwatch_log_group_kms_key_id"></a> [flow\_log\_cloudwatch\_log\_group\_kms\_key\_id](#input\_flow\_log\_cloudwatch\_log\_group\_kms\_key\_id) | The ARN of the KMS Key to use when encrypting log data for VPC flow logs. | `string` | `null` | no |
| <a name="input_flow_log_cloudwatch_log_group_name_prefix"></a> [flow\_log\_cloudwatch\_log\_group\_name\_prefix](#input\_flow\_log\_cloudwatch\_log\_group\_name\_prefix) | Specifies the name prefix of CloudWatch Log Group for VPC flow logs. | `string` | `"/aws/vpc-flow-log/"` | no |
| <a name="input_flow_log_cloudwatch_log_group_retention_in_days"></a> [flow\_log\_cloudwatch\_log\_group\_retention\_in\_days](#input\_flow\_log\_cloudwatch\_log\_group\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group for VPC flow logs. | `number` | `null` | no |
| <a name="input_flow_log_destination_arn"></a> [flow\_log\_destination\_arn](#input\_flow\_log\_destination\_arn) | The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create\_flow\_log\_cloudwatch\_log\_group is set to false this argument must be provided. | `string` | `""` | no |
| <a name="input_flow_log_destination_type"></a> [flow\_log\_destination\_type](#input\_flow\_log\_destination\_type) | Type of flow log destination. Can be s3 or cloud-watch-logs. | `string` | `"cloud-watch-logs"` | no |
| <a name="input_flow_log_log_format"></a> [flow\_log\_log\_format](#input\_flow\_log\_log\_format) | The fields to include in the flow log record, in the order in which they should appear. | `string` | `null` | no |
| <a name="input_flow_log_max_aggregation_interval"></a> [flow\_log\_max\_aggregation\_interval](#input\_flow\_log\_max\_aggregation\_interval) | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds. | `number` | `600` | no |
| <a name="input_flow_log_traffic_type"></a> [flow\_log\_traffic\_type](#input\_flow\_log\_traffic\_type) | The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL. | `string` | `"ALL"` | no |
| <a name="input_igw_tags"></a> [igw\_tags](#input\_igw\_tags) | Additional tags for the internet gateway | `map(string)` | `{}` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | A tenancy option for instances launched into the VPC | `string` | `"default"` | no |
| <a name="input_intra_acl_tags"></a> [intra\_acl\_tags](#input\_intra\_acl\_tags) | Additional tags for the intra subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_intra_dedicated_network_acl"></a> [intra\_dedicated\_network\_acl](#input\_intra\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for intra subnets | `bool` | `false` | no |
| <a name="input_intra_inbound_acl_rules"></a> [intra\_inbound\_acl\_rules](#input\_intra\_inbound\_acl\_rules) | Intra subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_intra_outbound_acl_rules"></a> [intra\_outbound\_acl\_rules](#input\_intra\_outbound\_acl\_rules) | Intra subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_intra_route_table_tags"></a> [intra\_route\_table\_tags](#input\_intra\_route\_table\_tags) | Additional tags for the intra route tables | `map(string)` | `{}` | no |
| <a name="input_intra_subnet_assign_ipv6_address_on_creation"></a> [intra\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_intra\_subnet\_assign\_ipv6\_address\_on\_creation) | Assign IPv6 address on intra subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| <a name="input_intra_subnet_ipv6_prefixes"></a> [intra\_subnet\_ipv6\_prefixes](#input\_intra\_subnet\_ipv6\_prefixes) | Assigns IPv6 intra subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_intra_subnet_suffix"></a> [intra\_subnet\_suffix](#input\_intra\_subnet\_suffix) | Suffix to append to intra subnets name | `string` | `"intra"` | no |
| <a name="input_intra_subnet_tags"></a> [intra\_subnet\_tags](#input\_intra\_subnet\_tags) | Additional tags for the intra subnets | `map(string)` | `{}` | no |
| <a name="input_intra_subnets"></a> [intra\_subnets](#input\_intra\_subnets) | A list of intra subnets | `list(string)` | `[]` | no |
| <a name="input_manage_default_network_acl"></a> [manage\_default\_network\_acl](#input\_manage\_default\_network\_acl) | Should be true to adopt and manage Default Network ACL | `bool` | `false` | no |
| <a name="input_manage_default_route_table"></a> [manage\_default\_route\_table](#input\_manage\_default\_route\_table) | Should be true to manage default route table | `bool` | `false` | no |
| <a name="input_manage_default_security_group"></a> [manage\_default\_security\_group](#input\_manage\_default\_security\_group) | Should be true to adopt and manage default security group | `bool` | `false` | no |
| <a name="input_manage_default_vpc"></a> [manage\_default\_vpc](#input\_manage\_default\_vpc) | Should be true to adopt and manage Default VPC | `bool` | `false` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Should be false if you do not want to auto-assign public IP on launch | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier | `string` | `""` | no |
| <a name="input_nat_eip_tags"></a> [nat\_eip\_tags](#input\_nat\_eip\_tags) | Additional tags for the NAT EIP | `map(string)` | `{}` | no |
| <a name="input_nat_gateway_tags"></a> [nat\_gateway\_tags](#input\_nat\_gateway\_tags) | Additional tags for the NAT gateways | `map(string)` | `{}` | no |
| <a name="input_one_nat_gateway_per_az"></a> [one\_nat\_gateway\_per\_az](#input\_one\_nat\_gateway\_per\_az) | Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`. | `bool` | `false` | no |
| <a name="input_private_acl_tags"></a> [private\_acl\_tags](#input\_private\_acl\_tags) | Additional tags for the private subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_private_dedicated_network_acl"></a> [private\_dedicated\_network\_acl](#input\_private\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for private subnets | `bool` | `false` | no |
| <a name="input_private_eks_subnets"></a> [private\_eks\_subnets](#input\_private\_eks\_subnets) | A list of private eks subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_private_eks_subnet_tags"></a> [private\_eks\_subnet\_tags](#input\_private\_eks\_subnet\_tags) | Additional tags for the private eks subnets | `map(string)` | `{}` | no |
| <a name="input_public_eks_subnets"></a> [public\_eks\_subnets](#input\_public\_eks\_subnets) | A list of public eks subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_public_eks_subnet_tags"></a> [public\_eks\_subnet\_tags](#input\_public\_eks\_subnet\_tags) | Additional tags for the public eks subnets | `map(string)` | `{}` | no |
| <a name="input_private_inbound_acl_rules"></a> [private\_inbound\_acl\_rules](#input\_private\_inbound\_acl\_rules) | Private subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_private_outbound_acl_rules"></a> [private\_outbound\_acl\_rules](#input\_private\_outbound\_acl\_rules) | Private subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_private_route_table_tags"></a> [private\_route\_table\_tags](#input\_private\_route\_table\_tags) | Additional tags for the private route tables | `map(string)` | `{}` | no |
| <a name="input_private_subnet_assign_ipv6_address_on_creation"></a> [private\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_private\_subnet\_assign\_ipv6\_address\_on\_creation) | Assign IPv6 address on private subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| <a name="input_private_subnet_ipv6_prefixes"></a> [private\_subnet\_ipv6\_prefixes](#input\_private\_subnet\_ipv6\_prefixes) | Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_private_subnet_suffix"></a> [private\_subnet\_suffix](#input\_private\_subnet\_suffix) | Suffix to append to private subnets name | `string` | `"private"` | no |
| <a name="input_private_subnet_tags"></a> [private\_subnet\_tags](#input\_private\_subnet\_tags) | Additional tags for the private subnets | `map(string)` | `{}` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_propagate_intra_route_tables_vgw"></a> [propagate\_intra\_route\_tables\_vgw](#input\_propagate\_intra\_route\_tables\_vgw) | Should be true if you want route table propagation | `bool` | `false` | no |
| <a name="input_propagate_private_route_tables_vgw"></a> [propagate\_private\_route\_tables\_vgw](#input\_propagate\_private\_route\_tables\_vgw) | Should be true if you want route table propagation | `bool` | `false` | no |
| <a name="input_propagate_public_route_tables_vgw"></a> [propagate\_public\_route\_tables\_vgw](#input\_propagate\_public\_route\_tables\_vgw) | Should be true if you want route table propagation | `bool` | `false` | no |
| <a name="input_public_acl_tags"></a> [public\_acl\_tags](#input\_public\_acl\_tags) | Additional tags for the public subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_public_dedicated_network_acl"></a> [public\_dedicated\_network\_acl](#input\_public\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for public subnets | `bool` | `false` | no |
| <a name="input_public_inbound_acl_rules"></a> [public\_inbound\_acl\_rules](#input\_public\_inbound\_acl\_rules) | Public subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_public_outbound_acl_rules"></a> [public\_outbound\_acl\_rules](#input\_public\_outbound\_acl\_rules) | Public subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_public_route_table_tags"></a> [public\_route\_table\_tags](#input\_public\_route\_table\_tags) | Additional tags for the public route tables | `map(string)` | `{}` | no |
| <a name="input_public_subnet_assign_ipv6_address_on_creation"></a> [public\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_public\_subnet\_assign\_ipv6\_address\_on\_creation) | Assign IPv6 address on public subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| <a name="input_public_subnet_ipv6_prefixes"></a> [public\_subnet\_ipv6\_prefixes](#input\_public\_subnet\_ipv6\_prefixes) | Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_public_subnet_suffix"></a> [public\_subnet\_suffix](#input\_public\_subnet\_suffix) | Suffix to append to public subnets name | `string` | `"public"` | no |
| <a name="input_public_subnet_tags"></a> [public\_subnet\_tags](#input\_public\_subnet\_tags) | Additional tags for the public subnets | `map(string)` | `{}` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_redshift_acl_tags"></a> [redshift\_acl\_tags](#input\_redshift\_acl\_tags) | Additional tags for the redshift subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_redshift_dedicated_network_acl"></a> [redshift\_dedicated\_network\_acl](#input\_redshift\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for redshift subnets | `bool` | `false` | no |
| <a name="input_redshift_inbound_acl_rules"></a> [redshift\_inbound\_acl\_rules](#input\_redshift\_inbound\_acl\_rules) | Redshift subnets inbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_redshift_outbound_acl_rules"></a> [redshift\_outbound\_acl\_rules](#input\_redshift\_outbound\_acl\_rules) | Redshift subnets outbound network ACL rules | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_redshift_route_table_tags"></a> [redshift\_route\_table\_tags](#input\_redshift\_route\_table\_tags) | Additional tags for the redshift route tables | `map(string)` | `{}` | no |
| <a name="input_redshift_subnet_assign_ipv6_address_on_creation"></a> [redshift\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_redshift\_subnet\_assign\_ipv6\_address\_on\_creation) | Assign IPv6 address on redshift subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| <a name="input_redshift_subnet_group_tags"></a> [redshift\_subnet\_group\_tags](#input\_redshift\_subnet\_group\_tags) | Additional tags for the redshift subnet group | `map(string)` | `{}` | no |
| <a name="input_redshift_subnet_ipv6_prefixes"></a> [redshift\_subnet\_ipv6\_prefixes](#input\_redshift\_subnet\_ipv6\_prefixes) | Assigns IPv6 redshift subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_redshift_subnet_suffix"></a> [redshift\_subnet\_suffix](#input\_redshift\_subnet\_suffix) | Suffix to append to redshift subnets name | `string` | `"redshift"` | no |
| <a name="input_redshift_subnet_tags"></a> [redshift\_subnet\_tags](#input\_redshift\_subnet\_tags) | Additional tags for the redshift subnets | `map(string)` | `{}` | no |
| <a name="input_redshift_subnets"></a> [redshift\_subnets](#input\_redshift\_subnets) | A list of redshift subnets | `list(string)` | `[]` | no |
| <a name="input_reuse_nat_ips"></a> [reuse\_nat\_ips](#input\_reuse\_nat\_ips) | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external\_nat\_ip\_ids' variable | `bool` | `false` | no |
| <a name="input_secondary_cidr_blocks"></a> [secondary\_cidr\_blocks](#input\_secondary\_cidr\_blocks) | List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool | `list(string)` | `[]` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_flow_log_permissions_boundary"></a> [vpc\_flow\_log\_permissions\_boundary](#input\_vpc\_flow\_log\_permissions\_boundary) | The ARN of the Permissions Boundary for the VPC Flow Log IAM Role | `string` | `null` | no |
| <a name="input_vpc_flow_log_tags"></a> [vpc\_flow\_log\_tags](#input\_vpc\_flow\_log\_tags) | Additional tags for the VPC Flow Logs | `map(string)` | `{}` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | Additional tags for the VPC | `map(string)` | `{}` | no |
| <a name="input_vpn_gateway_az"></a> [vpn\_gateway\_az](#input\_vpn\_gateway\_az) | The Availability Zone for the VPN Gateway | `string` | `null` | no |
| <a name="input_vpn_gateway_id"></a> [vpn\_gateway\_id](#input\_vpn\_gateway\_id) | ID of VPN Gateway to attach to the VPC | `string` | `""` | no |
| <a name="input_vpn_gateway_tags"></a> [vpn\_gateway\_tags](#input\_vpn\_gateway\_tags) | Additional tags for the VPN gateway | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azs"></a> [azs](#output\_azs) | A list of availability zones specified as argument to this module |
| <a name="output_cgw_arns"></a> [cgw\_arns](#output\_cgw\_arns) | List of ARNs of Customer Gateway |
| <a name="output_cgw_ids"></a> [cgw\_ids](#output\_cgw\_ids) | List of IDs of Customer Gateway |
| <a name="output_database_internet_gateway_route_id"></a> [database\_internet\_gateway\_route\_id](#output\_database\_internet\_gateway\_route\_id) | ID of the database internet gateway route. |
| <a name="output_database_ipv6_egress_route_id"></a> [database\_ipv6\_egress\_route\_id](#output\_database\_ipv6\_egress\_route\_id) | ID of the database IPv6 egress route. |
| <a name="output_database_nat_gateway_route_ids"></a> [database\_nat\_gateway\_route\_ids](#output\_database\_nat\_gateway\_route\_ids) | List of IDs of the database nat gateway route. |
| <a name="output_database_network_acl_arn"></a> [database\_network\_acl\_arn](#output\_database\_network\_acl\_arn) | ARN of the database network ACL |
| <a name="output_database_network_acl_id"></a> [database\_network\_acl\_id](#output\_database\_network\_acl\_id) | ID of the database network ACL |
| <a name="output_database_route_table_association_ids"></a> [database\_route\_table\_association\_ids](#output\_database\_route\_table\_association\_ids) | List of IDs of the database route table association |
| <a name="output_database_route_table_ids"></a> [database\_route\_table\_ids](#output\_database\_route\_table\_ids) | List of IDs of database route tables |
| <a name="output_database_subnet_arns"></a> [database\_subnet\_arns](#output\_database\_subnet\_arns) | List of ARNs of database subnets |
| <a name="output_database_subnet_group"></a> [database\_subnet\_group](#output\_database\_subnet\_group) | ID of database subnet group |
| <a name="output_database_subnet_group_name"></a> [database\_subnet\_group\_name](#output\_database\_subnet\_group\_name) | Name of database subnet group |
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | List of IDs of database subnets |
| <a name="output_database_subnets_cidr_blocks"></a> [database\_subnets\_cidr\_blocks](#output\_database\_subnets\_cidr\_blocks) | List of cidr\_blocks of database subnets |
| <a name="output_database_subnets_ipv6_cidr_blocks"></a> [database\_subnets\_ipv6\_cidr\_blocks](#output\_database\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of database subnets in an IPv6 enabled VPC |
| <a name="output_default_network_acl_id"></a> [default\_network\_acl\_id](#output\_default\_network\_acl\_id) | The ID of the default network ACL |
| <a name="output_default_route_table_id"></a> [default\_route\_table\_id](#output\_default\_route\_table\_id) | The ID of the default route table |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | The ID of the security group created by default on VPC creation |
| <a name="output_default_vpc_arn"></a> [default\_vpc\_arn](#output\_default\_vpc\_arn) | The ARN of the Default VPC |
| <a name="output_default_vpc_cidr_block"></a> [default\_vpc\_cidr\_block](#output\_default\_vpc\_cidr\_block) | The CIDR block of the Default VPC |
| <a name="output_default_vpc_default_network_acl_id"></a> [default\_vpc\_default\_network\_acl\_id](#output\_default\_vpc\_default\_network\_acl\_id) | The ID of the default network ACL of the Default VPC |
| <a name="output_default_vpc_default_route_table_id"></a> [default\_vpc\_default\_route\_table\_id](#output\_default\_vpc\_default\_route\_table\_id) | The ID of the default route table of the Default VPC |
| <a name="output_default_vpc_default_security_group_id"></a> [default\_vpc\_default\_security\_group\_id](#output\_default\_vpc\_default\_security\_group\_id) | The ID of the security group created by default on Default VPC creation |
| <a name="output_default_vpc_enable_dns_hostnames"></a> [default\_vpc\_enable\_dns\_hostnames](#output\_default\_vpc\_enable\_dns\_hostnames) | Whether or not the Default VPC has DNS hostname support |
| <a name="output_default_vpc_enable_dns_support"></a> [default\_vpc\_enable\_dns\_support](#output\_default\_vpc\_enable\_dns\_support) | Whether or not the Default VPC has DNS support |
| <a name="output_default_vpc_id"></a> [default\_vpc\_id](#output\_default\_vpc\_id) | The ID of the Default VPC |
| <a name="output_default_vpc_instance_tenancy"></a> [default\_vpc\_instance\_tenancy](#output\_default\_vpc\_instance\_tenancy) | Tenancy of instances spin up within Default VPC |
| <a name="output_default_vpc_main_route_table_id"></a> [default\_vpc\_main\_route\_table\_id](#output\_default\_vpc\_main\_route\_table\_id) | The ID of the main route table associated with the Default VPC |
| <a name="output_dhcp_options_id"></a> [dhcp\_options\_id](#output\_dhcp\_options\_id) | The ID of the DHCP options |
| <a name="output_egress_only_internet_gateway_id"></a> [egress\_only\_internet\_gateway\_id](#output\_egress\_only\_internet\_gateway\_id) | The ID of the egress only Internet Gateway |
| <a name="output_elasticache_network_acl_arn"></a> [elasticache\_network\_acl\_arn](#output\_elasticache\_network\_acl\_arn) | ARN of the elasticache network ACL |
| <a name="output_elasticache_network_acl_id"></a> [elasticache\_network\_acl\_id](#output\_elasticache\_network\_acl\_id) | ID of the elasticache network ACL |
| <a name="output_elasticache_route_table_association_ids"></a> [elasticache\_route\_table\_association\_ids](#output\_elasticache\_route\_table\_association\_ids) | List of IDs of the elasticache route table association |
| <a name="output_elasticache_route_table_ids"></a> [elasticache\_route\_table\_ids](#output\_elasticache\_route\_table\_ids) | List of IDs of elasticache route tables |
| <a name="output_elasticache_subnet_arns"></a> [elasticache\_subnet\_arns](#output\_elasticache\_subnet\_arns) | List of ARNs of elasticache subnets |
| <a name="output_elasticache_subnet_group"></a> [elasticache\_subnet\_group](#output\_elasticache\_subnet\_group) | ID of elasticache subnet group |
| <a name="output_elasticache_subnet_group_name"></a> [elasticache\_subnet\_group\_name](#output\_elasticache\_subnet\_group\_name) | Name of elasticache subnet group |
| <a name="output_elasticache_subnets"></a> [elasticache\_subnets](#output\_elasticache\_subnets) | List of IDs of elasticache subnets |
| <a name="output_elasticache_subnets_cidr_blocks"></a> [elasticache\_subnets\_cidr\_blocks](#output\_elasticache\_subnets\_cidr\_blocks) | List of cidr\_blocks of elasticache subnets |
| <a name="output_elasticache_subnets_ipv6_cidr_blocks"></a> [elasticache\_subnets\_ipv6\_cidr\_blocks](#output\_elasticache\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of elasticache subnets in an IPv6 enabled VPC |
| <a name="output_igw_arn"></a> [igw\_arn](#output\_igw\_arn) | The ARN of the Internet Gateway |
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | The ID of the Internet Gateway |
| <a name="output_intra_network_acl_arn"></a> [intra\_network\_acl\_arn](#output\_intra\_network\_acl\_arn) | ARN of the intra network ACL |
| <a name="output_intra_network_acl_id"></a> [intra\_network\_acl\_id](#output\_intra\_network\_acl\_id) | ID of the intra network ACL |
| <a name="output_intra_route_table_association_ids"></a> [intra\_route\_table\_association\_ids](#output\_intra\_route\_table\_association\_ids) | List of IDs of the intra route table association |
| <a name="output_intra_route_table_ids"></a> [intra\_route\_table\_ids](#output\_intra\_route\_table\_ids) | List of IDs of intra route tables |
| <a name="output_intra_subnet_arns"></a> [intra\_subnet\_arns](#output\_intra\_subnet\_arns) | List of ARNs of intra subnets |
| <a name="output_intra_subnets"></a> [intra\_subnets](#output\_intra\_subnets) | List of IDs of intra subnets |
| <a name="output_intra_subnets_cidr_blocks"></a> [intra\_subnets\_cidr\_blocks](#output\_intra\_subnets\_cidr\_blocks) | List of cidr\_blocks of intra subnets |
| <a name="output_intra_subnets_ipv6_cidr_blocks"></a> [intra\_subnets\_ipv6\_cidr\_blocks](#output\_intra\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of intra subnets in an IPv6 enabled VPC |
| <a name="output_name"></a> [name](#output\_name) | The name of the VPC specified as argument to this module |
| <a name="output_nat_ids"></a> [nat\_ids](#output\_nat\_ids) | List of allocation ID of Elastic IPs created for AWS NAT Gateway |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | List of public Elastic IPs created for AWS NAT Gateway |
| <a name="output_natgw_ids"></a> [natgw\_ids](#output\_natgw\_ids) | List of NAT Gateway IDs |
| <a name="output_private_ipv6_egress_route_ids"></a> [private\_ipv6\_egress\_route\_ids](#output\_private\_ipv6\_egress\_route\_ids) | List of IDs of the ipv6 egress route. |
| <a name="output_private_nat_gateway_route_ids"></a> [private\_nat\_gateway\_route\_ids](#output\_private\_nat\_gateway\_route\_ids) | List of IDs of the private nat gateway route. |
| <a name="output_private_network_acl_arn"></a> [private\_network\_acl\_arn](#output\_private\_network\_acl\_arn) | ARN of the private network ACL |
| <a name="output_private_network_acl_id"></a> [private\_network\_acl\_id](#output\_private\_network\_acl\_id) | ID of the private network ACL |
| <a name="output_private_route_table_association_ids"></a> [private\_route\_table\_association\_ids](#output\_private\_route\_table\_association\_ids) | List of IDs of the private route table association |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | List of IDs of private route tables |
| <a name="output_private_subnet_arns"></a> [private\_subnet\_arns](#output\_private\_subnet\_arns) | List of ARNs of private subnets |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of IDs of private subnets |
| <a name="output_private_eks_subnets"></a> [private\_eks\_subnets](#output\_private\_eks\_subnets) | List of IDs of private eks subnets |
| <a name="output_private_eks_subnets_cidr_blocks"></a> [private\_eks_subnets\_cidr\_blocks](#output\_private\_eks_subnets\_cidr\_blocks) | List of cidr\_blocks of private eks subnets |
| <a name="output_public_eks_subnets"></a> [public\_eks\_subnets](#output\_public\_eks\_subnets) | List of IDs of public eks subnets |
| <a name="output_public_eks_subnets_cidr_blocks"></a> [public\_eks_subnets\_cidr\_blocks](#output\_public\_eks_subnets\_cidr\_blocks) | List of cidr\_blocks of public eks subnets |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | List of cidr\_blocks of private subnets |
| <a name="output_private_subnets_ipv6_cidr_blocks"></a> [private\_subnets\_ipv6\_cidr\_blocks](#output\_private\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of private subnets in an IPv6 enabled VPC |
| <a name="output_public_internet_gateway_ipv6_route_id"></a> [public\_internet\_gateway\_ipv6\_route\_id](#output\_public\_internet\_gateway\_ipv6\_route\_id) | ID of the IPv6 internet gateway route. |
| <a name="output_public_internet_gateway_route_id"></a> [public\_internet\_gateway\_route\_id](#output\_public\_internet\_gateway\_route\_id) | ID of the internet gateway route. |
| <a name="output_public_network_acl_arn"></a> [public\_network\_acl\_arn](#output\_public\_network\_acl\_arn) | ARN of the public network ACL |
| <a name="output_public_network_acl_id"></a> [public\_network\_acl\_id](#output\_public\_network\_acl\_id) | ID of the public network ACL |
| <a name="output_public_route_table_association_ids"></a> [public\_route\_table\_association\_ids](#output\_public\_route\_table\_association\_ids) | List of IDs of the public route table association |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | List of IDs of public route tables |
| <a name="output_public_subnet_arns"></a> [public\_subnet\_arns](#output\_public\_subnet\_arns) | List of ARNs of public subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of IDs of public subnets |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | List of cidr\_blocks of public subnets |
| <a name="output_public_subnets_ipv6_cidr_blocks"></a> [public\_subnets\_ipv6\_cidr\_blocks](#output\_public\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of public subnets in an IPv6 enabled VPC |
| <a name="output_redshift_network_acl_arn"></a> [redshift\_network\_acl\_arn](#output\_redshift\_network\_acl\_arn) | ARN of the redshift network ACL |
| <a name="output_redshift_network_acl_id"></a> [redshift\_network\_acl\_id](#output\_redshift\_network\_acl\_id) | ID of the redshift network ACL |
| <a name="output_redshift_public_route_table_association_ids"></a> [redshift\_public\_route\_table\_association\_ids](#output\_redshift\_public\_route\_table\_association\_ids) | List of IDs of the public redshidt route table association |
| <a name="output_redshift_route_table_association_ids"></a> [redshift\_route\_table\_association\_ids](#output\_redshift\_route\_table\_association\_ids) | List of IDs of the redshift route table association |
| <a name="output_redshift_route_table_ids"></a> [redshift\_route\_table\_ids](#output\_redshift\_route\_table\_ids) | List of IDs of redshift route tables |
| <a name="output_redshift_subnet_arns"></a> [redshift\_subnet\_arns](#output\_redshift\_subnet\_arns) | List of ARNs of redshift subnets |
| <a name="output_redshift_subnet_group"></a> [redshift\_subnet\_group](#output\_redshift\_subnet\_group) | ID of redshift subnet group |
| <a name="output_redshift_subnets"></a> [redshift\_subnets](#output\_redshift\_subnets) | List of IDs of redshift subnets |
| <a name="output_redshift_subnets_cidr_blocks"></a> [redshift\_subnets\_cidr\_blocks](#output\_redshift\_subnets\_cidr\_blocks) | List of cidr\_blocks of redshift subnets |
| <a name="output_redshift_subnets_ipv6_cidr_blocks"></a> [redshift\_subnets\_ipv6\_cidr\_blocks](#output\_redshift\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of redshift subnets in an IPv6 enabled VPC |
| <a name="output_this_customer_gateway"></a> [this\_customer\_gateway](#output\_this\_customer\_gateway) | Map of Customer Gateway attributes |
| <a name="output_vgw_arn"></a> [vgw\_arn](#output\_vgw\_arn) | The ARN of the VPN Gateway |
| <a name="output_vgw_id"></a> [vgw\_id](#output\_vgw\_id) | The ID of the VPN Gateway |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | The ARN of the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_enable_dns_hostnames"></a> [vpc\_enable\_dns\_hostnames](#output\_vpc\_enable\_dns\_hostnames) | Whether or not the VPC has DNS hostname support |
| <a name="output_vpc_enable_dns_support"></a> [vpc\_enable\_dns\_support](#output\_vpc\_enable\_dns\_support) | Whether or not the VPC has DNS support |
| <a name="output_vpc_flow_log_cloudwatch_iam_role_arn"></a> [vpc\_flow\_log\_cloudwatch\_iam\_role\_arn](#output\_vpc\_flow\_log\_cloudwatch\_iam\_role\_arn) | The ARN of the IAM role used when pushing logs to Cloudwatch log group |
| <a name="output_vpc_flow_log_destination_arn"></a> [vpc\_flow\_log\_destination\_arn](#output\_vpc\_flow\_log\_destination\_arn) | The ARN of the destination for VPC Flow Logs |
| <a name="output_vpc_flow_log_destination_type"></a> [vpc\_flow\_log\_destination\_type](#output\_vpc\_flow\_log\_destination\_type) | The type of the destination for VPC Flow Logs |
| <a name="output_vpc_flow_log_id"></a> [vpc\_flow\_log\_id](#output\_vpc\_flow\_log\_id) | The ID of the Flow Log resource |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_instance_tenancy"></a> [vpc\_instance\_tenancy](#output\_vpc\_instance\_tenancy) | Tenancy of instances spin up within VPC |
| <a name="output_vpc_ipv6_association_id"></a> [vpc\_ipv6\_association\_id](#output\_vpc\_ipv6\_association\_id) | The association ID for the IPv6 CIDR block |
| <a name="output_vpc_ipv6_cidr_block"></a> [vpc\_ipv6\_cidr\_block](#output\_vpc\_ipv6\_cidr\_block) | The IPv6 CIDR block |
| <a name="output_vpc_main_route_table_id"></a> [vpc\_main\_route\_table\_id](#output\_vpc\_main\_route\_table\_id) | The ID of the main route table associated with this VPC |
| <a name="output_vpc_owner_id"></a> [vpc\_owner\_id](#output\_vpc\_owner\_id) | The ID of the AWS account that owns the VPC |
| <a name="output_vpc_secondary_cidr_blocks"></a> [vpc\_secondary\_cidr\_blocks](#output\_vpc\_secondary\_cidr\_blocks) | List of secondary CIDR blocks of the VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-vpc/graphs/contributors).

## License

Apache 2 Licensed. See LICENSE for full details.
