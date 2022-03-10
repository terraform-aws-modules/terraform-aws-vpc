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
* [VPC with Outpost](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/outpost)
* [Manage Default VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/manage-default-vpc)
* Few tests and edge cases examples: [#46](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-46-no-private-subnets), [#44](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-44-asymmetric-private-subnets), [#108](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-108-route-already-exists)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.21 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.70 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.70 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_customer_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) | resource |
| [aws_db_subnet_group.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_egress_only_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/egress_only_internet_gateway) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_elasticache_subnet_group.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_policy.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.outpost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.database_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.database_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.elasticache_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.elasticache_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.intra_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.intra_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.outpost_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.outpost_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.redshift_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.redshift_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_redshift_subnet_group.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_subnet_group) | resource |
| [aws_route.database_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.database_ipv6_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.database_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_ipv6_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet_gateway_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.outpost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.redshift_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.outpost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_vpc_endpoint.access_analyzer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.acm_pca](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.appmesh_envoy_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.appstream_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.appstream_streaming](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.auto_scaling_plans](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.cloud_directory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.cloudformation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.codeartifact_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.codeartifact_repositories](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.codecommit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.codedeploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.codedeploy_commands_secure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.datasync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.dms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ec2_autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ec2messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecr_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecr_dkr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecs_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ecs_telemetry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.elastic_inference_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.elasticbeanstalk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.elasticbeanstalk_health](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.elasticloadbalancing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.emr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.git_codecommit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.kinesis_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.kinesis_streams](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.qldb_session](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.rekognition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sagemaker_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sagemaker_notebook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sagemaker_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.servicecatalog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ses](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssmmessages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.states](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.storagegateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.textract](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.transfer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.transferserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.workspaces](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_route_table_association.intra_dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.intra_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.private_dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.private_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.public_dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.public_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_ipv4_cidr_block_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_vpn_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) | resource |
| [aws_vpn_gateway_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_attachment) | resource |
| [aws_vpn_gateway_route_propagation.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) | resource |
| [aws_vpn_gateway_route_propagation.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) | resource |
| [aws_vpn_gateway_route_propagation.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) | resource |
| [aws_iam_policy_document.flow_log_cloudwatch_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_vpc_endpoint_service.access_analyzer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.acm_pca](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.appmesh_envoy_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.appstream_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.appstream_streaming](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.auto_scaling_plans](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.cloud_directory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.cloudformation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.codeartifact_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.codeartifact_repositories](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.codecommit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.codedeploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.codedeploy_commands_secure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.datasync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.dms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ec2_autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ec2messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ecr_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ecr_dkr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ecs_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ecs_telemetry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.elastic_inference_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.elasticbeanstalk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.elasticbeanstalk_health](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.elasticloadbalancing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.emr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.git_codecommit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.kinesis_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.kinesis_streams](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.qldb_session](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.rekognition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.sagemaker_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.sagemaker_notebook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.sagemaker_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.servicecatalog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ses](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.sms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.ssmmessages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.states](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.storagegateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.textract](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.transfer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.transferserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [aws_vpc_endpoint_service.workspaces](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_analyzer_endpoint_policy"></a> [access\_analyzer\_endpoint\_policy](#input\_access\_analyzer\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_access_analyzer_endpoint_private_dns_enabled"></a> [access\_analyzer\_endpoint\_private\_dns\_enabled](#input\_access\_analyzer\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Access Analyzer endpoint | `bool` | `false` | no |
| <a name="input_access_analyzer_endpoint_security_group_ids"></a> [access\_analyzer\_endpoint\_security\_group\_ids](#input\_access\_analyzer\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Access Analyzer endpoint | `list(string)` | `[]` | no |
| <a name="input_access_analyzer_endpoint_subnet_ids"></a> [access\_analyzer\_endpoint\_subnet\_ids](#input\_access\_analyzer\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Access Analyzer endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_acm_pca_endpoint_policy"></a> [acm\_pca\_endpoint\_policy](#input\_acm\_pca\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_acm_pca_endpoint_private_dns_enabled"></a> [acm\_pca\_endpoint\_private\_dns\_enabled](#input\_acm\_pca\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for ACM PCA endpoint | `bool` | `false` | no |
| <a name="input_acm_pca_endpoint_security_group_ids"></a> [acm\_pca\_endpoint\_security\_group\_ids](#input\_acm\_pca\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for ACM PCA endpoint | `list(string)` | `[]` | no |
| <a name="input_acm_pca_endpoint_subnet_ids"></a> [acm\_pca\_endpoint\_subnet\_ids](#input\_acm\_pca\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for ACM PCA endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_amazon_side_asn"></a> [amazon\_side\_asn](#input\_amazon\_side\_asn) | The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN. | `string` | `"64512"` | no |
| <a name="input_apigw_endpoint_policy"></a> [apigw\_endpoint\_policy](#input\_apigw\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_apigw_endpoint_private_dns_enabled"></a> [apigw\_endpoint\_private\_dns\_enabled](#input\_apigw\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for API GW endpoint | `bool` | `false` | no |
| <a name="input_apigw_endpoint_security_group_ids"></a> [apigw\_endpoint\_security\_group\_ids](#input\_apigw\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for API GW  endpoint | `list(string)` | `[]` | no |
| <a name="input_apigw_endpoint_subnet_ids"></a> [apigw\_endpoint\_subnet\_ids](#input\_apigw\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for API GW endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_appmesh_envoy_management_endpoint_private_dns_enabled"></a> [appmesh\_envoy\_management\_endpoint\_private\_dns\_enabled](#input\_appmesh\_envoy\_management\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for AppMesh endpoint | `bool` | `false` | no |
| <a name="input_appmesh_envoy_management_endpoint_security_group_ids"></a> [appmesh\_envoy\_management\_endpoint\_security\_group\_ids](#input\_appmesh\_envoy\_management\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for AppMesh endpoint | `list(string)` | `[]` | no |
| <a name="input_appmesh_envoy_management_endpoint_subnet_ids"></a> [appmesh\_envoy\_management\_endpoint\_subnet\_ids](#input\_appmesh\_envoy\_management\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for AppMesh endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_appstream_api_endpoint_private_dns_enabled"></a> [appstream\_api\_endpoint\_private\_dns\_enabled](#input\_appstream\_api\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for AppStream API endpoint | `bool` | `false` | no |
| <a name="input_appstream_api_endpoint_security_group_ids"></a> [appstream\_api\_endpoint\_security\_group\_ids](#input\_appstream\_api\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for AppStream API endpoint | `list(string)` | `[]` | no |
| <a name="input_appstream_api_endpoint_subnet_ids"></a> [appstream\_api\_endpoint\_subnet\_ids](#input\_appstream\_api\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for AppStream API endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_appstream_streaming_endpoint_private_dns_enabled"></a> [appstream\_streaming\_endpoint\_private\_dns\_enabled](#input\_appstream\_streaming\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for AppStream Streaming endpoint | `bool` | `false` | no |
| <a name="input_appstream_streaming_endpoint_security_group_ids"></a> [appstream\_streaming\_endpoint\_security\_group\_ids](#input\_appstream\_streaming\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for AppStream Streaming endpoint | `list(string)` | `[]` | no |
| <a name="input_appstream_streaming_endpoint_subnet_ids"></a> [appstream\_streaming\_endpoint\_subnet\_ids](#input\_appstream\_streaming\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for AppStream Streaming endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_assign_ipv6_address_on_creation"></a> [assign\_ipv6\_address\_on\_creation](#input\_assign\_ipv6\_address\_on\_creation) | Assign IPv6 address on subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `false` | no |
| <a name="input_athena_endpoint_policy"></a> [athena\_endpoint\_policy](#input\_athena\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_athena_endpoint_private_dns_enabled"></a> [athena\_endpoint\_private\_dns\_enabled](#input\_athena\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Athena endpoint | `bool` | `false` | no |
| <a name="input_athena_endpoint_security_group_ids"></a> [athena\_endpoint\_security\_group\_ids](#input\_athena\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Athena endpoint | `list(string)` | `[]` | no |
| <a name="input_athena_endpoint_subnet_ids"></a> [athena\_endpoint\_subnet\_ids](#input\_athena\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Athena endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_auto_scaling_plans_endpoint_policy"></a> [auto\_scaling\_plans\_endpoint\_policy](#input\_auto\_scaling\_plans\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_auto_scaling_plans_endpoint_private_dns_enabled"></a> [auto\_scaling\_plans\_endpoint\_private\_dns\_enabled](#input\_auto\_scaling\_plans\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Auto Scaling Plans endpoint | `bool` | `false` | no |
| <a name="input_auto_scaling_plans_endpoint_security_group_ids"></a> [auto\_scaling\_plans\_endpoint\_security\_group\_ids](#input\_auto\_scaling\_plans\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Auto Scaling Plans endpoint | `list(string)` | `[]` | no |
| <a name="input_auto_scaling_plans_endpoint_subnet_ids"></a> [auto\_scaling\_plans\_endpoint\_subnet\_ids](#input\_auto\_scaling\_plans\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Auto Scaling Plans endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones names or ids in the region | `list(string)` | `[]` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden | `string` | `"0.0.0.0/0"` | no |
| <a name="input_cloud_directory_endpoint_policy"></a> [cloud\_directory\_endpoint\_policy](#input\_cloud\_directory\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_cloud_directory_endpoint_private_dns_enabled"></a> [cloud\_directory\_endpoint\_private\_dns\_enabled](#input\_cloud\_directory\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Cloud Directory endpoint | `bool` | `false` | no |
| <a name="input_cloud_directory_endpoint_security_group_ids"></a> [cloud\_directory\_endpoint\_security\_group\_ids](#input\_cloud\_directory\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Cloud Directory endpoint | `list(string)` | `[]` | no |
| <a name="input_cloud_directory_endpoint_subnet_ids"></a> [cloud\_directory\_endpoint\_subnet\_ids](#input\_cloud\_directory\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Cloud Directory endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_cloudformation_endpoint_private_dns_enabled"></a> [cloudformation\_endpoint\_private\_dns\_enabled](#input\_cloudformation\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Cloudformation endpoint | `bool` | `false` | no |
| <a name="input_cloudformation_endpoint_security_group_ids"></a> [cloudformation\_endpoint\_security\_group\_ids](#input\_cloudformation\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Cloudformation endpoint | `list(string)` | `[]` | no |
| <a name="input_cloudformation_endpoint_subnet_ids"></a> [cloudformation\_endpoint\_subnet\_ids](#input\_cloudformation\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Cloudformation endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_cloudtrail_endpoint_private_dns_enabled"></a> [cloudtrail\_endpoint\_private\_dns\_enabled](#input\_cloudtrail\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for CloudTrail endpoint | `bool` | `false` | no |
| <a name="input_cloudtrail_endpoint_security_group_ids"></a> [cloudtrail\_endpoint\_security\_group\_ids](#input\_cloudtrail\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for CloudTrail endpoint | `list(string)` | `[]` | no |
| <a name="input_cloudtrail_endpoint_subnet_ids"></a> [cloudtrail\_endpoint\_subnet\_ids](#input\_cloudtrail\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for CloudTrail endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_codeartifact_api_endpoint_private_dns_enabled"></a> [codeartifact\_api\_endpoint\_private\_dns\_enabled](#input\_codeartifact\_api\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Codeartifact API endpoint | `bool` | `false` | no |
| <a name="input_codeartifact_api_endpoint_security_group_ids"></a> [codeartifact\_api\_endpoint\_security\_group\_ids](#input\_codeartifact\_api\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Codeartifact API endpoint | `list(string)` | `[]` | no |
| <a name="input_codeartifact_api_endpoint_subnet_ids"></a> [codeartifact\_api\_endpoint\_subnet\_ids](#input\_codeartifact\_api\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Codeartifact API endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_codeartifact_repositories_endpoint_private_dns_enabled"></a> [codeartifact\_repositories\_endpoint\_private\_dns\_enabled](#input\_codeartifact\_repositories\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Codeartifact repositories endpoint | `bool` | `false` | no |
| <a name="input_codeartifact_repositories_endpoint_security_group_ids"></a> [codeartifact\_repositories\_endpoint\_security\_group\_ids](#input\_codeartifact\_repositories\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Codeartifact repositories endpoint | `list(string)` | `[]` | no |
| <a name="input_codeartifact_repositories_endpoint_subnet_ids"></a> [codeartifact\_repositories\_endpoint\_subnet\_ids](#input\_codeartifact\_repositories\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Codeartifact repositories endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_codebuild_endpoint_policy"></a> [codebuild\_endpoint\_policy](#input\_codebuild\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_codebuild_endpoint_private_dns_enabled"></a> [codebuild\_endpoint\_private\_dns\_enabled](#input\_codebuild\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Codebuild endpoint | `bool` | `false` | no |
| <a name="input_codebuild_endpoint_security_group_ids"></a> [codebuild\_endpoint\_security\_group\_ids](#input\_codebuild\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Codebuild endpoint | `list(string)` | `[]` | no |
| <a name="input_codebuild_endpoint_subnet_ids"></a> [codebuild\_endpoint\_subnet\_ids](#input\_codebuild\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Codebuilt endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_codecommit_endpoint_policy"></a> [codecommit\_endpoint\_policy](#input\_codecommit\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_codecommit_endpoint_private_dns_enabled"></a> [codecommit\_endpoint\_private\_dns\_enabled](#input\_codecommit\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Codecommit endpoint | `bool` | `false` | no |
| <a name="input_codecommit_endpoint_security_group_ids"></a> [codecommit\_endpoint\_security\_group\_ids](#input\_codecommit\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Codecommit endpoint | `list(string)` | `[]` | no |
| <a name="input_codecommit_endpoint_subnet_ids"></a> [codecommit\_endpoint\_subnet\_ids](#input\_codecommit\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Codecommit endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_codedeploy_commands_secure_endpoint_private_dns_enabled"></a> [codedeploy\_commands\_secure\_endpoint\_private\_dns\_enabled](#input\_codedeploy\_commands\_secure\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for CodeDeploy Commands Secure endpoint | `bool` | `false` | no |
| <a name="input_codedeploy_commands_secure_endpoint_security_group_ids"></a> [codedeploy\_commands\_secure\_endpoint\_security\_group\_ids](#input\_codedeploy\_commands\_secure\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for CodeDeploy Commands Secure endpoint | `list(string)` | `[]` | no |
| <a name="input_codedeploy_commands_secure_endpoint_subnet_ids"></a> [codedeploy\_commands\_secure\_endpoint\_subnet\_ids](#input\_codedeploy\_commands\_secure\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for CodeDeploy Commands Secure endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_codedeploy_endpoint_private_dns_enabled"></a> [codedeploy\_endpoint\_private\_dns\_enabled](#input\_codedeploy\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for CodeDeploy endpoint | `bool` | `false` | no |
| <a name="input_codedeploy_endpoint_security_group_ids"></a> [codedeploy\_endpoint\_security\_group\_ids](#input\_codedeploy\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for CodeDeploy endpoint | `list(string)` | `[]` | no |
| <a name="input_codedeploy_endpoint_subnet_ids"></a> [codedeploy\_endpoint\_subnet\_ids](#input\_codedeploy\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for CodeDeploy endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_codepipeline_endpoint_private_dns_enabled"></a> [codepipeline\_endpoint\_private\_dns\_enabled](#input\_codepipeline\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for CodePipeline endpoint | `bool` | `false` | no |
| <a name="input_codepipeline_endpoint_security_group_ids"></a> [codepipeline\_endpoint\_security\_group\_ids](#input\_codepipeline\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for CodePipeline endpoint | `list(string)` | `[]` | no |
| <a name="input_codepipeline_endpoint_subnet_ids"></a> [codepipeline\_endpoint\_subnet\_ids](#input\_codepipeline\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for CodePipeline endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_config_endpoint_private_dns_enabled"></a> [config\_endpoint\_private\_dns\_enabled](#input\_config\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for config endpoint | `bool` | `false` | no |
| <a name="input_config_endpoint_security_group_ids"></a> [config\_endpoint\_security\_group\_ids](#input\_config\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for config endpoint | `list(string)` | `[]` | no |
| <a name="input_config_endpoint_subnet_ids"></a> [config\_endpoint\_subnet\_ids](#input\_config\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for config endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
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
| <a name="input_database_subnet_group_tags"></a> [database\_subnet\_group\_tags](#input\_database\_subnet\_group\_tags) | Additional tags for the database subnet group | `map(string)` | `{}` | no |
| <a name="input_database_subnet_ipv6_prefixes"></a> [database\_subnet\_ipv6\_prefixes](#input\_database\_subnet\_ipv6\_prefixes) | Assigns IPv6 database subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_database_subnet_suffix"></a> [database\_subnet\_suffix](#input\_database\_subnet\_suffix) | Suffix to append to database subnets name | `string` | `"db"` | no |
| <a name="input_database_subnet_tags"></a> [database\_subnet\_tags](#input\_database\_subnet\_tags) | Additional tags for the database subnets | `map(string)` | `{}` | no |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | A list of database subnets | `list(string)` | `[]` | no |
| <a name="input_datasync_endpoint_private_dns_enabled"></a> [datasync\_endpoint\_private\_dns\_enabled](#input\_datasync\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Data Sync endpoint | `bool` | `false` | no |
| <a name="input_datasync_endpoint_security_group_ids"></a> [datasync\_endpoint\_security\_group\_ids](#input\_datasync\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Data Sync endpoint | `list(string)` | `[]` | no |
| <a name="input_datasync_endpoint_subnet_ids"></a> [datasync\_endpoint\_subnet\_ids](#input\_datasync\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Data Sync endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
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
| <a name="input_dms_endpoint_private_dns_enabled"></a> [dms\_endpoint\_private\_dns\_enabled](#input\_dms\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for DMS endpoint | `bool` | `false` | no |
| <a name="input_dms_endpoint_security_group_ids"></a> [dms\_endpoint\_security\_group\_ids](#input\_dms\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for DMS endpoint | `list(string)` | `[]` | no |
| <a name="input_dms_endpoint_subnet_ids"></a> [dms\_endpoint\_subnet\_ids](#input\_dms\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for DMS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_dynamodb_endpoint_policy"></a> [dynamodb\_endpoint\_policy](#input\_dynamodb\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_dynamodb_endpoint_private_dns_enabled"></a> [dynamodb\_endpoint\_private\_dns\_enabled](#input\_dynamodb\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for DynamoDB interface endpoint | `bool` | `false` | no |
| <a name="input_dynamodb_endpoint_security_group_ids"></a> [dynamodb\_endpoint\_security\_group\_ids](#input\_dynamodb\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for DynamoDB interface endpoint | `list(string)` | `[]` | no |
| <a name="input_dynamodb_endpoint_subnet_ids"></a> [dynamodb\_endpoint\_subnet\_ids](#input\_dynamodb\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for DynamoDB interface endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_dynamodb_endpoint_type"></a> [dynamodb\_endpoint\_type](#input\_dynamodb\_endpoint\_type) | DynamoDB VPC endpoint type. Note - DynamoDB Interface type support is not yet available | `string` | `"Gateway"` | no |
| <a name="input_ebs_endpoint_private_dns_enabled"></a> [ebs\_endpoint\_private\_dns\_enabled](#input\_ebs\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for EBS endpoint | `bool` | `false` | no |
| <a name="input_ebs_endpoint_security_group_ids"></a> [ebs\_endpoint\_security\_group\_ids](#input\_ebs\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for EBS endpoint | `list(string)` | `[]` | no |
| <a name="input_ebs_endpoint_subnet_ids"></a> [ebs\_endpoint\_subnet\_ids](#input\_ebs\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for EBS endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ec2_autoscaling_endpoint_policy"></a> [ec2\_autoscaling\_endpoint\_policy](#input\_ec2\_autoscaling\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_ec2_autoscaling_endpoint_private_dns_enabled"></a> [ec2\_autoscaling\_endpoint\_private\_dns\_enabled](#input\_ec2\_autoscaling\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for EC2 Autoscaling endpoint | `bool` | `false` | no |
| <a name="input_ec2_autoscaling_endpoint_security_group_ids"></a> [ec2\_autoscaling\_endpoint\_security\_group\_ids](#input\_ec2\_autoscaling\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for EC2 Autoscaling endpoint | `list(string)` | `[]` | no |
| <a name="input_ec2_autoscaling_endpoint_subnet_ids"></a> [ec2\_autoscaling\_endpoint\_subnet\_ids](#input\_ec2\_autoscaling\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for EC2 Autoscaling endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ec2_endpoint_policy"></a> [ec2\_endpoint\_policy](#input\_ec2\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_ec2_endpoint_private_dns_enabled"></a> [ec2\_endpoint\_private\_dns\_enabled](#input\_ec2\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for EC2 endpoint | `bool` | `false` | no |
| <a name="input_ec2_endpoint_security_group_ids"></a> [ec2\_endpoint\_security\_group\_ids](#input\_ec2\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for EC2 endpoint | `list(string)` | `[]` | no |
| <a name="input_ec2_endpoint_subnet_ids"></a> [ec2\_endpoint\_subnet\_ids](#input\_ec2\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for EC2 endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ec2messages_endpoint_private_dns_enabled"></a> [ec2messages\_endpoint\_private\_dns\_enabled](#input\_ec2messages\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for EC2MESSAGES endpoint | `bool` | `false` | no |
| <a name="input_ec2messages_endpoint_security_group_ids"></a> [ec2messages\_endpoint\_security\_group\_ids](#input\_ec2messages\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for EC2MESSAGES endpoint | `list(string)` | `[]` | no |
| <a name="input_ec2messages_endpoint_subnet_ids"></a> [ec2messages\_endpoint\_subnet\_ids](#input\_ec2messages\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for EC2MESSAGES endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ecr_api_endpoint_policy"></a> [ecr\_api\_endpoint\_policy](#input\_ecr\_api\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_ecr_api_endpoint_private_dns_enabled"></a> [ecr\_api\_endpoint\_private\_dns\_enabled](#input\_ecr\_api\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for ECR API endpoint | `bool` | `false` | no |
| <a name="input_ecr_api_endpoint_security_group_ids"></a> [ecr\_api\_endpoint\_security\_group\_ids](#input\_ecr\_api\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for ECR API endpoint | `list(string)` | `[]` | no |
| <a name="input_ecr_api_endpoint_subnet_ids"></a> [ecr\_api\_endpoint\_subnet\_ids](#input\_ecr\_api\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for ECR api endpoint. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ecr_dkr_endpoint_policy"></a> [ecr\_dkr\_endpoint\_policy](#input\_ecr\_dkr\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_ecr_dkr_endpoint_private_dns_enabled"></a> [ecr\_dkr\_endpoint\_private\_dns\_enabled](#input\_ecr\_dkr\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for ECR DKR endpoint | `bool` | `false` | no |
| <a name="input_ecr_dkr_endpoint_security_group_ids"></a> [ecr\_dkr\_endpoint\_security\_group\_ids](#input\_ecr\_dkr\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for ECR DKR endpoint | `list(string)` | `[]` | no |
| <a name="input_ecr_dkr_endpoint_subnet_ids"></a> [ecr\_dkr\_endpoint\_subnet\_ids](#input\_ecr\_dkr\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for ECR dkr endpoint. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ecs_agent_endpoint_private_dns_enabled"></a> [ecs\_agent\_endpoint\_private\_dns\_enabled](#input\_ecs\_agent\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for ECS Agent endpoint | `bool` | `false` | no |
| <a name="input_ecs_agent_endpoint_security_group_ids"></a> [ecs\_agent\_endpoint\_security\_group\_ids](#input\_ecs\_agent\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for ECS Agent endpoint | `list(string)` | `[]` | no |
| <a name="input_ecs_agent_endpoint_subnet_ids"></a> [ecs\_agent\_endpoint\_subnet\_ids](#input\_ecs\_agent\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for ECS Agent endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ecs_endpoint_private_dns_enabled"></a> [ecs\_endpoint\_private\_dns\_enabled](#input\_ecs\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for ECS endpoint | `bool` | `false` | no |
| <a name="input_ecs_endpoint_security_group_ids"></a> [ecs\_endpoint\_security\_group\_ids](#input\_ecs\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for ECS endpoint | `list(string)` | `[]` | no |
| <a name="input_ecs_endpoint_subnet_ids"></a> [ecs\_endpoint\_subnet\_ids](#input\_ecs\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for ECS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ecs_telemetry_endpoint_private_dns_enabled"></a> [ecs\_telemetry\_endpoint\_private\_dns\_enabled](#input\_ecs\_telemetry\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for ECS Telemetry endpoint | `bool` | `false` | no |
| <a name="input_ecs_telemetry_endpoint_security_group_ids"></a> [ecs\_telemetry\_endpoint\_security\_group\_ids](#input\_ecs\_telemetry\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for ECS Telemetry endpoint | `list(string)` | `[]` | no |
| <a name="input_ecs_telemetry_endpoint_subnet_ids"></a> [ecs\_telemetry\_endpoint\_subnet\_ids](#input\_ecs\_telemetry\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for ECS Telemetry endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_efs_endpoint_policy"></a> [efs\_endpoint\_policy](#input\_efs\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_efs_endpoint_private_dns_enabled"></a> [efs\_endpoint\_private\_dns\_enabled](#input\_efs\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for EFS endpoint | `bool` | `false` | no |
| <a name="input_efs_endpoint_security_group_ids"></a> [efs\_endpoint\_security\_group\_ids](#input\_efs\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for EFS endpoint | `list(string)` | `[]` | no |
| <a name="input_efs_endpoint_subnet_ids"></a> [efs\_endpoint\_subnet\_ids](#input\_efs\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for EFS endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_elastic_inference_runtime_endpoint_private_dns_enabled"></a> [elastic\_inference\_runtime\_endpoint\_private\_dns\_enabled](#input\_elastic\_inference\_runtime\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Elastic Inference Runtime endpoint | `bool` | `false` | no |
| <a name="input_elastic_inference_runtime_endpoint_security_group_ids"></a> [elastic\_inference\_runtime\_endpoint\_security\_group\_ids](#input\_elastic\_inference\_runtime\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Elastic Inference Runtime endpoint | `list(string)` | `[]` | no |
| <a name="input_elastic_inference_runtime_endpoint_subnet_ids"></a> [elastic\_inference\_runtime\_endpoint\_subnet\_ids](#input\_elastic\_inference\_runtime\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Elastic Inference Runtime endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
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
| <a name="input_elasticbeanstalk_endpoint_policy"></a> [elasticbeanstalk\_endpoint\_policy](#input\_elasticbeanstalk\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_elasticbeanstalk_endpoint_private_dns_enabled"></a> [elasticbeanstalk\_endpoint\_private\_dns\_enabled](#input\_elasticbeanstalk\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Elastic Beanstalk endpoint | `bool` | `false` | no |
| <a name="input_elasticbeanstalk_endpoint_security_group_ids"></a> [elasticbeanstalk\_endpoint\_security\_group\_ids](#input\_elasticbeanstalk\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Elastic Beanstalk endpoint | `list(string)` | `[]` | no |
| <a name="input_elasticbeanstalk_endpoint_subnet_ids"></a> [elasticbeanstalk\_endpoint\_subnet\_ids](#input\_elasticbeanstalk\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Elastic Beanstalk endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_elasticbeanstalk_health_endpoint_private_dns_enabled"></a> [elasticbeanstalk\_health\_endpoint\_private\_dns\_enabled](#input\_elasticbeanstalk\_health\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Elastic Beanstalk Health endpoint | `bool` | `false` | no |
| <a name="input_elasticbeanstalk_health_endpoint_security_group_ids"></a> [elasticbeanstalk\_health\_endpoint\_security\_group\_ids](#input\_elasticbeanstalk\_health\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Elastic Beanstalk Health endpoint | `list(string)` | `[]` | no |
| <a name="input_elasticbeanstalk_health_endpoint_subnet_ids"></a> [elasticbeanstalk\_health\_endpoint\_subnet\_ids](#input\_elasticbeanstalk\_health\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Elastic Beanstalk Health endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_elasticloadbalancing_endpoint_policy"></a> [elasticloadbalancing\_endpoint\_policy](#input\_elasticloadbalancing\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_elasticloadbalancing_endpoint_private_dns_enabled"></a> [elasticloadbalancing\_endpoint\_private\_dns\_enabled](#input\_elasticloadbalancing\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Elastic Load Balancing endpoint | `bool` | `false` | no |
| <a name="input_elasticloadbalancing_endpoint_security_group_ids"></a> [elasticloadbalancing\_endpoint\_security\_group\_ids](#input\_elasticloadbalancing\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Elastic Load Balancing endpoint | `list(string)` | `[]` | no |
| <a name="input_elasticloadbalancing_endpoint_subnet_ids"></a> [elasticloadbalancing\_endpoint\_subnet\_ids](#input\_elasticloadbalancing\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Elastic Load Balancing endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_emr_endpoint_policy"></a> [emr\_endpoint\_policy](#input\_emr\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_emr_endpoint_private_dns_enabled"></a> [emr\_endpoint\_private\_dns\_enabled](#input\_emr\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for EMR endpoint | `bool` | `false` | no |
| <a name="input_emr_endpoint_security_group_ids"></a> [emr\_endpoint\_security\_group\_ids](#input\_emr\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for EMR endpoint | `list(string)` | `[]` | no |
| <a name="input_emr_endpoint_subnet_ids"></a> [emr\_endpoint\_subnet\_ids](#input\_emr\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for EMR endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_enable_access_analyzer_endpoint"></a> [enable\_access\_analyzer\_endpoint](#input\_enable\_access\_analyzer\_endpoint) | Should be true if you want to provision an Access Analyzer endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_acm_pca_endpoint"></a> [enable\_acm\_pca\_endpoint](#input\_enable\_acm\_pca\_endpoint) | Should be true if you want to provision an ACM PCA endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_apigw_endpoint"></a> [enable\_apigw\_endpoint](#input\_enable\_apigw\_endpoint) | Should be true if you want to provision an api gateway endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_appmesh_envoy_management_endpoint"></a> [enable\_appmesh\_envoy\_management\_endpoint](#input\_enable\_appmesh\_envoy\_management\_endpoint) | Should be true if you want to provision a AppMesh endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_appstream_api_endpoint"></a> [enable\_appstream\_api\_endpoint](#input\_enable\_appstream\_api\_endpoint) | Should be true if you want to provision a AppStream API endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_appstream_streaming_endpoint"></a> [enable\_appstream\_streaming\_endpoint](#input\_enable\_appstream\_streaming\_endpoint) | Should be true if you want to provision a AppStream Streaming endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_athena_endpoint"></a> [enable\_athena\_endpoint](#input\_enable\_athena\_endpoint) | Should be true if you want to provision a Athena endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_auto_scaling_plans_endpoint"></a> [enable\_auto\_scaling\_plans\_endpoint](#input\_enable\_auto\_scaling\_plans\_endpoint) | Should be true if you want to provision an Auto Scaling Plans endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_classiclink"></a> [enable\_classiclink](#input\_enable\_classiclink) | Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic. | `bool` | `null` | no |
| <a name="input_enable_classiclink_dns_support"></a> [enable\_classiclink\_dns\_support](#input\_enable\_classiclink\_dns\_support) | Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic. | `bool` | `null` | no |
| <a name="input_enable_cloud_directory_endpoint"></a> [enable\_cloud\_directory\_endpoint](#input\_enable\_cloud\_directory\_endpoint) | Should be true if you want to provision an Cloud Directory endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_cloudformation_endpoint"></a> [enable\_cloudformation\_endpoint](#input\_enable\_cloudformation\_endpoint) | Should be true if you want to provision a Cloudformation endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_cloudtrail_endpoint"></a> [enable\_cloudtrail\_endpoint](#input\_enable\_cloudtrail\_endpoint) | Should be true if you want to provision a CloudTrail endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_codeartifact_api_endpoint"></a> [enable\_codeartifact\_api\_endpoint](#input\_enable\_codeartifact\_api\_endpoint) | Should be true if you want to provision an Codeartifact API endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_codeartifact_repositories_endpoint"></a> [enable\_codeartifact\_repositories\_endpoint](#input\_enable\_codeartifact\_repositories\_endpoint) | Should be true if you want to provision an Codeartifact repositories endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_codebuild_endpoint"></a> [enable\_codebuild\_endpoint](#input\_enable\_codebuild\_endpoint) | Should be true if you want to provision an Codebuild endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_codecommit_endpoint"></a> [enable\_codecommit\_endpoint](#input\_enable\_codecommit\_endpoint) | Should be true if you want to provision an Codecommit endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_codedeploy_commands_secure_endpoint"></a> [enable\_codedeploy\_commands\_secure\_endpoint](#input\_enable\_codedeploy\_commands\_secure\_endpoint) | Should be true if you want to provision an CodeDeploy Commands Secure endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_codedeploy_endpoint"></a> [enable\_codedeploy\_endpoint](#input\_enable\_codedeploy\_endpoint) | Should be true if you want to provision an CodeDeploy endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_codepipeline_endpoint"></a> [enable\_codepipeline\_endpoint](#input\_enable\_codepipeline\_endpoint) | Should be true if you want to provision a CodePipeline endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_config_endpoint"></a> [enable\_config\_endpoint](#input\_enable\_config\_endpoint) | Should be true if you want to provision an config endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_datasync_endpoint"></a> [enable\_datasync\_endpoint](#input\_enable\_datasync\_endpoint) | Should be true if you want to provision an Data Sync endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_dhcp_options"></a> [enable\_dhcp\_options](#input\_enable\_dhcp\_options) | Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type | `bool` | `false` | no |
| <a name="input_enable_dms_endpoint"></a> [enable\_dms\_endpoint](#input\_enable\_dms\_endpoint) | Should be true if you want to provision a DMS endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the VPC | `bool` | `false` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_enable_dynamodb_endpoint"></a> [enable\_dynamodb\_endpoint](#input\_enable\_dynamodb\_endpoint) | Should be true if you want to provision a DynamoDB endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ebs_endpoint"></a> [enable\_ebs\_endpoint](#input\_enable\_ebs\_endpoint) | Should be true if you want to provision an EBS endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ec2_autoscaling_endpoint"></a> [enable\_ec2\_autoscaling\_endpoint](#input\_enable\_ec2\_autoscaling\_endpoint) | Should be true if you want to provision an EC2 Autoscaling endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ec2_endpoint"></a> [enable\_ec2\_endpoint](#input\_enable\_ec2\_endpoint) | Should be true if you want to provision an EC2 endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ec2messages_endpoint"></a> [enable\_ec2messages\_endpoint](#input\_enable\_ec2messages\_endpoint) | Should be true if you want to provision an EC2MESSAGES endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ecr_api_endpoint"></a> [enable\_ecr\_api\_endpoint](#input\_enable\_ecr\_api\_endpoint) | Should be true if you want to provision an ecr api endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ecr_dkr_endpoint"></a> [enable\_ecr\_dkr\_endpoint](#input\_enable\_ecr\_dkr\_endpoint) | Should be true if you want to provision an ecr dkr endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ecs_agent_endpoint"></a> [enable\_ecs\_agent\_endpoint](#input\_enable\_ecs\_agent\_endpoint) | Should be true if you want to provision a ECS Agent endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ecs_endpoint"></a> [enable\_ecs\_endpoint](#input\_enable\_ecs\_endpoint) | Should be true if you want to provision a ECS endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ecs_telemetry_endpoint"></a> [enable\_ecs\_telemetry\_endpoint](#input\_enable\_ecs\_telemetry\_endpoint) | Should be true if you want to provision a ECS Telemetry endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_efs_endpoint"></a> [enable\_efs\_endpoint](#input\_enable\_efs\_endpoint) | Should be true if you want to provision an EFS endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_elastic_inference_runtime_endpoint"></a> [enable\_elastic\_inference\_runtime\_endpoint](#input\_enable\_elastic\_inference\_runtime\_endpoint) | Should be true if you want to provision an Elastic Inference Runtime endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_elasticbeanstalk_endpoint"></a> [enable\_elasticbeanstalk\_endpoint](#input\_enable\_elasticbeanstalk\_endpoint) | Should be true if you want to provision a Elastic Beanstalk endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_elasticbeanstalk_health_endpoint"></a> [enable\_elasticbeanstalk\_health\_endpoint](#input\_enable\_elasticbeanstalk\_health\_endpoint) | Should be true if you want to provision a Elastic Beanstalk Health endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_elasticloadbalancing_endpoint"></a> [enable\_elasticloadbalancing\_endpoint](#input\_enable\_elasticloadbalancing\_endpoint) | Should be true if you want to provision a Elastic Load Balancing endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_emr_endpoint"></a> [enable\_emr\_endpoint](#input\_enable\_emr\_endpoint) | Should be true if you want to provision an EMR endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_events_endpoint"></a> [enable\_events\_endpoint](#input\_enable\_events\_endpoint) | Should be true if you want to provision a CloudWatch Events endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | Whether or not to enable VPC Flow Logs | `bool` | `false` | no |
| <a name="input_enable_git_codecommit_endpoint"></a> [enable\_git\_codecommit\_endpoint](#input\_enable\_git\_codecommit\_endpoint) | Should be true if you want to provision an Git Codecommit endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_glue_endpoint"></a> [enable\_glue\_endpoint](#input\_enable\_glue\_endpoint) | Should be true if you want to provision a Glue endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block. | `bool` | `false` | no |
| <a name="input_enable_kinesis_firehose_endpoint"></a> [enable\_kinesis\_firehose\_endpoint](#input\_enable\_kinesis\_firehose\_endpoint) | Should be true if you want to provision a Kinesis Firehose endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_kinesis_streams_endpoint"></a> [enable\_kinesis\_streams\_endpoint](#input\_enable\_kinesis\_streams\_endpoint) | Should be true if you want to provision a Kinesis Streams endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_kms_endpoint"></a> [enable\_kms\_endpoint](#input\_enable\_kms\_endpoint) | Should be true if you want to provision a KMS endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_lambda_endpoint"></a> [enable\_lambda\_endpoint](#input\_enable\_lambda\_endpoint) | Should be true if you want to provision a Lambda endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_logs_endpoint"></a> [enable\_logs\_endpoint](#input\_enable\_logs\_endpoint) | Should be true if you want to provision a CloudWatch Logs endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_monitoring_endpoint"></a> [enable\_monitoring\_endpoint](#input\_enable\_monitoring\_endpoint) | Should be true if you want to provision a CloudWatch Monitoring endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `false` | no |
| <a name="input_enable_public_redshift"></a> [enable\_public\_redshift](#input\_enable\_public\_redshift) | Controls if redshift should have public routing table | `bool` | `false` | no |
| <a name="input_enable_public_s3_endpoint"></a> [enable\_public\_s3\_endpoint](#input\_enable\_public\_s3\_endpoint) | Whether to enable S3 VPC Endpoint for public subnets | `bool` | `true` | no |
| <a name="input_enable_qldb_session_endpoint"></a> [enable\_qldb\_session\_endpoint](#input\_enable\_qldb\_session\_endpoint) | Should be true if you want to provision an QLDB Session endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_rds_endpoint"></a> [enable\_rds\_endpoint](#input\_enable\_rds\_endpoint) | Should be true if you want to provision an RDS endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_rekognition_endpoint"></a> [enable\_rekognition\_endpoint](#input\_enable\_rekognition\_endpoint) | Should be true if you want to provision a Rekognition endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_s3_endpoint"></a> [enable\_s3\_endpoint](#input\_enable\_s3\_endpoint) | Should be true if you want to provision an S3 endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_sagemaker_api_endpoint"></a> [enable\_sagemaker\_api\_endpoint](#input\_enable\_sagemaker\_api\_endpoint) | Should be true if you want to provision a SageMaker API endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_sagemaker_notebook_endpoint"></a> [enable\_sagemaker\_notebook\_endpoint](#input\_enable\_sagemaker\_notebook\_endpoint) | Should be true if you want to provision a Sagemaker Notebook endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_sagemaker_runtime_endpoint"></a> [enable\_sagemaker\_runtime\_endpoint](#input\_enable\_sagemaker\_runtime\_endpoint) | Should be true if you want to provision a SageMaker Runtime endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_secretsmanager_endpoint"></a> [enable\_secretsmanager\_endpoint](#input\_enable\_secretsmanager\_endpoint) | Should be true if you want to provision an Secrets Manager endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_servicecatalog_endpoint"></a> [enable\_servicecatalog\_endpoint](#input\_enable\_servicecatalog\_endpoint) | Should be true if you want to provision a Service Catalog endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ses_endpoint"></a> [enable\_ses\_endpoint](#input\_enable\_ses\_endpoint) | Should be true if you want to provision an SES endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_sms_endpoint"></a> [enable\_sms\_endpoint](#input\_enable\_sms\_endpoint) | Should be true if you want to provision an SMS endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_sns_endpoint"></a> [enable\_sns\_endpoint](#input\_enable\_sns\_endpoint) | Should be true if you want to provision a SNS endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_sqs_endpoint"></a> [enable\_sqs\_endpoint](#input\_enable\_sqs\_endpoint) | Should be true if you want to provision an SQS endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ssm_endpoint"></a> [enable\_ssm\_endpoint](#input\_enable\_ssm\_endpoint) | Should be true if you want to provision an SSM endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_ssmmessages_endpoint"></a> [enable\_ssmmessages\_endpoint](#input\_enable\_ssmmessages\_endpoint) | Should be true if you want to provision a SSMMESSAGES endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_states_endpoint"></a> [enable\_states\_endpoint](#input\_enable\_states\_endpoint) | Should be true if you want to provision a Step Function endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_storagegateway_endpoint"></a> [enable\_storagegateway\_endpoint](#input\_enable\_storagegateway\_endpoint) | Should be true if you want to provision a Storage Gateway endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_sts_endpoint"></a> [enable\_sts\_endpoint](#input\_enable\_sts\_endpoint) | Should be true if you want to provision a STS endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_textract_endpoint"></a> [enable\_textract\_endpoint](#input\_enable\_textract\_endpoint) | Should be true if you want to provision an Textract endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_transfer_endpoint"></a> [enable\_transfer\_endpoint](#input\_enable\_transfer\_endpoint) | Should be true if you want to provision a Transfer endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_transferserver_endpoint"></a> [enable\_transferserver\_endpoint](#input\_enable\_transferserver\_endpoint) | Should be true if you want to provision a Transfer Server endpoint to the VPC | `bool` | `false` | no |
| <a name="input_enable_vpn_gateway"></a> [enable\_vpn\_gateway](#input\_enable\_vpn\_gateway) | Should be true if you want to create a new VPN Gateway resource and attach it to the VPC | `bool` | `false` | no |
| <a name="input_enable_workspaces_endpoint"></a> [enable\_workspaces\_endpoint](#input\_enable\_workspaces\_endpoint) | Should be true if you want to provision an Workspaces endpoint to the VPC | `bool` | `false` | no |
| <a name="input_events_endpoint_policy"></a> [events\_endpoint\_policy](#input\_events\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_events_endpoint_private_dns_enabled"></a> [events\_endpoint\_private\_dns\_enabled](#input\_events\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Events endpoint | `bool` | `false` | no |
| <a name="input_events_endpoint_security_group_ids"></a> [events\_endpoint\_security\_group\_ids](#input\_events\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for CloudWatch Events endpoint | `list(string)` | `[]` | no |
| <a name="input_events_endpoint_subnet_ids"></a> [events\_endpoint\_subnet\_ids](#input\_events\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for CloudWatch Events endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
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
| <a name="input_git_codecommit_endpoint_private_dns_enabled"></a> [git\_codecommit\_endpoint\_private\_dns\_enabled](#input\_git\_codecommit\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Git Codecommit endpoint | `bool` | `false` | no |
| <a name="input_git_codecommit_endpoint_security_group_ids"></a> [git\_codecommit\_endpoint\_security\_group\_ids](#input\_git\_codecommit\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Git Codecommit endpoint | `list(string)` | `[]` | no |
| <a name="input_git_codecommit_endpoint_subnet_ids"></a> [git\_codecommit\_endpoint\_subnet\_ids](#input\_git\_codecommit\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Git Codecommit endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_glue_endpoint_private_dns_enabled"></a> [glue\_endpoint\_private\_dns\_enabled](#input\_glue\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Glue endpoint | `bool` | `false` | no |
| <a name="input_glue_endpoint_security_group_ids"></a> [glue\_endpoint\_security\_group\_ids](#input\_glue\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Glue endpoint | `list(string)` | `[]` | no |
| <a name="input_glue_endpoint_subnet_ids"></a> [glue\_endpoint\_subnet\_ids](#input\_glue\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Glue endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
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
| <a name="input_kinesis_firehose_endpoint_policy"></a> [kinesis\_firehose\_endpoint\_policy](#input\_kinesis\_firehose\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_kinesis_firehose_endpoint_private_dns_enabled"></a> [kinesis\_firehose\_endpoint\_private\_dns\_enabled](#input\_kinesis\_firehose\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Kinesis Firehose endpoint | `bool` | `false` | no |
| <a name="input_kinesis_firehose_endpoint_security_group_ids"></a> [kinesis\_firehose\_endpoint\_security\_group\_ids](#input\_kinesis\_firehose\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Kinesis Firehose endpoint | `list(string)` | `[]` | no |
| <a name="input_kinesis_firehose_endpoint_subnet_ids"></a> [kinesis\_firehose\_endpoint\_subnet\_ids](#input\_kinesis\_firehose\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Kinesis Firehose endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_kinesis_streams_endpoint_policy"></a> [kinesis\_streams\_endpoint\_policy](#input\_kinesis\_streams\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_kinesis_streams_endpoint_private_dns_enabled"></a> [kinesis\_streams\_endpoint\_private\_dns\_enabled](#input\_kinesis\_streams\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Kinesis Streams endpoint | `bool` | `false` | no |
| <a name="input_kinesis_streams_endpoint_security_group_ids"></a> [kinesis\_streams\_endpoint\_security\_group\_ids](#input\_kinesis\_streams\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Kinesis Streams endpoint | `list(string)` | `[]` | no |
| <a name="input_kinesis_streams_endpoint_subnet_ids"></a> [kinesis\_streams\_endpoint\_subnet\_ids](#input\_kinesis\_streams\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Kinesis Streams endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_kms_endpoint_policy"></a> [kms\_endpoint\_policy](#input\_kms\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_kms_endpoint_private_dns_enabled"></a> [kms\_endpoint\_private\_dns\_enabled](#input\_kms\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for KMS endpoint | `bool` | `false` | no |
| <a name="input_kms_endpoint_security_group_ids"></a> [kms\_endpoint\_security\_group\_ids](#input\_kms\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for KMS endpoint | `list(string)` | `[]` | no |
| <a name="input_kms_endpoint_subnet_ids"></a> [kms\_endpoint\_subnet\_ids](#input\_kms\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for KMS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_lambda_endpoint_private_dns_enabled"></a> [lambda\_endpoint\_private\_dns\_enabled](#input\_lambda\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Lambda endpoint | `bool` | `false` | no |
| <a name="input_lambda_endpoint_security_group_ids"></a> [lambda\_endpoint\_security\_group\_ids](#input\_lambda\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Lambda endpoint | `list(string)` | `[]` | no |
| <a name="input_lambda_endpoint_subnet_ids"></a> [lambda\_endpoint\_subnet\_ids](#input\_lambda\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Lambda endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_logs_endpoint_policy"></a> [logs\_endpoint\_policy](#input\_logs\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_logs_endpoint_private_dns_enabled"></a> [logs\_endpoint\_private\_dns\_enabled](#input\_logs\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Logs endpoint | `bool` | `false` | no |
| <a name="input_logs_endpoint_security_group_ids"></a> [logs\_endpoint\_security\_group\_ids](#input\_logs\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for CloudWatch Logs endpoint | `list(string)` | `[]` | no |
| <a name="input_logs_endpoint_subnet_ids"></a> [logs\_endpoint\_subnet\_ids](#input\_logs\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for CloudWatch Logs endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_manage_default_network_acl"></a> [manage\_default\_network\_acl](#input\_manage\_default\_network\_acl) | Should be true to adopt and manage Default Network ACL | `bool` | `false` | no |
| <a name="input_manage_default_route_table"></a> [manage\_default\_route\_table](#input\_manage\_default\_route\_table) | Should be true to manage default route table | `bool` | `false` | no |
| <a name="input_manage_default_security_group"></a> [manage\_default\_security\_group](#input\_manage\_default\_security\_group) | Should be true to adopt and manage default security group | `bool` | `false` | no |
| <a name="input_manage_default_vpc"></a> [manage\_default\_vpc](#input\_manage\_default\_vpc) | Should be true to adopt and manage Default VPC | `bool` | `false` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Should be false if you do not want to auto-assign public IP on launch | `bool` | `true` | no |
| <a name="input_monitoring_endpoint_policy"></a> [monitoring\_endpoint\_policy](#input\_monitoring\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_monitoring_endpoint_private_dns_enabled"></a> [monitoring\_endpoint\_private\_dns\_enabled](#input\_monitoring\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for CloudWatch Monitoring endpoint | `bool` | `false` | no |
| <a name="input_monitoring_endpoint_security_group_ids"></a> [monitoring\_endpoint\_security\_group\_ids](#input\_monitoring\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for CloudWatch Monitoring endpoint | `list(string)` | `[]` | no |
| <a name="input_monitoring_endpoint_subnet_ids"></a> [monitoring\_endpoint\_subnet\_ids](#input\_monitoring\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for CloudWatch Monitoring endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier | `string` | `""` | no |
| <a name="input_nat_eip_tags"></a> [nat\_eip\_tags](#input\_nat\_eip\_tags) | Additional tags for the NAT EIP | `map(string)` | `{}` | no |
| <a name="input_nat_gateway_tags"></a> [nat\_gateway\_tags](#input\_nat\_gateway\_tags) | Additional tags for the NAT gateways | `map(string)` | `{}` | no |
| <a name="input_one_nat_gateway_per_az"></a> [one\_nat\_gateway\_per\_az](#input\_one\_nat\_gateway\_per\_az) | Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`. | `bool` | `false` | no |
| <a name="input_outpost_acl_tags"></a> [outpost\_acl\_tags](#input\_outpost\_acl\_tags) | Additional tags for the outpost subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_outpost_arn"></a> [outpost\_arn](#input\_outpost\_arn) | ARN of Outpost you want to create a subnet in. | `string` | `null` | no |
| <a name="input_outpost_az"></a> [outpost\_az](#input\_outpost\_az) | AZ where Outpost is anchored. | `string` | `null` | no |
| <a name="input_outpost_dedicated_network_acl"></a> [outpost\_dedicated\_network\_acl](#input\_outpost\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for outpost subnets | `bool` | `false` | no |
| <a name="input_outpost_inbound_acl_rules"></a> [outpost\_inbound\_acl\_rules](#input\_outpost\_inbound\_acl\_rules) | Outpost subnets inbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_outpost_outbound_acl_rules"></a> [outpost\_outbound\_acl\_rules](#input\_outpost\_outbound\_acl\_rules) | Outpost subnets outbound network ACLs | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_outpost_subnet_assign_ipv6_address_on_creation"></a> [outpost\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_outpost\_subnet\_assign\_ipv6\_address\_on\_creation) | Assign IPv6 address on outpost subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map\_public\_ip\_on\_launch | `bool` | `null` | no |
| <a name="input_outpost_subnet_ipv6_prefixes"></a> [outpost\_subnet\_ipv6\_prefixes](#input\_outpost\_subnet\_ipv6\_prefixes) | Assigns IPv6 outpost subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_outpost_subnet_suffix"></a> [outpost\_subnet\_suffix](#input\_outpost\_subnet\_suffix) | Suffix to append to outpost subnets name | `string` | `"outpost"` | no |
| <a name="input_outpost_subnet_tags"></a> [outpost\_subnet\_tags](#input\_outpost\_subnet\_tags) | Additional tags for the outpost subnets | `map(string)` | `{}` | no |
| <a name="input_outpost_subnets"></a> [outpost\_subnets](#input\_outpost\_subnets) | A list of outpost subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_private_acl_tags"></a> [private\_acl\_tags](#input\_private\_acl\_tags) | Additional tags for the private subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_private_dedicated_network_acl"></a> [private\_dedicated\_network\_acl](#input\_private\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for private subnets | `bool` | `false` | no |
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
| <a name="input_qldb_session_endpoint_private_dns_enabled"></a> [qldb\_session\_endpoint\_private\_dns\_enabled](#input\_qldb\_session\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for QLDB Session endpoint | `bool` | `false` | no |
| <a name="input_qldb_session_endpoint_security_group_ids"></a> [qldb\_session\_endpoint\_security\_group\_ids](#input\_qldb\_session\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for QLDB Session endpoint | `list(string)` | `[]` | no |
| <a name="input_qldb_session_endpoint_subnet_ids"></a> [qldb\_session\_endpoint\_subnet\_ids](#input\_qldb\_session\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for QLDB Session endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_rds_endpoint_private_dns_enabled"></a> [rds\_endpoint\_private\_dns\_enabled](#input\_rds\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for RDS endpoint | `bool` | `false` | no |
| <a name="input_rds_endpoint_security_group_ids"></a> [rds\_endpoint\_security\_group\_ids](#input\_rds\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for RDS endpoint | `list(string)` | `[]` | no |
| <a name="input_rds_endpoint_subnet_ids"></a> [rds\_endpoint\_subnet\_ids](#input\_rds\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for RDS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
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
| <a name="input_rekognition_endpoint_policy"></a> [rekognition\_endpoint\_policy](#input\_rekognition\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_rekognition_endpoint_private_dns_enabled"></a> [rekognition\_endpoint\_private\_dns\_enabled](#input\_rekognition\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Rekognition endpoint | `bool` | `false` | no |
| <a name="input_rekognition_endpoint_security_group_ids"></a> [rekognition\_endpoint\_security\_group\_ids](#input\_rekognition\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Rekognition endpoint | `list(string)` | `[]` | no |
| <a name="input_rekognition_endpoint_subnet_ids"></a> [rekognition\_endpoint\_subnet\_ids](#input\_rekognition\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Rekognition endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_reuse_nat_ips"></a> [reuse\_nat\_ips](#input\_reuse\_nat\_ips) | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external\_nat\_ip\_ids' variable | `bool` | `false` | no |
| <a name="input_s3_endpoint_policy"></a> [s3\_endpoint\_policy](#input\_s3\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_s3_endpoint_private_dns_enabled"></a> [s3\_endpoint\_private\_dns\_enabled](#input\_s3\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for S3 interface endpoint | `bool` | `false` | no |
| <a name="input_s3_endpoint_security_group_ids"></a> [s3\_endpoint\_security\_group\_ids](#input\_s3\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for S3 interface endpoint | `list(string)` | `[]` | no |
| <a name="input_s3_endpoint_subnet_ids"></a> [s3\_endpoint\_subnet\_ids](#input\_s3\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for S3 interface endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_s3_endpoint_type"></a> [s3\_endpoint\_type](#input\_s3\_endpoint\_type) | S3 VPC endpoint type. Note - S3 Interface type support is only available on AWS provider 3.10 and later | `string` | `"Gateway"` | no |
| <a name="input_sagemaker_api_endpoint_policy"></a> [sagemaker\_api\_endpoint\_policy](#input\_sagemaker\_api\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_sagemaker_api_endpoint_private_dns_enabled"></a> [sagemaker\_api\_endpoint\_private\_dns\_enabled](#input\_sagemaker\_api\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for SageMaker API endpoint | `bool` | `false` | no |
| <a name="input_sagemaker_api_endpoint_security_group_ids"></a> [sagemaker\_api\_endpoint\_security\_group\_ids](#input\_sagemaker\_api\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for SageMaker API endpoint | `list(string)` | `[]` | no |
| <a name="input_sagemaker_api_endpoint_subnet_ids"></a> [sagemaker\_api\_endpoint\_subnet\_ids](#input\_sagemaker\_api\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for SageMaker API endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_sagemaker_notebook_endpoint_policy"></a> [sagemaker\_notebook\_endpoint\_policy](#input\_sagemaker\_notebook\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_sagemaker_notebook_endpoint_private_dns_enabled"></a> [sagemaker\_notebook\_endpoint\_private\_dns\_enabled](#input\_sagemaker\_notebook\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Sagemaker Notebook endpoint | `bool` | `false` | no |
| <a name="input_sagemaker_notebook_endpoint_region"></a> [sagemaker\_notebook\_endpoint\_region](#input\_sagemaker\_notebook\_endpoint\_region) | Region to use for Sagemaker Notebook endpoint | `string` | `""` | no |
| <a name="input_sagemaker_notebook_endpoint_security_group_ids"></a> [sagemaker\_notebook\_endpoint\_security\_group\_ids](#input\_sagemaker\_notebook\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Sagemaker Notebook endpoint | `list(string)` | `[]` | no |
| <a name="input_sagemaker_notebook_endpoint_subnet_ids"></a> [sagemaker\_notebook\_endpoint\_subnet\_ids](#input\_sagemaker\_notebook\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Sagemaker Notebook endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_sagemaker_runtime_endpoint_policy"></a> [sagemaker\_runtime\_endpoint\_policy](#input\_sagemaker\_runtime\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_sagemaker_runtime_endpoint_private_dns_enabled"></a> [sagemaker\_runtime\_endpoint\_private\_dns\_enabled](#input\_sagemaker\_runtime\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for SageMaker Runtime endpoint | `bool` | `false` | no |
| <a name="input_sagemaker_runtime_endpoint_security_group_ids"></a> [sagemaker\_runtime\_endpoint\_security\_group\_ids](#input\_sagemaker\_runtime\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for SageMaker Runtime endpoint | `list(string)` | `[]` | no |
| <a name="input_sagemaker_runtime_endpoint_subnet_ids"></a> [sagemaker\_runtime\_endpoint\_subnet\_ids](#input\_sagemaker\_runtime\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for SageMaker Runtime endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_secondary_cidr_blocks"></a> [secondary\_cidr\_blocks](#input\_secondary\_cidr\_blocks) | List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool | `list(string)` | `[]` | no |
| <a name="input_secretsmanager_endpoint_policy"></a> [secretsmanager\_endpoint\_policy](#input\_secretsmanager\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_secretsmanager_endpoint_private_dns_enabled"></a> [secretsmanager\_endpoint\_private\_dns\_enabled](#input\_secretsmanager\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Secrets Manager endpoint | `bool` | `false` | no |
| <a name="input_secretsmanager_endpoint_security_group_ids"></a> [secretsmanager\_endpoint\_security\_group\_ids](#input\_secretsmanager\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Secrets Manager endpoint | `list(string)` | `[]` | no |
| <a name="input_secretsmanager_endpoint_subnet_ids"></a> [secretsmanager\_endpoint\_subnet\_ids](#input\_secretsmanager\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Secrets Manager endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_servicecatalog_endpoint_private_dns_enabled"></a> [servicecatalog\_endpoint\_private\_dns\_enabled](#input\_servicecatalog\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Service Catalog endpoint | `bool` | `false` | no |
| <a name="input_servicecatalog_endpoint_security_group_ids"></a> [servicecatalog\_endpoint\_security\_group\_ids](#input\_servicecatalog\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Service Catalog endpoint | `list(string)` | `[]` | no |
| <a name="input_servicecatalog_endpoint_subnet_ids"></a> [servicecatalog\_endpoint\_subnet\_ids](#input\_servicecatalog\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Service Catalog endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ses_endpoint_private_dns_enabled"></a> [ses\_endpoint\_private\_dns\_enabled](#input\_ses\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for SES endpoint | `bool` | `false` | no |
| <a name="input_ses_endpoint_security_group_ids"></a> [ses\_endpoint\_security\_group\_ids](#input\_ses\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for SES endpoint | `list(string)` | `[]` | no |
| <a name="input_ses_endpoint_subnet_ids"></a> [ses\_endpoint\_subnet\_ids](#input\_ses\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for SES endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `false` | no |
| <a name="input_sms_endpoint_private_dns_enabled"></a> [sms\_endpoint\_private\_dns\_enabled](#input\_sms\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for SMS endpoint | `bool` | `false` | no |
| <a name="input_sms_endpoint_security_group_ids"></a> [sms\_endpoint\_security\_group\_ids](#input\_sms\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for SMS endpoint | `list(string)` | `[]` | no |
| <a name="input_sms_endpoint_subnet_ids"></a> [sms\_endpoint\_subnet\_ids](#input\_sms\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for SMS endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_sns_endpoint_policy"></a> [sns\_endpoint\_policy](#input\_sns\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_sns_endpoint_private_dns_enabled"></a> [sns\_endpoint\_private\_dns\_enabled](#input\_sns\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for SNS endpoint | `bool` | `false` | no |
| <a name="input_sns_endpoint_security_group_ids"></a> [sns\_endpoint\_security\_group\_ids](#input\_sns\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for SNS endpoint | `list(string)` | `[]` | no |
| <a name="input_sns_endpoint_subnet_ids"></a> [sns\_endpoint\_subnet\_ids](#input\_sns\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for SNS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_sqs_endpoint_policy"></a> [sqs\_endpoint\_policy](#input\_sqs\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_sqs_endpoint_private_dns_enabled"></a> [sqs\_endpoint\_private\_dns\_enabled](#input\_sqs\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for SQS endpoint | `bool` | `false` | no |
| <a name="input_sqs_endpoint_security_group_ids"></a> [sqs\_endpoint\_security\_group\_ids](#input\_sqs\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for SQS endpoint | `list(string)` | `[]` | no |
| <a name="input_sqs_endpoint_subnet_ids"></a> [sqs\_endpoint\_subnet\_ids](#input\_sqs\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for SQS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ssm_endpoint_private_dns_enabled"></a> [ssm\_endpoint\_private\_dns\_enabled](#input\_ssm\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for SSM endpoint | `bool` | `false` | no |
| <a name="input_ssm_endpoint_security_group_ids"></a> [ssm\_endpoint\_security\_group\_ids](#input\_ssm\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for SSM endpoint | `list(string)` | `[]` | no |
| <a name="input_ssm_endpoint_subnet_ids"></a> [ssm\_endpoint\_subnet\_ids](#input\_ssm\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for SSM endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_ssmmessages_endpoint_private_dns_enabled"></a> [ssmmessages\_endpoint\_private\_dns\_enabled](#input\_ssmmessages\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for SSMMESSAGES endpoint | `bool` | `false` | no |
| <a name="input_ssmmessages_endpoint_security_group_ids"></a> [ssmmessages\_endpoint\_security\_group\_ids](#input\_ssmmessages\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for SSMMESSAGES endpoint | `list(string)` | `[]` | no |
| <a name="input_ssmmessages_endpoint_subnet_ids"></a> [ssmmessages\_endpoint\_subnet\_ids](#input\_ssmmessages\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for SSMMESSAGES endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_states_endpoint_policy"></a> [states\_endpoint\_policy](#input\_states\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_states_endpoint_private_dns_enabled"></a> [states\_endpoint\_private\_dns\_enabled](#input\_states\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Step Function endpoint | `bool` | `false` | no |
| <a name="input_states_endpoint_security_group_ids"></a> [states\_endpoint\_security\_group\_ids](#input\_states\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Step Function endpoint | `list(string)` | `[]` | no |
| <a name="input_states_endpoint_subnet_ids"></a> [states\_endpoint\_subnet\_ids](#input\_states\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Step Function endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_storagegateway_endpoint_private_dns_enabled"></a> [storagegateway\_endpoint\_private\_dns\_enabled](#input\_storagegateway\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Storage Gateway endpoint | `bool` | `false` | no |
| <a name="input_storagegateway_endpoint_security_group_ids"></a> [storagegateway\_endpoint\_security\_group\_ids](#input\_storagegateway\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Storage Gateway endpoint | `list(string)` | `[]` | no |
| <a name="input_storagegateway_endpoint_subnet_ids"></a> [storagegateway\_endpoint\_subnet\_ids](#input\_storagegateway\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Storage Gateway endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_sts_endpoint_policy"></a> [sts\_endpoint\_policy](#input\_sts\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_sts_endpoint_private_dns_enabled"></a> [sts\_endpoint\_private\_dns\_enabled](#input\_sts\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for STS endpoint | `bool` | `false` | no |
| <a name="input_sts_endpoint_security_group_ids"></a> [sts\_endpoint\_security\_group\_ids](#input\_sts\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for STS endpoint | `list(string)` | `[]` | no |
| <a name="input_sts_endpoint_subnet_ids"></a> [sts\_endpoint\_subnet\_ids](#input\_sts\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for STS endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_textract_endpoint_private_dns_enabled"></a> [textract\_endpoint\_private\_dns\_enabled](#input\_textract\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Textract endpoint | `bool` | `false` | no |
| <a name="input_textract_endpoint_security_group_ids"></a> [textract\_endpoint\_security\_group\_ids](#input\_textract\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Textract endpoint | `list(string)` | `[]` | no |
| <a name="input_textract_endpoint_subnet_ids"></a> [textract\_endpoint\_subnet\_ids](#input\_textract\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Textract endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_transfer_endpoint_private_dns_enabled"></a> [transfer\_endpoint\_private\_dns\_enabled](#input\_transfer\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Transfer endpoint | `bool` | `false` | no |
| <a name="input_transfer_endpoint_security_group_ids"></a> [transfer\_endpoint\_security\_group\_ids](#input\_transfer\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Transfer endpoint | `list(string)` | `[]` | no |
| <a name="input_transfer_endpoint_subnet_ids"></a> [transfer\_endpoint\_subnet\_ids](#input\_transfer\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Transfer endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_transferserver_endpoint_private_dns_enabled"></a> [transferserver\_endpoint\_private\_dns\_enabled](#input\_transferserver\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Transfer Server endpoint | `bool` | `false` | no |
| <a name="input_transferserver_endpoint_security_group_ids"></a> [transferserver\_endpoint\_security\_group\_ids](#input\_transferserver\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Transfer Server endpoint | `list(string)` | `[]` | no |
| <a name="input_transferserver_endpoint_subnet_ids"></a> [transferserver\_endpoint\_subnet\_ids](#input\_transferserver\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Transfer Server endpoint. Only a single subnet within an AZ is supported. If omitted, private subnets will be used. | `list(string)` | `[]` | no |
| <a name="input_vpc_endpoint_tags"></a> [vpc\_endpoint\_tags](#input\_vpc\_endpoint\_tags) | Additional tags for the VPC Endpoints | `map(string)` | `{}` | no |
| <a name="input_vpc_flow_log_permissions_boundary"></a> [vpc\_flow\_log\_permissions\_boundary](#input\_vpc\_flow\_log\_permissions\_boundary) | The ARN of the Permissions Boundary for the VPC Flow Log IAM Role | `string` | `null` | no |
| <a name="input_vpc_flow_log_tags"></a> [vpc\_flow\_log\_tags](#input\_vpc\_flow\_log\_tags) | Additional tags for the VPC Flow Logs | `map(string)` | `{}` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | Additional tags for the VPC | `map(string)` | `{}` | no |
| <a name="input_vpn_gateway_az"></a> [vpn\_gateway\_az](#input\_vpn\_gateway\_az) | The Availability Zone for the VPN Gateway | `string` | `null` | no |
| <a name="input_vpn_gateway_id"></a> [vpn\_gateway\_id](#input\_vpn\_gateway\_id) | ID of VPN Gateway to attach to the VPC | `string` | `""` | no |
| <a name="input_vpn_gateway_tags"></a> [vpn\_gateway\_tags](#input\_vpn\_gateway\_tags) | Additional tags for the VPN gateway | `map(string)` | `{}` | no |
| <a name="input_workspaces_endpoint_policy"></a> [workspaces\_endpoint\_policy](#input\_workspaces\_endpoint\_policy) | A policy to attach to the endpoint that controls access to the service. Defaults to full access | `string` | `null` | no |
| <a name="input_workspaces_endpoint_private_dns_enabled"></a> [workspaces\_endpoint\_private\_dns\_enabled](#input\_workspaces\_endpoint\_private\_dns\_enabled) | Whether or not to associate a private hosted zone with the specified VPC for Workspaces endpoint | `bool` | `false` | no |
| <a name="input_workspaces_endpoint_security_group_ids"></a> [workspaces\_endpoint\_security\_group\_ids](#input\_workspaces\_endpoint\_security\_group\_ids) | The ID of one or more security groups to associate with the network interface for Workspaces endpoint | `list(string)` | `[]` | no |
| <a name="input_workspaces_endpoint_subnet_ids"></a> [workspaces\_endpoint\_subnet\_ids](#input\_workspaces\_endpoint\_subnet\_ids) | The ID of one or more subnets in which to create a network interface for Workspaces endpoint. Only a single subnet within an AZ is supported. Ifomitted, private subnets will be used. | `list(string)` | `[]` | no |

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
| <a name="output_outpost_network_acl_arn"></a> [outpost\_network\_acl\_arn](#output\_outpost\_network\_acl\_arn) | ARN of the outpost network ACL |
| <a name="output_outpost_network_acl_id"></a> [outpost\_network\_acl\_id](#output\_outpost\_network\_acl\_id) | ID of the outpost network ACL |
| <a name="output_outpost_subnet_arns"></a> [outpost\_subnet\_arns](#output\_outpost\_subnet\_arns) | List of ARNs of outpost subnets |
| <a name="output_outpost_subnets"></a> [outpost\_subnets](#output\_outpost\_subnets) | List of IDs of outpost subnets |
| <a name="output_outpost_subnets_cidr_blocks"></a> [outpost\_subnets\_cidr\_blocks](#output\_outpost\_subnets\_cidr\_blocks) | List of cidr\_blocks of outpost subnets |
| <a name="output_outpost_subnets_ipv6_cidr_blocks"></a> [outpost\_subnets\_ipv6\_cidr\_blocks](#output\_outpost\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of outpost subnets in an IPv6 enabled VPC |
| <a name="output_private_ipv6_egress_route_ids"></a> [private\_ipv6\_egress\_route\_ids](#output\_private\_ipv6\_egress\_route\_ids) | List of IDs of the ipv6 egress route. |
| <a name="output_private_nat_gateway_route_ids"></a> [private\_nat\_gateway\_route\_ids](#output\_private\_nat\_gateway\_route\_ids) | List of IDs of the private nat gateway route. |
| <a name="output_private_network_acl_arn"></a> [private\_network\_acl\_arn](#output\_private\_network\_acl\_arn) | ARN of the private network ACL |
| <a name="output_private_network_acl_id"></a> [private\_network\_acl\_id](#output\_private\_network\_acl\_id) | ID of the private network ACL |
| <a name="output_private_route_table_association_ids"></a> [private\_route\_table\_association\_ids](#output\_private\_route\_table\_association\_ids) | List of IDs of the private route table association |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | List of IDs of private route tables |
| <a name="output_private_subnet_arns"></a> [private\_subnet\_arns](#output\_private\_subnet\_arns) | List of ARNs of private subnets |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of IDs of private subnets |
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
| <a name="output_vpc_endpoint_access_analyzer_dns_entry"></a> [vpc\_endpoint\_access\_analyzer\_dns\_entry](#output\_vpc\_endpoint\_access\_analyzer\_dns\_entry) | The DNS entries for the VPC Endpoint for Access Analyzer. |
| <a name="output_vpc_endpoint_access_analyzer_id"></a> [vpc\_endpoint\_access\_analyzer\_id](#output\_vpc\_endpoint\_access\_analyzer\_id) | The ID of VPC endpoint for Access Analyzer |
| <a name="output_vpc_endpoint_access_analyzer_network_interface_ids"></a> [vpc\_endpoint\_access\_analyzer\_network\_interface\_ids](#output\_vpc\_endpoint\_access\_analyzer\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Access Analyzer. |
| <a name="output_vpc_endpoint_acm_pca_dns_entry"></a> [vpc\_endpoint\_acm\_pca\_dns\_entry](#output\_vpc\_endpoint\_acm\_pca\_dns\_entry) | The DNS entries for the VPC Endpoint for ACM PCA. |
| <a name="output_vpc_endpoint_acm_pca_id"></a> [vpc\_endpoint\_acm\_pca\_id](#output\_vpc\_endpoint\_acm\_pca\_id) | The ID of VPC endpoint for ACM PCA |
| <a name="output_vpc_endpoint_acm_pca_network_interface_ids"></a> [vpc\_endpoint\_acm\_pca\_network\_interface\_ids](#output\_vpc\_endpoint\_acm\_pca\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for ACM PCA. |
| <a name="output_vpc_endpoint_apigw_dns_entry"></a> [vpc\_endpoint\_apigw\_dns\_entry](#output\_vpc\_endpoint\_apigw\_dns\_entry) | The DNS entries for the VPC Endpoint for APIGW. |
| <a name="output_vpc_endpoint_apigw_id"></a> [vpc\_endpoint\_apigw\_id](#output\_vpc\_endpoint\_apigw\_id) | The ID of VPC endpoint for APIGW |
| <a name="output_vpc_endpoint_apigw_network_interface_ids"></a> [vpc\_endpoint\_apigw\_network\_interface\_ids](#output\_vpc\_endpoint\_apigw\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for APIGW. |
| <a name="output_vpc_endpoint_appmesh_envoy_management_dns_entry"></a> [vpc\_endpoint\_appmesh\_envoy\_management\_dns\_entry](#output\_vpc\_endpoint\_appmesh\_envoy\_management\_dns\_entry) | The DNS entries for the VPC Endpoint for AppMesh. |
| <a name="output_vpc_endpoint_appmesh_envoy_management_id"></a> [vpc\_endpoint\_appmesh\_envoy\_management\_id](#output\_vpc\_endpoint\_appmesh\_envoy\_management\_id) | The ID of VPC endpoint for AppMesh |
| <a name="output_vpc_endpoint_appmesh_envoy_management_network_interface_ids"></a> [vpc\_endpoint\_appmesh\_envoy\_management\_network\_interface\_ids](#output\_vpc\_endpoint\_appmesh\_envoy\_management\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for AppMesh. |
| <a name="output_vpc_endpoint_appstream_api_dns_entry"></a> [vpc\_endpoint\_appstream\_api\_dns\_entry](#output\_vpc\_endpoint\_appstream\_api\_dns\_entry) | The DNS entries for the VPC Endpoint for AppStream API. |
| <a name="output_vpc_endpoint_appstream_api_id"></a> [vpc\_endpoint\_appstream\_api\_id](#output\_vpc\_endpoint\_appstream\_api\_id) | The ID of VPC endpoint for AppStream API |
| <a name="output_vpc_endpoint_appstream_api_network_interface_ids"></a> [vpc\_endpoint\_appstream\_api\_network\_interface\_ids](#output\_vpc\_endpoint\_appstream\_api\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for AppStream API. |
| <a name="output_vpc_endpoint_appstream_streaming_dns_entry"></a> [vpc\_endpoint\_appstream\_streaming\_dns\_entry](#output\_vpc\_endpoint\_appstream\_streaming\_dns\_entry) | The DNS entries for the VPC Endpoint for AppStream Streaming. |
| <a name="output_vpc_endpoint_appstream_streaming_id"></a> [vpc\_endpoint\_appstream\_streaming\_id](#output\_vpc\_endpoint\_appstream\_streaming\_id) | The ID of VPC endpoint for AppStream Streaming |
| <a name="output_vpc_endpoint_appstream_streaming_network_interface_ids"></a> [vpc\_endpoint\_appstream\_streaming\_network\_interface\_ids](#output\_vpc\_endpoint\_appstream\_streaming\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for AppStream Streaming. |
| <a name="output_vpc_endpoint_athena_dns_entry"></a> [vpc\_endpoint\_athena\_dns\_entry](#output\_vpc\_endpoint\_athena\_dns\_entry) | The DNS entries for the VPC Endpoint for Athena. |
| <a name="output_vpc_endpoint_athena_id"></a> [vpc\_endpoint\_athena\_id](#output\_vpc\_endpoint\_athena\_id) | The ID of VPC endpoint for Athena |
| <a name="output_vpc_endpoint_athena_network_interface_ids"></a> [vpc\_endpoint\_athena\_network\_interface\_ids](#output\_vpc\_endpoint\_athena\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Athena. |
| <a name="output_vpc_endpoint_auto_scaling_plans_dns_entry"></a> [vpc\_endpoint\_auto\_scaling\_plans\_dns\_entry](#output\_vpc\_endpoint\_auto\_scaling\_plans\_dns\_entry) | The DNS entries for the VPC Endpoint for Auto Scaling Plans. |
| <a name="output_vpc_endpoint_auto_scaling_plans_id"></a> [vpc\_endpoint\_auto\_scaling\_plans\_id](#output\_vpc\_endpoint\_auto\_scaling\_plans\_id) | The ID of VPC endpoint for Auto Scaling Plans |
| <a name="output_vpc_endpoint_auto_scaling_plans_network_interface_ids"></a> [vpc\_endpoint\_auto\_scaling\_plans\_network\_interface\_ids](#output\_vpc\_endpoint\_auto\_scaling\_plans\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Auto Scaling Plans. |
| <a name="output_vpc_endpoint_cloud_directory_dns_entry"></a> [vpc\_endpoint\_cloud\_directory\_dns\_entry](#output\_vpc\_endpoint\_cloud\_directory\_dns\_entry) | The DNS entries for the VPC Endpoint for Cloud Directory. |
| <a name="output_vpc_endpoint_cloud_directory_id"></a> [vpc\_endpoint\_cloud\_directory\_id](#output\_vpc\_endpoint\_cloud\_directory\_id) | The ID of VPC endpoint for Cloud Directory |
| <a name="output_vpc_endpoint_cloud_directory_network_interface_ids"></a> [vpc\_endpoint\_cloud\_directory\_network\_interface\_ids](#output\_vpc\_endpoint\_cloud\_directory\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Cloud Directory. |
| <a name="output_vpc_endpoint_cloudformation_dns_entry"></a> [vpc\_endpoint\_cloudformation\_dns\_entry](#output\_vpc\_endpoint\_cloudformation\_dns\_entry) | The DNS entries for the VPC Endpoint for Cloudformation. |
| <a name="output_vpc_endpoint_cloudformation_id"></a> [vpc\_endpoint\_cloudformation\_id](#output\_vpc\_endpoint\_cloudformation\_id) | The ID of VPC endpoint for Cloudformation |
| <a name="output_vpc_endpoint_cloudformation_network_interface_ids"></a> [vpc\_endpoint\_cloudformation\_network\_interface\_ids](#output\_vpc\_endpoint\_cloudformation\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Cloudformation. |
| <a name="output_vpc_endpoint_cloudtrail_dns_entry"></a> [vpc\_endpoint\_cloudtrail\_dns\_entry](#output\_vpc\_endpoint\_cloudtrail\_dns\_entry) | The DNS entries for the VPC Endpoint for CloudTrail. |
| <a name="output_vpc_endpoint_cloudtrail_id"></a> [vpc\_endpoint\_cloudtrail\_id](#output\_vpc\_endpoint\_cloudtrail\_id) | The ID of VPC endpoint for CloudTrail |
| <a name="output_vpc_endpoint_cloudtrail_network_interface_ids"></a> [vpc\_endpoint\_cloudtrail\_network\_interface\_ids](#output\_vpc\_endpoint\_cloudtrail\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for CloudTrail. |
| <a name="output_vpc_endpoint_codeartifact_api_dns_entry"></a> [vpc\_endpoint\_codeartifact\_api\_dns\_entry](#output\_vpc\_endpoint\_codeartifact\_api\_dns\_entry) | The DNS entries for the VPC Endpoint for Codeartifact API. |
| <a name="output_vpc_endpoint_codeartifact_api_id"></a> [vpc\_endpoint\_codeartifact\_api\_id](#output\_vpc\_endpoint\_codeartifact\_api\_id) | The ID of VPC endpoint for Codeartifact API |
| <a name="output_vpc_endpoint_codeartifact_api_network_interface_ids"></a> [vpc\_endpoint\_codeartifact\_api\_network\_interface\_ids](#output\_vpc\_endpoint\_codeartifact\_api\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Codeartifact API. |
| <a name="output_vpc_endpoint_codeartifact_repositories_dns_entry"></a> [vpc\_endpoint\_codeartifact\_repositories\_dns\_entry](#output\_vpc\_endpoint\_codeartifact\_repositories\_dns\_entry) | The DNS entries for the VPC Endpoint for Codeartifact repositories. |
| <a name="output_vpc_endpoint_codeartifact_repositories_id"></a> [vpc\_endpoint\_codeartifact\_repositories\_id](#output\_vpc\_endpoint\_codeartifact\_repositories\_id) | The ID of VPC endpoint for Codeartifact repositories |
| <a name="output_vpc_endpoint_codeartifact_repositories_network_interface_ids"></a> [vpc\_endpoint\_codeartifact\_repositories\_network\_interface\_ids](#output\_vpc\_endpoint\_codeartifact\_repositories\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Codeartifact repositories. |
| <a name="output_vpc_endpoint_codebuild_dns_entry"></a> [vpc\_endpoint\_codebuild\_dns\_entry](#output\_vpc\_endpoint\_codebuild\_dns\_entry) | The DNS entries for the VPC Endpoint for codebuild. |
| <a name="output_vpc_endpoint_codebuild_id"></a> [vpc\_endpoint\_codebuild\_id](#output\_vpc\_endpoint\_codebuild\_id) | The ID of VPC endpoint for codebuild |
| <a name="output_vpc_endpoint_codebuild_network_interface_ids"></a> [vpc\_endpoint\_codebuild\_network\_interface\_ids](#output\_vpc\_endpoint\_codebuild\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for codebuild. |
| <a name="output_vpc_endpoint_codecommit_dns_entry"></a> [vpc\_endpoint\_codecommit\_dns\_entry](#output\_vpc\_endpoint\_codecommit\_dns\_entry) | The DNS entries for the VPC Endpoint for codecommit. |
| <a name="output_vpc_endpoint_codecommit_id"></a> [vpc\_endpoint\_codecommit\_id](#output\_vpc\_endpoint\_codecommit\_id) | The ID of VPC endpoint for codecommit |
| <a name="output_vpc_endpoint_codecommit_network_interface_ids"></a> [vpc\_endpoint\_codecommit\_network\_interface\_ids](#output\_vpc\_endpoint\_codecommit\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for codecommit. |
| <a name="output_vpc_endpoint_codepipeline_dns_entry"></a> [vpc\_endpoint\_codepipeline\_dns\_entry](#output\_vpc\_endpoint\_codepipeline\_dns\_entry) | The DNS entries for the VPC Endpoint for CodePipeline. |
| <a name="output_vpc_endpoint_codepipeline_id"></a> [vpc\_endpoint\_codepipeline\_id](#output\_vpc\_endpoint\_codepipeline\_id) | The ID of VPC endpoint for CodePipeline |
| <a name="output_vpc_endpoint_codepipeline_network_interface_ids"></a> [vpc\_endpoint\_codepipeline\_network\_interface\_ids](#output\_vpc\_endpoint\_codepipeline\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for CodePipeline. |
| <a name="output_vpc_endpoint_config_dns_entry"></a> [vpc\_endpoint\_config\_dns\_entry](#output\_vpc\_endpoint\_config\_dns\_entry) | The DNS entries for the VPC Endpoint for config. |
| <a name="output_vpc_endpoint_config_id"></a> [vpc\_endpoint\_config\_id](#output\_vpc\_endpoint\_config\_id) | The ID of VPC endpoint for config |
| <a name="output_vpc_endpoint_config_network_interface_ids"></a> [vpc\_endpoint\_config\_network\_interface\_ids](#output\_vpc\_endpoint\_config\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for config. |
| <a name="output_vpc_endpoint_datasync_dns_entry"></a> [vpc\_endpoint\_datasync\_dns\_entry](#output\_vpc\_endpoint\_datasync\_dns\_entry) | The DNS entries for the VPC Endpoint for DataSync. |
| <a name="output_vpc_endpoint_datasync_id"></a> [vpc\_endpoint\_datasync\_id](#output\_vpc\_endpoint\_datasync\_id) | The ID of VPC endpoint for DataSync |
| <a name="output_vpc_endpoint_datasync_network_interface_ids"></a> [vpc\_endpoint\_datasync\_network\_interface\_ids](#output\_vpc\_endpoint\_datasync\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for DataSync. |
| <a name="output_vpc_endpoint_dms_dns_entry"></a> [vpc\_endpoint\_dms\_dns\_entry](#output\_vpc\_endpoint\_dms\_dns\_entry) | The DNS entries for the VPC Endpoint for DMS. |
| <a name="output_vpc_endpoint_dms_id"></a> [vpc\_endpoint\_dms\_id](#output\_vpc\_endpoint\_dms\_id) | The ID of VPC endpoint for DMS |
| <a name="output_vpc_endpoint_dms_network_interface_ids"></a> [vpc\_endpoint\_dms\_network\_interface\_ids](#output\_vpc\_endpoint\_dms\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for DMS. |
| <a name="output_vpc_endpoint_dynamodb_id"></a> [vpc\_endpoint\_dynamodb\_id](#output\_vpc\_endpoint\_dynamodb\_id) | The ID of VPC endpoint for DynamoDB |
| <a name="output_vpc_endpoint_dynamodb_pl_id"></a> [vpc\_endpoint\_dynamodb\_pl\_id](#output\_vpc\_endpoint\_dynamodb\_pl\_id) | The prefix list for the DynamoDB VPC endpoint. |
| <a name="output_vpc_endpoint_ebs_dns_entry"></a> [vpc\_endpoint\_ebs\_dns\_entry](#output\_vpc\_endpoint\_ebs\_dns\_entry) | The DNS entries for the VPC Endpoint for EBS. |
| <a name="output_vpc_endpoint_ebs_id"></a> [vpc\_endpoint\_ebs\_id](#output\_vpc\_endpoint\_ebs\_id) | The ID of VPC endpoint for EBS |
| <a name="output_vpc_endpoint_ebs_network_interface_ids"></a> [vpc\_endpoint\_ebs\_network\_interface\_ids](#output\_vpc\_endpoint\_ebs\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for EBS. |
| <a name="output_vpc_endpoint_ec2_autoscaling_dns_entry"></a> [vpc\_endpoint\_ec2\_autoscaling\_dns\_entry](#output\_vpc\_endpoint\_ec2\_autoscaling\_dns\_entry) | The DNS entries for the VPC Endpoint for EC2 Autoscaling. |
| <a name="output_vpc_endpoint_ec2_autoscaling_id"></a> [vpc\_endpoint\_ec2\_autoscaling\_id](#output\_vpc\_endpoint\_ec2\_autoscaling\_id) | The ID of VPC endpoint for EC2 Autoscaling |
| <a name="output_vpc_endpoint_ec2_autoscaling_network_interface_ids"></a> [vpc\_endpoint\_ec2\_autoscaling\_network\_interface\_ids](#output\_vpc\_endpoint\_ec2\_autoscaling\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for EC2 Autoscaling |
| <a name="output_vpc_endpoint_ec2_dns_entry"></a> [vpc\_endpoint\_ec2\_dns\_entry](#output\_vpc\_endpoint\_ec2\_dns\_entry) | The DNS entries for the VPC Endpoint for EC2. |
| <a name="output_vpc_endpoint_ec2_id"></a> [vpc\_endpoint\_ec2\_id](#output\_vpc\_endpoint\_ec2\_id) | The ID of VPC endpoint for EC2 |
| <a name="output_vpc_endpoint_ec2_network_interface_ids"></a> [vpc\_endpoint\_ec2\_network\_interface\_ids](#output\_vpc\_endpoint\_ec2\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for EC2 |
| <a name="output_vpc_endpoint_ec2messages_dns_entry"></a> [vpc\_endpoint\_ec2messages\_dns\_entry](#output\_vpc\_endpoint\_ec2messages\_dns\_entry) | The DNS entries for the VPC Endpoint for EC2MESSAGES. |
| <a name="output_vpc_endpoint_ec2messages_id"></a> [vpc\_endpoint\_ec2messages\_id](#output\_vpc\_endpoint\_ec2messages\_id) | The ID of VPC endpoint for EC2MESSAGES |
| <a name="output_vpc_endpoint_ec2messages_network_interface_ids"></a> [vpc\_endpoint\_ec2messages\_network\_interface\_ids](#output\_vpc\_endpoint\_ec2messages\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for EC2MESSAGES |
| <a name="output_vpc_endpoint_ecr_api_dns_entry"></a> [vpc\_endpoint\_ecr\_api\_dns\_entry](#output\_vpc\_endpoint\_ecr\_api\_dns\_entry) | The DNS entries for the VPC Endpoint for ECR API. |
| <a name="output_vpc_endpoint_ecr_api_id"></a> [vpc\_endpoint\_ecr\_api\_id](#output\_vpc\_endpoint\_ecr\_api\_id) | The ID of VPC endpoint for ECR API |
| <a name="output_vpc_endpoint_ecr_api_network_interface_ids"></a> [vpc\_endpoint\_ecr\_api\_network\_interface\_ids](#output\_vpc\_endpoint\_ecr\_api\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for ECR API. |
| <a name="output_vpc_endpoint_ecr_dkr_dns_entry"></a> [vpc\_endpoint\_ecr\_dkr\_dns\_entry](#output\_vpc\_endpoint\_ecr\_dkr\_dns\_entry) | The DNS entries for the VPC Endpoint for ECR DKR. |
| <a name="output_vpc_endpoint_ecr_dkr_id"></a> [vpc\_endpoint\_ecr\_dkr\_id](#output\_vpc\_endpoint\_ecr\_dkr\_id) | The ID of VPC endpoint for ECR DKR |
| <a name="output_vpc_endpoint_ecr_dkr_network_interface_ids"></a> [vpc\_endpoint\_ecr\_dkr\_network\_interface\_ids](#output\_vpc\_endpoint\_ecr\_dkr\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for ECR DKR. |
| <a name="output_vpc_endpoint_ecs_agent_dns_entry"></a> [vpc\_endpoint\_ecs\_agent\_dns\_entry](#output\_vpc\_endpoint\_ecs\_agent\_dns\_entry) | The DNS entries for the VPC Endpoint for ECS Agent. |
| <a name="output_vpc_endpoint_ecs_agent_id"></a> [vpc\_endpoint\_ecs\_agent\_id](#output\_vpc\_endpoint\_ecs\_agent\_id) | The ID of VPC endpoint for ECS Agent |
| <a name="output_vpc_endpoint_ecs_agent_network_interface_ids"></a> [vpc\_endpoint\_ecs\_agent\_network\_interface\_ids](#output\_vpc\_endpoint\_ecs\_agent\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for ECS Agent. |
| <a name="output_vpc_endpoint_ecs_dns_entry"></a> [vpc\_endpoint\_ecs\_dns\_entry](#output\_vpc\_endpoint\_ecs\_dns\_entry) | The DNS entries for the VPC Endpoint for ECS. |
| <a name="output_vpc_endpoint_ecs_id"></a> [vpc\_endpoint\_ecs\_id](#output\_vpc\_endpoint\_ecs\_id) | The ID of VPC endpoint for ECS |
| <a name="output_vpc_endpoint_ecs_network_interface_ids"></a> [vpc\_endpoint\_ecs\_network\_interface\_ids](#output\_vpc\_endpoint\_ecs\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for ECS. |
| <a name="output_vpc_endpoint_ecs_telemetry_dns_entry"></a> [vpc\_endpoint\_ecs\_telemetry\_dns\_entry](#output\_vpc\_endpoint\_ecs\_telemetry\_dns\_entry) | The DNS entries for the VPC Endpoint for ECS Telemetry. |
| <a name="output_vpc_endpoint_ecs_telemetry_id"></a> [vpc\_endpoint\_ecs\_telemetry\_id](#output\_vpc\_endpoint\_ecs\_telemetry\_id) | The ID of VPC endpoint for ECS Telemetry |
| <a name="output_vpc_endpoint_ecs_telemetry_network_interface_ids"></a> [vpc\_endpoint\_ecs\_telemetry\_network\_interface\_ids](#output\_vpc\_endpoint\_ecs\_telemetry\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for ECS Telemetry. |
| <a name="output_vpc_endpoint_efs_dns_entry"></a> [vpc\_endpoint\_efs\_dns\_entry](#output\_vpc\_endpoint\_efs\_dns\_entry) | The DNS entries for the VPC Endpoint for EFS. |
| <a name="output_vpc_endpoint_efs_id"></a> [vpc\_endpoint\_efs\_id](#output\_vpc\_endpoint\_efs\_id) | The ID of VPC endpoint for EFS |
| <a name="output_vpc_endpoint_efs_network_interface_ids"></a> [vpc\_endpoint\_efs\_network\_interface\_ids](#output\_vpc\_endpoint\_efs\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for EFS. |
| <a name="output_vpc_endpoint_elastic_inference_runtime_dns_entry"></a> [vpc\_endpoint\_elastic\_inference\_runtime\_dns\_entry](#output\_vpc\_endpoint\_elastic\_inference\_runtime\_dns\_entry) | The DNS entries for the VPC Endpoint for Elastic Inference Runtime. |
| <a name="output_vpc_endpoint_elastic_inference_runtime_id"></a> [vpc\_endpoint\_elastic\_inference\_runtime\_id](#output\_vpc\_endpoint\_elastic\_inference\_runtime\_id) | The ID of VPC endpoint for Elastic Inference Runtime |
| <a name="output_vpc_endpoint_elastic_inference_runtime_network_interface_ids"></a> [vpc\_endpoint\_elastic\_inference\_runtime\_network\_interface\_ids](#output\_vpc\_endpoint\_elastic\_inference\_runtime\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Elastic Inference Runtime. |
| <a name="output_vpc_endpoint_elasticbeanstalk_dns_entry"></a> [vpc\_endpoint\_elasticbeanstalk\_dns\_entry](#output\_vpc\_endpoint\_elasticbeanstalk\_dns\_entry) | The DNS entries for the VPC Endpoint for Elastic Beanstalk. |
| <a name="output_vpc_endpoint_elasticbeanstalk_health_dns_entry"></a> [vpc\_endpoint\_elasticbeanstalk\_health\_dns\_entry](#output\_vpc\_endpoint\_elasticbeanstalk\_health\_dns\_entry) | The DNS entries for the VPC Endpoint for Elastic Beanstalk Health. |
| <a name="output_vpc_endpoint_elasticbeanstalk_health_id"></a> [vpc\_endpoint\_elasticbeanstalk\_health\_id](#output\_vpc\_endpoint\_elasticbeanstalk\_health\_id) | The ID of VPC endpoint for Elastic Beanstalk Health |
| <a name="output_vpc_endpoint_elasticbeanstalk_health_network_interface_ids"></a> [vpc\_endpoint\_elasticbeanstalk\_health\_network\_interface\_ids](#output\_vpc\_endpoint\_elasticbeanstalk\_health\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Elastic Beanstalk Health. |
| <a name="output_vpc_endpoint_elasticbeanstalk_id"></a> [vpc\_endpoint\_elasticbeanstalk\_id](#output\_vpc\_endpoint\_elasticbeanstalk\_id) | The ID of VPC endpoint for Elastic Beanstalk |
| <a name="output_vpc_endpoint_elasticbeanstalk_network_interface_ids"></a> [vpc\_endpoint\_elasticbeanstalk\_network\_interface\_ids](#output\_vpc\_endpoint\_elasticbeanstalk\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Elastic Beanstalk. |
| <a name="output_vpc_endpoint_elasticloadbalancing_dns_entry"></a> [vpc\_endpoint\_elasticloadbalancing\_dns\_entry](#output\_vpc\_endpoint\_elasticloadbalancing\_dns\_entry) | The DNS entries for the VPC Endpoint for Elastic Load Balancing. |
| <a name="output_vpc_endpoint_elasticloadbalancing_id"></a> [vpc\_endpoint\_elasticloadbalancing\_id](#output\_vpc\_endpoint\_elasticloadbalancing\_id) | The ID of VPC endpoint for Elastic Load Balancing |
| <a name="output_vpc_endpoint_elasticloadbalancing_network_interface_ids"></a> [vpc\_endpoint\_elasticloadbalancing\_network\_interface\_ids](#output\_vpc\_endpoint\_elasticloadbalancing\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Elastic Load Balancing. |
| <a name="output_vpc_endpoint_elasticmapreduce_dns_entry"></a> [vpc\_endpoint\_elasticmapreduce\_dns\_entry](#output\_vpc\_endpoint\_elasticmapreduce\_dns\_entry) | The DNS entries for the VPC Endpoint for EMR. |
| <a name="output_vpc_endpoint_elasticmapreduce_id"></a> [vpc\_endpoint\_elasticmapreduce\_id](#output\_vpc\_endpoint\_elasticmapreduce\_id) | The ID of VPC endpoint for EMR |
| <a name="output_vpc_endpoint_elasticmapreduce_network_interface_ids"></a> [vpc\_endpoint\_elasticmapreduce\_network\_interface\_ids](#output\_vpc\_endpoint\_elasticmapreduce\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for EMR. |
| <a name="output_vpc_endpoint_events_dns_entry"></a> [vpc\_endpoint\_events\_dns\_entry](#output\_vpc\_endpoint\_events\_dns\_entry) | The DNS entries for the VPC Endpoint for CloudWatch Events. |
| <a name="output_vpc_endpoint_events_id"></a> [vpc\_endpoint\_events\_id](#output\_vpc\_endpoint\_events\_id) | The ID of VPC endpoint for CloudWatch Events |
| <a name="output_vpc_endpoint_events_network_interface_ids"></a> [vpc\_endpoint\_events\_network\_interface\_ids](#output\_vpc\_endpoint\_events\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for CloudWatch Events. |
| <a name="output_vpc_endpoint_git_codecommit_dns_entry"></a> [vpc\_endpoint\_git\_codecommit\_dns\_entry](#output\_vpc\_endpoint\_git\_codecommit\_dns\_entry) | The DNS entries for the VPC Endpoint for git\_codecommit. |
| <a name="output_vpc_endpoint_git_codecommit_id"></a> [vpc\_endpoint\_git\_codecommit\_id](#output\_vpc\_endpoint\_git\_codecommit\_id) | The ID of VPC endpoint for git\_codecommit |
| <a name="output_vpc_endpoint_git_codecommit_network_interface_ids"></a> [vpc\_endpoint\_git\_codecommit\_network\_interface\_ids](#output\_vpc\_endpoint\_git\_codecommit\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for git\_codecommit. |
| <a name="output_vpc_endpoint_glue_dns_entry"></a> [vpc\_endpoint\_glue\_dns\_entry](#output\_vpc\_endpoint\_glue\_dns\_entry) | The DNS entries for the VPC Endpoint for Glue. |
| <a name="output_vpc_endpoint_glue_id"></a> [vpc\_endpoint\_glue\_id](#output\_vpc\_endpoint\_glue\_id) | The ID of VPC endpoint for Glue |
| <a name="output_vpc_endpoint_glue_network_interface_ids"></a> [vpc\_endpoint\_glue\_network\_interface\_ids](#output\_vpc\_endpoint\_glue\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Glue. |
| <a name="output_vpc_endpoint_kinesis_firehose_dns_entry"></a> [vpc\_endpoint\_kinesis\_firehose\_dns\_entry](#output\_vpc\_endpoint\_kinesis\_firehose\_dns\_entry) | The DNS entries for the VPC Endpoint for Kinesis Firehose. |
| <a name="output_vpc_endpoint_kinesis_firehose_id"></a> [vpc\_endpoint\_kinesis\_firehose\_id](#output\_vpc\_endpoint\_kinesis\_firehose\_id) | The ID of VPC endpoint for Kinesis Firehose |
| <a name="output_vpc_endpoint_kinesis_firehose_network_interface_ids"></a> [vpc\_endpoint\_kinesis\_firehose\_network\_interface\_ids](#output\_vpc\_endpoint\_kinesis\_firehose\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Kinesis Firehose. |
| <a name="output_vpc_endpoint_kinesis_streams_dns_entry"></a> [vpc\_endpoint\_kinesis\_streams\_dns\_entry](#output\_vpc\_endpoint\_kinesis\_streams\_dns\_entry) | The DNS entries for the VPC Endpoint for Kinesis Streams. |
| <a name="output_vpc_endpoint_kinesis_streams_id"></a> [vpc\_endpoint\_kinesis\_streams\_id](#output\_vpc\_endpoint\_kinesis\_streams\_id) | The ID of VPC endpoint for Kinesis Streams |
| <a name="output_vpc_endpoint_kinesis_streams_network_interface_ids"></a> [vpc\_endpoint\_kinesis\_streams\_network\_interface\_ids](#output\_vpc\_endpoint\_kinesis\_streams\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Kinesis Streams. |
| <a name="output_vpc_endpoint_kms_dns_entry"></a> [vpc\_endpoint\_kms\_dns\_entry](#output\_vpc\_endpoint\_kms\_dns\_entry) | The DNS entries for the VPC Endpoint for KMS. |
| <a name="output_vpc_endpoint_kms_id"></a> [vpc\_endpoint\_kms\_id](#output\_vpc\_endpoint\_kms\_id) | The ID of VPC endpoint for KMS |
| <a name="output_vpc_endpoint_kms_network_interface_ids"></a> [vpc\_endpoint\_kms\_network\_interface\_ids](#output\_vpc\_endpoint\_kms\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for KMS. |
| <a name="output_vpc_endpoint_lambda_dns_entry"></a> [vpc\_endpoint\_lambda\_dns\_entry](#output\_vpc\_endpoint\_lambda\_dns\_entry) | The DNS entries for the VPC Endpoint for Lambda. |
| <a name="output_vpc_endpoint_lambda_id"></a> [vpc\_endpoint\_lambda\_id](#output\_vpc\_endpoint\_lambda\_id) | The ID of VPC endpoint for Lambda |
| <a name="output_vpc_endpoint_lambda_network_interface_ids"></a> [vpc\_endpoint\_lambda\_network\_interface\_ids](#output\_vpc\_endpoint\_lambda\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Lambda. |
| <a name="output_vpc_endpoint_logs_dns_entry"></a> [vpc\_endpoint\_logs\_dns\_entry](#output\_vpc\_endpoint\_logs\_dns\_entry) | The DNS entries for the VPC Endpoint for CloudWatch Logs. |
| <a name="output_vpc_endpoint_logs_id"></a> [vpc\_endpoint\_logs\_id](#output\_vpc\_endpoint\_logs\_id) | The ID of VPC endpoint for CloudWatch Logs |
| <a name="output_vpc_endpoint_logs_network_interface_ids"></a> [vpc\_endpoint\_logs\_network\_interface\_ids](#output\_vpc\_endpoint\_logs\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for CloudWatch Logs. |
| <a name="output_vpc_endpoint_monitoring_dns_entry"></a> [vpc\_endpoint\_monitoring\_dns\_entry](#output\_vpc\_endpoint\_monitoring\_dns\_entry) | The DNS entries for the VPC Endpoint for CloudWatch Monitoring. |
| <a name="output_vpc_endpoint_monitoring_id"></a> [vpc\_endpoint\_monitoring\_id](#output\_vpc\_endpoint\_monitoring\_id) | The ID of VPC endpoint for CloudWatch Monitoring |
| <a name="output_vpc_endpoint_monitoring_network_interface_ids"></a> [vpc\_endpoint\_monitoring\_network\_interface\_ids](#output\_vpc\_endpoint\_monitoring\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for CloudWatch Monitoring. |
| <a name="output_vpc_endpoint_qldb_session_dns_entry"></a> [vpc\_endpoint\_qldb\_session\_dns\_entry](#output\_vpc\_endpoint\_qldb\_session\_dns\_entry) | The DNS entries for the VPC Endpoint for QLDB Session. |
| <a name="output_vpc_endpoint_qldb_session_id"></a> [vpc\_endpoint\_qldb\_session\_id](#output\_vpc\_endpoint\_qldb\_session\_id) | The ID of VPC endpoint for QLDB Session |
| <a name="output_vpc_endpoint_qldb_session_network_interface_ids"></a> [vpc\_endpoint\_qldb\_session\_network\_interface\_ids](#output\_vpc\_endpoint\_qldb\_session\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for QLDB Session. |
| <a name="output_vpc_endpoint_rds_dns_entry"></a> [vpc\_endpoint\_rds\_dns\_entry](#output\_vpc\_endpoint\_rds\_dns\_entry) | The DNS entries for the VPC Endpoint for RDS. |
| <a name="output_vpc_endpoint_rds_id"></a> [vpc\_endpoint\_rds\_id](#output\_vpc\_endpoint\_rds\_id) | The ID of VPC endpoint for RDS |
| <a name="output_vpc_endpoint_rds_network_interface_ids"></a> [vpc\_endpoint\_rds\_network\_interface\_ids](#output\_vpc\_endpoint\_rds\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for RDS. |
| <a name="output_vpc_endpoint_rekognition_dns_entry"></a> [vpc\_endpoint\_rekognition\_dns\_entry](#output\_vpc\_endpoint\_rekognition\_dns\_entry) | The DNS entries for the VPC Endpoint for Rekognition. |
| <a name="output_vpc_endpoint_rekognition_id"></a> [vpc\_endpoint\_rekognition\_id](#output\_vpc\_endpoint\_rekognition\_id) | The ID of VPC endpoint for Rekognition |
| <a name="output_vpc_endpoint_rekognition_network_interface_ids"></a> [vpc\_endpoint\_rekognition\_network\_interface\_ids](#output\_vpc\_endpoint\_rekognition\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Rekognition. |
| <a name="output_vpc_endpoint_s3_id"></a> [vpc\_endpoint\_s3\_id](#output\_vpc\_endpoint\_s3\_id) | The ID of VPC endpoint for S3 |
| <a name="output_vpc_endpoint_s3_pl_id"></a> [vpc\_endpoint\_s3\_pl\_id](#output\_vpc\_endpoint\_s3\_pl\_id) | The prefix list for the S3 VPC endpoint. |
| <a name="output_vpc_endpoint_sagemaker_api_dns_entry"></a> [vpc\_endpoint\_sagemaker\_api\_dns\_entry](#output\_vpc\_endpoint\_sagemaker\_api\_dns\_entry) | The DNS entries for the VPC Endpoint for SageMaker API. |
| <a name="output_vpc_endpoint_sagemaker_api_id"></a> [vpc\_endpoint\_sagemaker\_api\_id](#output\_vpc\_endpoint\_sagemaker\_api\_id) | The ID of VPC endpoint for SageMaker API |
| <a name="output_vpc_endpoint_sagemaker_api_network_interface_ids"></a> [vpc\_endpoint\_sagemaker\_api\_network\_interface\_ids](#output\_vpc\_endpoint\_sagemaker\_api\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for SageMaker API. |
| <a name="output_vpc_endpoint_sagemaker_runtime_dns_entry"></a> [vpc\_endpoint\_sagemaker\_runtime\_dns\_entry](#output\_vpc\_endpoint\_sagemaker\_runtime\_dns\_entry) | The DNS entries for the VPC Endpoint for SageMaker Runtime. |
| <a name="output_vpc_endpoint_sagemaker_runtime_id"></a> [vpc\_endpoint\_sagemaker\_runtime\_id](#output\_vpc\_endpoint\_sagemaker\_runtime\_id) | The ID of VPC endpoint for SageMaker Runtime |
| <a name="output_vpc_endpoint_sagemaker_runtime_network_interface_ids"></a> [vpc\_endpoint\_sagemaker\_runtime\_network\_interface\_ids](#output\_vpc\_endpoint\_sagemaker\_runtime\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for SageMaker Runtime. |
| <a name="output_vpc_endpoint_secretsmanager_dns_entry"></a> [vpc\_endpoint\_secretsmanager\_dns\_entry](#output\_vpc\_endpoint\_secretsmanager\_dns\_entry) | The DNS entries for the VPC Endpoint for secretsmanager. |
| <a name="output_vpc_endpoint_secretsmanager_id"></a> [vpc\_endpoint\_secretsmanager\_id](#output\_vpc\_endpoint\_secretsmanager\_id) | The ID of VPC endpoint for secretsmanager |
| <a name="output_vpc_endpoint_secretsmanager_network_interface_ids"></a> [vpc\_endpoint\_secretsmanager\_network\_interface\_ids](#output\_vpc\_endpoint\_secretsmanager\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for secretsmanager. |
| <a name="output_vpc_endpoint_servicecatalog_dns_entry"></a> [vpc\_endpoint\_servicecatalog\_dns\_entry](#output\_vpc\_endpoint\_servicecatalog\_dns\_entry) | The DNS entries for the VPC Endpoint for Service Catalog. |
| <a name="output_vpc_endpoint_servicecatalog_id"></a> [vpc\_endpoint\_servicecatalog\_id](#output\_vpc\_endpoint\_servicecatalog\_id) | The ID of VPC endpoint for Service Catalog |
| <a name="output_vpc_endpoint_servicecatalog_network_interface_ids"></a> [vpc\_endpoint\_servicecatalog\_network\_interface\_ids](#output\_vpc\_endpoint\_servicecatalog\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Service Catalog. |
| <a name="output_vpc_endpoint_ses_dns_entry"></a> [vpc\_endpoint\_ses\_dns\_entry](#output\_vpc\_endpoint\_ses\_dns\_entry) | The DNS entries for the VPC Endpoint for SES. |
| <a name="output_vpc_endpoint_ses_id"></a> [vpc\_endpoint\_ses\_id](#output\_vpc\_endpoint\_ses\_id) | The ID of VPC endpoint for SES |
| <a name="output_vpc_endpoint_ses_network_interface_ids"></a> [vpc\_endpoint\_ses\_network\_interface\_ids](#output\_vpc\_endpoint\_ses\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for SES. |
| <a name="output_vpc_endpoint_sms_dns_entry"></a> [vpc\_endpoint\_sms\_dns\_entry](#output\_vpc\_endpoint\_sms\_dns\_entry) | The DNS entries for the VPC Endpoint for SMS. |
| <a name="output_vpc_endpoint_sms_id"></a> [vpc\_endpoint\_sms\_id](#output\_vpc\_endpoint\_sms\_id) | The ID of VPC endpoint for SMS |
| <a name="output_vpc_endpoint_sms_network_interface_ids"></a> [vpc\_endpoint\_sms\_network\_interface\_ids](#output\_vpc\_endpoint\_sms\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for SMS. |
| <a name="output_vpc_endpoint_sns_dns_entry"></a> [vpc\_endpoint\_sns\_dns\_entry](#output\_vpc\_endpoint\_sns\_dns\_entry) | The DNS entries for the VPC Endpoint for SNS. |
| <a name="output_vpc_endpoint_sns_id"></a> [vpc\_endpoint\_sns\_id](#output\_vpc\_endpoint\_sns\_id) | The ID of VPC endpoint for SNS |
| <a name="output_vpc_endpoint_sns_network_interface_ids"></a> [vpc\_endpoint\_sns\_network\_interface\_ids](#output\_vpc\_endpoint\_sns\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for SNS. |
| <a name="output_vpc_endpoint_sqs_dns_entry"></a> [vpc\_endpoint\_sqs\_dns\_entry](#output\_vpc\_endpoint\_sqs\_dns\_entry) | The DNS entries for the VPC Endpoint for SQS. |
| <a name="output_vpc_endpoint_sqs_id"></a> [vpc\_endpoint\_sqs\_id](#output\_vpc\_endpoint\_sqs\_id) | The ID of VPC endpoint for SQS |
| <a name="output_vpc_endpoint_sqs_network_interface_ids"></a> [vpc\_endpoint\_sqs\_network\_interface\_ids](#output\_vpc\_endpoint\_sqs\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for SQS. |
| <a name="output_vpc_endpoint_ssm_dns_entry"></a> [vpc\_endpoint\_ssm\_dns\_entry](#output\_vpc\_endpoint\_ssm\_dns\_entry) | The DNS entries for the VPC Endpoint for SSM. |
| <a name="output_vpc_endpoint_ssm_id"></a> [vpc\_endpoint\_ssm\_id](#output\_vpc\_endpoint\_ssm\_id) | The ID of VPC endpoint for SSM |
| <a name="output_vpc_endpoint_ssm_network_interface_ids"></a> [vpc\_endpoint\_ssm\_network\_interface\_ids](#output\_vpc\_endpoint\_ssm\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for SSM. |
| <a name="output_vpc_endpoint_ssmmessages_dns_entry"></a> [vpc\_endpoint\_ssmmessages\_dns\_entry](#output\_vpc\_endpoint\_ssmmessages\_dns\_entry) | The DNS entries for the VPC Endpoint for SSMMESSAGES. |
| <a name="output_vpc_endpoint_ssmmessages_id"></a> [vpc\_endpoint\_ssmmessages\_id](#output\_vpc\_endpoint\_ssmmessages\_id) | The ID of VPC endpoint for SSMMESSAGES |
| <a name="output_vpc_endpoint_ssmmessages_network_interface_ids"></a> [vpc\_endpoint\_ssmmessages\_network\_interface\_ids](#output\_vpc\_endpoint\_ssmmessages\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for SSMMESSAGES. |
| <a name="output_vpc_endpoint_states_dns_entry"></a> [vpc\_endpoint\_states\_dns\_entry](#output\_vpc\_endpoint\_states\_dns\_entry) | The DNS entries for the VPC Endpoint for Step Function. |
| <a name="output_vpc_endpoint_states_id"></a> [vpc\_endpoint\_states\_id](#output\_vpc\_endpoint\_states\_id) | The ID of VPC endpoint for Step Function |
| <a name="output_vpc_endpoint_states_network_interface_ids"></a> [vpc\_endpoint\_states\_network\_interface\_ids](#output\_vpc\_endpoint\_states\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Step Function. |
| <a name="output_vpc_endpoint_storagegateway_dns_entry"></a> [vpc\_endpoint\_storagegateway\_dns\_entry](#output\_vpc\_endpoint\_storagegateway\_dns\_entry) | The DNS entries for the VPC Endpoint for Storage Gateway. |
| <a name="output_vpc_endpoint_storagegateway_id"></a> [vpc\_endpoint\_storagegateway\_id](#output\_vpc\_endpoint\_storagegateway\_id) | The ID of VPC endpoint for Storage Gateway |
| <a name="output_vpc_endpoint_storagegateway_network_interface_ids"></a> [vpc\_endpoint\_storagegateway\_network\_interface\_ids](#output\_vpc\_endpoint\_storagegateway\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Storage Gateway. |
| <a name="output_vpc_endpoint_sts_dns_entry"></a> [vpc\_endpoint\_sts\_dns\_entry](#output\_vpc\_endpoint\_sts\_dns\_entry) | The DNS entries for the VPC Endpoint for STS. |
| <a name="output_vpc_endpoint_sts_id"></a> [vpc\_endpoint\_sts\_id](#output\_vpc\_endpoint\_sts\_id) | The ID of VPC endpoint for STS |
| <a name="output_vpc_endpoint_sts_network_interface_ids"></a> [vpc\_endpoint\_sts\_network\_interface\_ids](#output\_vpc\_endpoint\_sts\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for STS. |
| <a name="output_vpc_endpoint_textract_dns_entry"></a> [vpc\_endpoint\_textract\_dns\_entry](#output\_vpc\_endpoint\_textract\_dns\_entry) | The DNS entries for the VPC Endpoint for Textract. |
| <a name="output_vpc_endpoint_textract_id"></a> [vpc\_endpoint\_textract\_id](#output\_vpc\_endpoint\_textract\_id) | The ID of VPC endpoint for Textract |
| <a name="output_vpc_endpoint_textract_network_interface_ids"></a> [vpc\_endpoint\_textract\_network\_interface\_ids](#output\_vpc\_endpoint\_textract\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Textract. |
| <a name="output_vpc_endpoint_transfer_dns_entry"></a> [vpc\_endpoint\_transfer\_dns\_entry](#output\_vpc\_endpoint\_transfer\_dns\_entry) | The DNS entries for the VPC Endpoint for Transfer. |
| <a name="output_vpc_endpoint_transfer_id"></a> [vpc\_endpoint\_transfer\_id](#output\_vpc\_endpoint\_transfer\_id) | The ID of VPC endpoint for Transfer |
| <a name="output_vpc_endpoint_transfer_network_interface_ids"></a> [vpc\_endpoint\_transfer\_network\_interface\_ids](#output\_vpc\_endpoint\_transfer\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Transfer. |
| <a name="output_vpc_endpoint_transferserver_dns_entry"></a> [vpc\_endpoint\_transferserver\_dns\_entry](#output\_vpc\_endpoint\_transferserver\_dns\_entry) | The DNS entries for the VPC Endpoint for transferserver. |
| <a name="output_vpc_endpoint_transferserver_id"></a> [vpc\_endpoint\_transferserver\_id](#output\_vpc\_endpoint\_transferserver\_id) | The ID of VPC endpoint for transferserver |
| <a name="output_vpc_endpoint_transferserver_network_interface_ids"></a> [vpc\_endpoint\_transferserver\_network\_interface\_ids](#output\_vpc\_endpoint\_transferserver\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for transferserver |
| <a name="output_vpc_endpoint_workspaces_dns_entry"></a> [vpc\_endpoint\_workspaces\_dns\_entry](#output\_vpc\_endpoint\_workspaces\_dns\_entry) | The DNS entries for the VPC Endpoint for Workspaces. |
| <a name="output_vpc_endpoint_workspaces_id"></a> [vpc\_endpoint\_workspaces\_id](#output\_vpc\_endpoint\_workspaces\_id) | The ID of VPC endpoint for Workspaces |
| <a name="output_vpc_endpoint_workspaces_network_interface_ids"></a> [vpc\_endpoint\_workspaces\_network\_interface\_ids](#output\_vpc\_endpoint\_workspaces\_network\_interface\_ids) | One or more network interfaces for the VPC Endpoint for Workspaces. |
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
