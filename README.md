# terraform-docs

[![Build Status](https://github.com/terraform-docs/terraform-docs/workflows/ci/badge.svg)](https://github.com/terraform-docs/terraform-docs/actions) [![GoDoc](https://pkg.go.dev/badge/github.com/terraform-docs/terraform-docs)](https://pkg.go.dev/github.com/terraform-docs/terraform-docs) [![Go Report Card](https://goreportcard.com/badge/github.com/terraform-docs/terraform-docs)](https://goreportcard.com/report/github.com/terraform-docs/terraform-docs) [![Codecov Report](https://codecov.io/gh/terraform-docs/terraform-docs/branch/master/graph/badge.svg)](https://codecov.io/gh/terraform-docs/terraform-docs) [![License](https://img.shields.io/github/license/terraform-docs/terraform-docs)](https://github.com/terraform-docs/terraform-docs/blob/master/LICENSE) [![Latest release](https://img.shields.io/github/v/release/terraform-docs/terraform-docs)](https://github.com/terraform-docs/terraform-docs/releases)

![terraform-docs-teaser](./images/terraform-docs-teaser.png)

## What is terraform-docs

A utility to generate documentation from Terraform modules in various output formats.

## Installation

macOS users can install using [Homebrew]:

```bash
brew install terraform-docs
```

or

```bash
brew install terraform-docs/tap/terraform-docs
```

Windows users can install using [Scoop]:

```bash
scoop bucket add terraform-docs https://github.com/terraform-docs/scoop-bucket
scoop install terraform-docs
```

or [Chocolatey]:

```bash
choco install terraform-docs
```

Stable binaries are also available on the [releases] page. To install, download the
binary for your platform from "Assets" and place this into your `$PATH`:

```bash
curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.19.0/terraform-docs-v0.19.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
mv terraform-docs /usr/local/bin/terraform-docs
```

**NOTE:** Windows releases are in `ZIP` format.

The latest version can be installed using `go install` or `go get`:

```bash
# go1.17+
go install github.com/terraform-docs/terraform-docs@v0.19.0
```

```bash
# go1.16
GO111MODULE="on" go get github.com/terraform-docs/terraform-docs@v0.19.0
```

**NOTE:** please use the latest Go to do this, minimum `go1.16` is required.

This will put `terraform-docs` in `$(go env GOPATH)/bin`. If you encounter the error
`terraform-docs: command not found` after installation then you may need to either add
that directory to your `$PATH` as shown [here] or do a manual installation by cloning
the repo and run `make build` from the repository which will put `terraform-docs` in:

```bash
$(go env GOPATH)/src/github.com/terraform-docs/terraform-docs/bin/$(uname | tr '[:upper:]' '[:lower:]')-amd64/terraform-docs
```

## Usage

### Running the binary directly

To run and generate documentation into README within a directory:

```bash
terraform-docs markdown table --output-file README.md --output-mode inject /path/to/module
```

Check [`output`] configuration for more details and examples.

### Using docker

terraform-docs can be run as a container by mounting a directory with `.tf`
files in it and run the following command:

```bash
docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.19.0 markdown /terraform-docs
```

If `output.file` is not enabled for this module, generated output can be redirected
back to a file:

```bash
docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.19.0 markdown /terraform-docs > doc.md
```

**NOTE:** Docker tag `latest` refers to _latest_ stable released version and `edge`
refers to HEAD of `master` at any given point in time.

### Using GitHub Actions

To use terraform-docs GitHub Action, configure a YAML workflow file (e.g.
`.github/workflows/documentation.yml`) with the following:

```yaml
name: Generate terraform docs
on:
  - pull_request

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
      with:
        ref: ${{ github.event.pull_request.head.ref }}

    - name: Render terraform docs and push changes back to PR
      uses: terraform-docs/gh-actions@main
      with:
        working-dir: .
        output-file: README.md
        output-method: inject
        git-push: "true"
```

Read more about [terraform-docs GitHub Action] and its configuration and
examples.

### pre-commit hook

With pre-commit, you can ensure your Terraform module documentation is kept
up-to-date each time you make a commit.

First [install pre-commit] and then create or update a `.pre-commit-config.yaml`
in the root of your Git repo with at least the following content:

```yaml
repos:
  - repo: https://github.com/terraform-docs/terraform-docs
    rev: "v0.19.0"
    hooks:
      - id: terraform-docs-go
        args: ["markdown", "table", "--output-file", "README.md", "./mymodule/path"]
```

Then run:

```bash
pre-commit install
pre-commit install-hooks
```

Further changes to your module's `.tf` files will cause an update to documentation
when you make a commit.

## Configuration

terraform-docs can be configured with a yaml file. The default name of this file is
`.terraform-docs.yml` and the path order for locating it is:

1. root of module directory
1. `.config/` folder at root of module directory
1. current directory
1. `.config/` folder at current directory
1. `$HOME/.tfdocs.d/`

```yaml
formatter: "" # this is required

version: ""

header-from: main.tf
footer-from: ""

recursive:
  enabled: false
  path: modules
  include-main: true

sections:
  hide: []
  show: []

content: ""

output:
  file: ""
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.46 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.46 |

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
| [aws_route.database_dns64_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.database_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.database_ipv6_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.database_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_dns64_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_ipv6_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_route_table_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
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
| [aws_vpc_ipv4_cidr_block_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_vpn_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) | resource |
| [aws_vpn_gateway_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_attachment) | resource |
| [aws_vpn_gateway_route_propagation.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) | resource |
| [aws_vpn_gateway_route_propagation.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) | resource |
| [aws_vpn_gateway_route_propagation.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.flow_log_cloudwatch_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_side_asn"></a> [amazon\_side\_asn](#input\_amazon\_side\_asn) | The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN | `string` | `"64512"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones names or ids in the region | `list(string)` | `[]` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | (Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id` | `string` | `"10.0.0.0/16"` | no |
| <a name="input_create_database_internet_gateway_route"></a> [create\_database\_internet\_gateway\_route](#input\_create\_database\_internet\_gateway\_route) | Controls if an internet gateway route for public database access should be created | `bool` | `false` | no |
| <a name="input_create_database_nat_gateway_route"></a> [create\_database\_nat\_gateway\_route](#input\_create\_database\_nat\_gateway\_route) | Controls if a nat gateway route should be created to give internet access to the database subnets | `bool` | `false` | no |
| <a name="input_create_database_subnet_group"></a> [create\_database\_subnet\_group](#input\_create\_database\_subnet\_group) | Controls if database subnet group should be created (n.b. database\_subnets must also be set) | `bool` | `true` | no |
| <a name="input_create_database_subnet_route_table"></a> [create\_database\_subnet\_route\_table](#input\_create\_database\_subnet\_route\_table) | Controls if separate route table for database should be created | `bool` | `false` | no |
| <a name="input_create_egress_only_igw"></a> [create\_egress\_only\_igw](#input\_create\_egress\_only\_igw) | Controls if an Egress Only Internet Gateway is created and its related routes | `bool` | `true` | no |
| <a name="input_create_elasticache_subnet_group"></a> [create\_elasticache\_subnet\_group](#input\_create\_elasticache\_subnet\_group) | Controls if elasticache subnet group should be created | `bool` | `true` | no |
| <a name="input_create_elasticache_subnet_route_table"></a> [create\_elasticache\_subnet\_route\_table](#input\_create\_elasticache\_subnet\_route\_table) | Controls if separate route table for elasticache should be created | `bool` | `false` | no |
| <a name="input_create_flow_log_cloudwatch_iam_role"></a> [create\_flow\_log\_cloudwatch\_iam\_role](#input\_create\_flow\_log\_cloudwatch\_iam\_role) | Whether to create IAM role for VPC Flow Logs | `bool` | `false` | no |
| <a name="input_create_flow_log_cloudwatch_log_group"></a> [create\_flow\_log\_cloudwatch\_log\_group](#input\_create\_flow\_log\_cloudwatch\_log\_group) | Whether to create CloudWatch log group for VPC Flow Logs | `bool` | `false` | no |
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | Controls if an Internet Gateway is created for public subnets and the related routes that connect them | `bool` | `true` | no |
| <a name="input_create_multiple_intra_route_tables"></a> [create\_multiple\_intra\_route\_tables](#input\_create\_multiple\_intra\_route\_tables) | Indicates whether to create a separate route table for each intra subnet. Default: `false` | `bool` | `false` | no |
| <a name="input_create_multiple_public_route_tables"></a> [create\_multiple\_public\_route\_tables](#input\_create\_multiple\_public\_route\_tables) | Indicates whether to create a separate route table for each public subnet. Default: `false` | `bool` | `false` | no |
| <a name="input_create_private_nat_gateway_route"></a> [create\_private\_nat\_gateway\_route](#input\_create\_private\_nat\_gateway\_route) | Controls if a nat gateway route should be created to give internet access to the private subnets | `bool` | `true` | no |
| <a name="input_create_redshift_subnet_group"></a> [create\_redshift\_subnet\_group](#input\_create\_redshift\_subnet\_group) | Controls if redshift subnet group should be created | `bool` | `true` | no |
| <a name="input_create_redshift_subnet_route_table"></a> [create\_redshift\_subnet\_route\_table](#input\_create\_redshift\_subnet\_route\_table) | Controls if separate route table for redshift should be created | `bool` | `false` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Controls if VPC should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_customer_gateway_tags"></a> [customer\_gateway\_tags](#input\_customer\_gateway\_tags) | Additional tags for the Customer Gateway | `map(string)` | `{}` | no |
| <a name="input_customer_gateways"></a> [customer\_gateways](#input\_customer\_gateways) | Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address) | `map(map(any))` | `{}` | no |
| <a name="input_customer_owned_ipv4_pool"></a> [customer\_owned\_ipv4\_pool](#input\_customer\_owned\_ipv4\_pool) | The customer owned IPv4 address pool. Typically used with the `map_customer_owned_ip_on_launch` argument. The `outpost_arn` argument must be specified when configured | `string` | `null` | no |
| <a name="input_database_acl_tags"></a> [database\_acl\_tags](#input\_database\_acl\_tags) | Additional tags for the database subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_database_dedicated_network_acl"></a> [database\_dedicated\_network\_acl](#input\_database\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for database subnets | `bool` | `false` | no |
| <a name="input_database_inbound_acl_rules"></a> [database\_inbound\_acl\_rules](#input\_database\_inbound\_acl\_rules) | Database subnets inbound network ACL rules | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_database_outbound_acl_rules"></a> [database\_outbound\_acl\_rules](#input\_database\_outbound\_acl\_rules) | Database subnets outbound network ACL rules | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_database_route_table_tags"></a> [database\_route\_table\_tags](#input\_database\_route\_table\_tags) | Additional tags for the database route tables | `map(string)` | `{}` | no |
| <a name="input_database_subnet_assign_ipv6_address_on_creation"></a> [database\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_database\_subnet\_assign\_ipv6\_address\_on\_creation) | Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false` | `bool` | `false` | no |
| <a name="input_database_subnet_enable_dns64"></a> [database\_subnet\_enable\_dns64](#input\_database\_subnet\_enable\_dns64) | Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true` | `bool` | `true` | no |
| <a name="input_database_subnet_enable_resource_name_dns_a_record_on_launch"></a> [database\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch](#input\_database\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false` | `bool` | `false` | no |
| <a name="input_database_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [database\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch](#input\_database\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true` | `bool` | `true` | no |
| <a name="input_database_subnet_group_name"></a> [database\_subnet\_group\_name](#input\_database\_subnet\_group\_name) | Name of database subnet group | `string` | `null` | no |
| <a name="input_database_subnet_group_tags"></a> [database\_subnet\_group\_tags](#input\_database\_subnet\_group\_tags) | Additional tags for the database subnet group | `map(string)` | `{}` | no |
| <a name="input_database_subnet_ipv6_native"></a> [database\_subnet\_ipv6\_native](#input\_database\_subnet\_ipv6\_native) | Indicates whether to create an IPv6-only subnet. Default: `false` | `bool` | `false` | no |
| <a name="input_database_subnet_ipv6_prefixes"></a> [database\_subnet\_ipv6\_prefixes](#input\_database\_subnet\_ipv6\_prefixes) | Assigns IPv6 database subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_database_subnet_names"></a> [database\_subnet\_names](#input\_database\_subnet\_names) | Explicit values to use in the Name tag on database subnets. If empty, Name tags are generated | `list(string)` | `[]` | no |
| <a name="input_database_subnet_private_dns_hostname_type_on_launch"></a> [database\_subnet\_private\_dns\_hostname\_type\_on\_launch](#input\_database\_subnet\_private\_dns\_hostname\_type\_on\_launch) | The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name` | `string` | `null` | no |
| <a name="input_database_subnet_suffix"></a> [database\_subnet\_suffix](#input\_database\_subnet\_suffix) | Suffix to append to database subnets name | `string` | `"db"` | no |
| <a name="input_database_subnet_tags"></a> [database\_subnet\_tags](#input\_database\_subnet\_tags) | Additional tags for the database subnets | `map(string)` | `{}` | no |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | A list of database subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_default_network_acl_egress"></a> [default\_network\_acl\_egress](#input\_default\_network\_acl\_egress) | List of maps of egress rules to set on the Default Network ACL | `list(map(string))` | <pre>[<br/>  {<br/>    "action": "allow",<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_no": 100,<br/>    "to_port": 0<br/>  },<br/>  {<br/>    "action": "allow",<br/>    "from_port": 0,<br/>    "ipv6_cidr_block": "::/0",<br/>    "protocol": "-1",<br/>    "rule_no": 101,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_default_network_acl_ingress"></a> [default\_network\_acl\_ingress](#input\_default\_network\_acl\_ingress) | List of maps of ingress rules to set on the Default Network ACL | `list(map(string))` | <pre>[<br/>  {<br/>    "action": "allow",<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_no": 100,<br/>    "to_port": 0<br/>  },<br/>  {<br/>    "action": "allow",<br/>    "from_port": 0,<br/>    "ipv6_cidr_block": "::/0",<br/>    "protocol": "-1",<br/>    "rule_no": 101,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_default_network_acl_name"></a> [default\_network\_acl\_name](#input\_default\_network\_acl\_name) | Name to be used on the Default Network ACL | `string` | `null` | no |
| <a name="input_default_network_acl_tags"></a> [default\_network\_acl\_tags](#input\_default\_network\_acl\_tags) | Additional tags for the Default Network ACL | `map(string)` | `{}` | no |
| <a name="input_default_route_table_name"></a> [default\_route\_table\_name](#input\_default\_route\_table\_name) | Name to be used on the default route table | `string` | `null` | no |
| <a name="input_default_route_table_propagating_vgws"></a> [default\_route\_table\_propagating\_vgws](#input\_default\_route\_table\_propagating\_vgws) | List of virtual gateways for propagation | `list(string)` | `[]` | no |
| <a name="input_default_route_table_routes"></a> [default\_route\_table\_routes](#input\_default\_route\_table\_routes) | Configuration block of routes. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table#route | `list(map(string))` | `[]` | no |
| <a name="input_default_route_table_tags"></a> [default\_route\_table\_tags](#input\_default\_route\_table\_tags) | Additional tags for the default route table | `map(string)` | `{}` | no |
| <a name="input_default_security_group_egress"></a> [default\_security\_group\_egress](#input\_default\_security\_group\_egress) | List of maps of egress rules to set on the default security group | `list(map(string))` | `[]` | no |
| <a name="input_default_security_group_ingress"></a> [default\_security\_group\_ingress](#input\_default\_security\_group\_ingress) | List of maps of ingress rules to set on the default security group | `list(map(string))` | `[]` | no |
| <a name="input_default_security_group_name"></a> [default\_security\_group\_name](#input\_default\_security\_group\_name) | Name to be used on the default security group | `string` | `null` | no |
| <a name="input_default_security_group_tags"></a> [default\_security\_group\_tags](#input\_default\_security\_group\_tags) | Additional tags for the default security group | `map(string)` | `{}` | no |
| <a name="input_default_vpc_enable_dns_hostnames"></a> [default\_vpc\_enable\_dns\_hostnames](#input\_default\_vpc\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the Default VPC | `bool` | `true` | no |
| <a name="input_default_vpc_enable_dns_support"></a> [default\_vpc\_enable\_dns\_support](#input\_default\_vpc\_enable\_dns\_support) | Should be true to enable DNS support in the Default VPC | `bool` | `true` | no |
| <a name="input_default_vpc_name"></a> [default\_vpc\_name](#input\_default\_vpc\_name) | Name to be used on the Default VPC | `string` | `null` | no |
| <a name="input_default_vpc_tags"></a> [default\_vpc\_tags](#input\_default\_vpc\_tags) | Additional tags for the Default VPC | `map(string)` | `{}` | no |
| <a name="input_dhcp_options_domain_name"></a> [dhcp\_options\_domain\_name](#input\_dhcp\_options\_domain\_name) | Specifies DNS name for DHCP options set (requires enable\_dhcp\_options set to true) | `string` | `""` | no |
| <a name="input_dhcp_options_domain_name_servers"></a> [dhcp\_options\_domain\_name\_servers](#input\_dhcp\_options\_domain\_name\_servers) | Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable\_dhcp\_options set to true) | `list(string)` | <pre>[<br/>  "AmazonProvidedDNS"<br/>]</pre> | no |
| <a name="input_dhcp_options_ipv6_address_preferred_lease_time"></a> [dhcp\_options\_ipv6\_address\_preferred\_lease\_time](#input\_dhcp\_options\_ipv6\_address\_preferred\_lease\_time) | How frequently, in seconds, a running instance with an IPv6 assigned to it goes through DHCPv6 lease renewal (requires enable\_dhcp\_options set to true) | `number` | `null` | no |
| <a name="input_dhcp_options_netbios_name_servers"></a> [dhcp\_options\_netbios\_name\_servers](#input\_dhcp\_options\_netbios\_name\_servers) | Specify a list of netbios servers for DHCP options set (requires enable\_dhcp\_options set to true) | `list(string)` | `[]` | no |
| <a name="input_dhcp_options_netbios_node_type"></a> [dhcp\_options\_netbios\_node\_type](#input\_dhcp\_options\_netbios\_node\_type) | Specify netbios node\_type for DHCP options set (requires enable\_dhcp\_options set to true) | `string` | `""` | no |
| <a name="input_dhcp_options_ntp_servers"></a> [dhcp\_options\_ntp\_servers](#input\_dhcp\_options\_ntp\_servers) | Specify a list of NTP servers for DHCP options set (requires enable\_dhcp\_options set to true) | `list(string)` | `[]` | no |
| <a name="input_dhcp_options_tags"></a> [dhcp\_options\_tags](#input\_dhcp\_options\_tags) | Additional tags for the DHCP option set (requires enable\_dhcp\_options set to true) | `map(string)` | `{}` | no |
| <a name="input_elasticache_acl_tags"></a> [elasticache\_acl\_tags](#input\_elasticache\_acl\_tags) | Additional tags for the elasticache subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_elasticache_dedicated_network_acl"></a> [elasticache\_dedicated\_network\_acl](#input\_elasticache\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for elasticache subnets | `bool` | `false` | no |
| <a name="input_elasticache_inbound_acl_rules"></a> [elasticache\_inbound\_acl\_rules](#input\_elasticache\_inbound\_acl\_rules) | Elasticache subnets inbound network ACL rules | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_elasticache_outbound_acl_rules"></a> [elasticache\_outbound\_acl\_rules](#input\_elasticache\_outbound\_acl\_rules) | Elasticache subnets outbound network ACL rules | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_elasticache_route_table_tags"></a> [elasticache\_route\_table\_tags](#input\_elasticache\_route\_table\_tags) | Additional tags for the elasticache route tables | `map(string)` | `{}` | no |
| <a name="input_elasticache_subnet_assign_ipv6_address_on_creation"></a> [elasticache\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_elasticache\_subnet\_assign\_ipv6\_address\_on\_creation) | Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false` | `bool` | `false` | no |
| <a name="input_elasticache_subnet_enable_dns64"></a> [elasticache\_subnet\_enable\_dns64](#input\_elasticache\_subnet\_enable\_dns64) | Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true` | `bool` | `true` | no |
| <a name="input_elasticache_subnet_enable_resource_name_dns_a_record_on_launch"></a> [elasticache\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch](#input\_elasticache\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false` | `bool` | `false` | no |
| <a name="input_elasticache_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [elasticache\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch](#input\_elasticache\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true` | `bool` | `true` | no |
| <a name="input_elasticache_subnet_group_name"></a> [elasticache\_subnet\_group\_name](#input\_elasticache\_subnet\_group\_name) | Name of elasticache subnet group | `string` | `null` | no |
| <a name="input_elasticache_subnet_group_tags"></a> [elasticache\_subnet\_group\_tags](#input\_elasticache\_subnet\_group\_tags) | Additional tags for the elasticache subnet group | `map(string)` | `{}` | no |
| <a name="input_elasticache_subnet_ipv6_native"></a> [elasticache\_subnet\_ipv6\_native](#input\_elasticache\_subnet\_ipv6\_native) | Indicates whether to create an IPv6-only subnet. Default: `false` | `bool` | `false` | no |
| <a name="input_elasticache_subnet_ipv6_prefixes"></a> [elasticache\_subnet\_ipv6\_prefixes](#input\_elasticache\_subnet\_ipv6\_prefixes) | Assigns IPv6 elasticache subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_elasticache_subnet_names"></a> [elasticache\_subnet\_names](#input\_elasticache\_subnet\_names) | Explicit values to use in the Name tag on elasticache subnets. If empty, Name tags are generated | `list(string)` | `[]` | no |
| <a name="input_elasticache_subnet_private_dns_hostname_type_on_launch"></a> [elasticache\_subnet\_private\_dns\_hostname\_type\_on\_launch](#input\_elasticache\_subnet\_private\_dns\_hostname\_type\_on\_launch) | The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name` | `string` | `null` | no |
| <a name="input_elasticache_subnet_suffix"></a> [elasticache\_subnet\_suffix](#input\_elasticache\_subnet\_suffix) | Suffix to append to elasticache subnets name | `string` | `"elasticache"` | no |
| <a name="input_elasticache_subnet_tags"></a> [elasticache\_subnet\_tags](#input\_elasticache\_subnet\_tags) | Additional tags for the elasticache subnets | `map(string)` | `{}` | no |
| <a name="input_elasticache_subnets"></a> [elasticache\_subnets](#input\_elasticache\_subnets) | A list of elasticache subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_enable_dhcp_options"></a> [enable\_dhcp\_options](#input\_enable\_dhcp\_options) | Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type | `bool` | `false` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | Whether or not to enable VPC Flow Logs | `bool` | `false` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block | `bool` | `false` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `false` | no |
| <a name="input_enable_network_address_usage_metrics"></a> [enable\_network\_address\_usage\_metrics](#input\_enable\_network\_address\_usage\_metrics) | Determines whether network address usage metrics are enabled for the VPC | `bool` | `null` | no |
| <a name="input_enable_public_redshift"></a> [enable\_public\_redshift](#input\_enable\_public\_redshift) | Controls if redshift should have public routing table | `bool` | `false` | no |
| <a name="input_enable_vpn_gateway"></a> [enable\_vpn\_gateway](#input\_enable\_vpn\_gateway) | Should be true if you want to create a new VPN Gateway resource and attach it to the VPC | `bool` | `false` | no |
| <a name="input_external_nat_ip_ids"></a> [external\_nat\_ip\_ids](#input\_external\_nat\_ip\_ids) | List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse\_nat\_ips) | `list(string)` | `[]` | no |
| <a name="input_external_nat_ips"></a> [external\_nat\_ips](#input\_external\_nat\_ips) | List of EIPs to be used for `nat_public_ips` output (used in combination with reuse\_nat\_ips and external\_nat\_ip\_ids) | `list(string)` | `[]` | no |
| <a name="input_flow_log_cloudwatch_iam_role_arn"></a> [flow\_log\_cloudwatch\_iam\_role\_arn](#input\_flow\_log\_cloudwatch\_iam\_role\_arn) | The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When flow\_log\_destination\_arn is set to ARN of Cloudwatch Logs, this argument needs to be provided | `string` | `""` | no |
| <a name="input_flow_log_cloudwatch_iam_role_conditions"></a> [flow\_log\_cloudwatch\_iam\_role\_conditions](#input\_flow\_log\_cloudwatch\_iam\_role\_conditions) | Additional conditions of the CloudWatch role assumption policy | <pre>list(object({<br/>    test     = string<br/>    variable = string<br/>    values   = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_flow_log_cloudwatch_log_group_class"></a> [flow\_log\_cloudwatch\_log\_group\_class](#input\_flow\_log\_cloudwatch\_log\_group\_class) | Specified the log class of the log group. Possible values are: STANDARD or INFREQUENT\_ACCESS | `string` | `null` | no |
| <a name="input_flow_log_cloudwatch_log_group_kms_key_id"></a> [flow\_log\_cloudwatch\_log\_group\_kms\_key\_id](#input\_flow\_log\_cloudwatch\_log\_group\_kms\_key\_id) | The ARN of the KMS Key to use when encrypting log data for VPC flow logs | `string` | `null` | no |
| <a name="input_flow_log_cloudwatch_log_group_name_prefix"></a> [flow\_log\_cloudwatch\_log\_group\_name\_prefix](#input\_flow\_log\_cloudwatch\_log\_group\_name\_prefix) | Specifies the name prefix of CloudWatch Log Group for VPC flow logs | `string` | `"/aws/vpc-flow-log/"` | no |
| <a name="input_flow_log_cloudwatch_log_group_name_suffix"></a> [flow\_log\_cloudwatch\_log\_group\_name\_suffix](#input\_flow\_log\_cloudwatch\_log\_group\_name\_suffix) | Specifies the name suffix of CloudWatch Log Group for VPC flow logs | `string` | `""` | no |
| <a name="input_flow_log_cloudwatch_log_group_retention_in_days"></a> [flow\_log\_cloudwatch\_log\_group\_retention\_in\_days](#input\_flow\_log\_cloudwatch\_log\_group\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group for VPC flow logs | `number` | `null` | no |
| <a name="input_flow_log_cloudwatch_log_group_skip_destroy"></a> [flow\_log\_cloudwatch\_log\_group\_skip\_destroy](#input\_flow\_log\_cloudwatch\_log\_group\_skip\_destroy) | Set to true if you do not wish the log group (and any logs it may contain) to be deleted at destroy time, and instead just remove the log group from the Terraform state | `bool` | `false` | no |
| <a name="input_flow_log_deliver_cross_account_role"></a> [flow\_log\_deliver\_cross\_account\_role](#input\_flow\_log\_deliver\_cross\_account\_role) | (Optional) ARN of the IAM role that allows Amazon EC2 to publish flow logs across accounts. | `string` | `null` | no |
| <a name="input_flow_log_destination_arn"></a> [flow\_log\_destination\_arn](#input\_flow\_log\_destination\_arn) | The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create\_flow\_log\_cloudwatch\_log\_group is set to false this argument must be provided | `string` | `""` | no |
| <a name="input_flow_log_destination_type"></a> [flow\_log\_destination\_type](#input\_flow\_log\_destination\_type) | Type of flow log destination. Can be s3, kinesis-data-firehose or cloud-watch-logs | `string` | `"cloud-watch-logs"` | no |
| <a name="input_flow_log_file_format"></a> [flow\_log\_file\_format](#input\_flow\_log\_file\_format) | (Optional) The format for the flow log. Valid values: `plain-text`, `parquet` | `string` | `null` | no |
| <a name="input_flow_log_hive_compatible_partitions"></a> [flow\_log\_hive\_compatible\_partitions](#input\_flow\_log\_hive\_compatible\_partitions) | (Optional) Indicates whether to use Hive-compatible prefixes for flow logs stored in Amazon S3 | `bool` | `false` | no |
| <a name="input_flow_log_log_format"></a> [flow\_log\_log\_format](#input\_flow\_log\_log\_format) | The fields to include in the flow log record, in the order in which they should appear | `string` | `null` | no |
| <a name="input_flow_log_max_aggregation_interval"></a> [flow\_log\_max\_aggregation\_interval](#input\_flow\_log\_max\_aggregation\_interval) | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds | `number` | `600` | no |
| <a name="input_flow_log_per_hour_partition"></a> [flow\_log\_per\_hour\_partition](#input\_flow\_log\_per\_hour\_partition) | (Optional) Indicates whether to partition the flow log per hour. This reduces the cost and response time for queries | `bool` | `false` | no |
| <a name="input_flow_log_traffic_type"></a> [flow\_log\_traffic\_type](#input\_flow\_log\_traffic\_type) | The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL | `string` | `"ALL"` | no |
| <a name="input_igw_tags"></a> [igw\_tags](#input\_igw\_tags) | Additional tags for the internet gateway | `map(string)` | `{}` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | A tenancy option for instances launched into the VPC | `string` | `"default"` | no |
| <a name="input_intra_acl_tags"></a> [intra\_acl\_tags](#input\_intra\_acl\_tags) | Additional tags for the intra subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_intra_dedicated_network_acl"></a> [intra\_dedicated\_network\_acl](#input\_intra\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for intra subnets | `bool` | `false` | no |
| <a name="input_intra_inbound_acl_rules"></a> [intra\_inbound\_acl\_rules](#input\_intra\_inbound\_acl\_rules) | Intra subnets inbound network ACLs | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_intra_outbound_acl_rules"></a> [intra\_outbound\_acl\_rules](#input\_intra\_outbound\_acl\_rules) | Intra subnets outbound network ACLs | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_intra_route_table_tags"></a> [intra\_route\_table\_tags](#input\_intra\_route\_table\_tags) | Additional tags for the intra route tables | `map(string)` | `{}` | no |
| <a name="input_intra_subnet_assign_ipv6_address_on_creation"></a> [intra\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_intra\_subnet\_assign\_ipv6\_address\_on\_creation) | Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false` | `bool` | `false` | no |
| <a name="input_intra_subnet_enable_dns64"></a> [intra\_subnet\_enable\_dns64](#input\_intra\_subnet\_enable\_dns64) | Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true` | `bool` | `true` | no |
| <a name="input_intra_subnet_enable_resource_name_dns_a_record_on_launch"></a> [intra\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch](#input\_intra\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false` | `bool` | `false` | no |
| <a name="input_intra_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [intra\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch](#input\_intra\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true` | `bool` | `true` | no |
| <a name="input_intra_subnet_ipv6_native"></a> [intra\_subnet\_ipv6\_native](#input\_intra\_subnet\_ipv6\_native) | Indicates whether to create an IPv6-only subnet. Default: `false` | `bool` | `false` | no |
| <a name="input_intra_subnet_ipv6_prefixes"></a> [intra\_subnet\_ipv6\_prefixes](#input\_intra\_subnet\_ipv6\_prefixes) | Assigns IPv6 intra subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_intra_subnet_names"></a> [intra\_subnet\_names](#input\_intra\_subnet\_names) | Explicit values to use in the Name tag on intra subnets. If empty, Name tags are generated | `list(string)` | `[]` | no |
| <a name="input_intra_subnet_private_dns_hostname_type_on_launch"></a> [intra\_subnet\_private\_dns\_hostname\_type\_on\_launch](#input\_intra\_subnet\_private\_dns\_hostname\_type\_on\_launch) | The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name` | `string` | `null` | no |
| <a name="input_intra_subnet_suffix"></a> [intra\_subnet\_suffix](#input\_intra\_subnet\_suffix) | Suffix to append to intra subnets name | `string` | `"intra"` | no |
| <a name="input_intra_subnet_tags"></a> [intra\_subnet\_tags](#input\_intra\_subnet\_tags) | Additional tags for the intra subnets | `map(string)` | `{}` | no |
| <a name="input_intra_subnets"></a> [intra\_subnets](#input\_intra\_subnets) | A list of intra subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_ipv4_ipam_pool_id"></a> [ipv4\_ipam\_pool\_id](#input\_ipv4\_ipam\_pool\_id) | (Optional) The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR | `string` | `null` | no |
| <a name="input_ipv4_netmask_length"></a> [ipv4\_netmask\_length](#input\_ipv4\_netmask\_length) | (Optional) The netmask length of the IPv4 CIDR you want to allocate to this VPC. Requires specifying a ipv4\_ipam\_pool\_id | `number` | `null` | no |
| <a name="input_ipv6_cidr"></a> [ipv6\_cidr](#input\_ipv6\_cidr) | (Optional) IPv6 CIDR block to request from an IPAM Pool. Can be set explicitly or derived from IPAM using `ipv6_netmask_length` | `string` | `null` | no |
| <a name="input_ipv6_cidr_block_network_border_group"></a> [ipv6\_cidr\_block\_network\_border\_group](#input\_ipv6\_cidr\_block\_network\_border\_group) | By default when an IPv6 CIDR is assigned to a VPC a default ipv6\_cidr\_block\_network\_border\_group will be set to the region of the VPC. This can be changed to restrict advertisement of public addresses to specific Network Border Groups such as LocalZones | `string` | `null` | no |
| <a name="input_ipv6_ipam_pool_id"></a> [ipv6\_ipam\_pool\_id](#input\_ipv6\_ipam\_pool\_id) | (Optional) IPAM Pool ID for a IPv6 pool. Conflicts with `assign_generated_ipv6_cidr_block` | `string` | `null` | no |
| <a name="input_ipv6_netmask_length"></a> [ipv6\_netmask\_length](#input\_ipv6\_netmask\_length) | (Optional) Netmask length to request from IPAM Pool. Conflicts with `ipv6_cidr_block`. This can be omitted if IPAM pool as a `allocation_default_netmask_length` set. Valid values: `56` | `number` | `null` | no |
| <a name="input_manage_default_network_acl"></a> [manage\_default\_network\_acl](#input\_manage\_default\_network\_acl) | Should be true to adopt and manage Default Network ACL | `bool` | `true` | no |
| <a name="input_manage_default_route_table"></a> [manage\_default\_route\_table](#input\_manage\_default\_route\_table) | Should be true to manage default route table | `bool` | `true` | no |
| <a name="input_manage_default_security_group"></a> [manage\_default\_security\_group](#input\_manage\_default\_security\_group) | Should be true to adopt and manage default security group | `bool` | `true` | no |
| <a name="input_manage_default_vpc"></a> [manage\_default\_vpc](#input\_manage\_default\_vpc) | Should be true to adopt and manage Default VPC | `bool` | `false` | no |
| <a name="input_map_customer_owned_ip_on_launch"></a> [map\_customer\_owned\_ip\_on\_launch](#input\_map\_customer\_owned\_ip\_on\_launch) | Specify true to indicate that network interfaces created in the subnet should be assigned a customer owned IP address. The `customer_owned_ipv4_pool` and `outpost_arn` arguments must be specified when set to `true`. Default is `false` | `bool` | `false` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is `false` | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier | `string` | `""` | no |
| <a name="input_nat_eip_tags"></a> [nat\_eip\_tags](#input\_nat\_eip\_tags) | Additional tags for the NAT EIP | `map(string)` | `{}` | no |
| <a name="input_nat_gateway_destination_cidr_block"></a> [nat\_gateway\_destination\_cidr\_block](#input\_nat\_gateway\_destination\_cidr\_block) | Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route | `string` | `"0.0.0.0/0"` | no |
| <a name="input_nat_gateway_tags"></a> [nat\_gateway\_tags](#input\_nat\_gateway\_tags) | Additional tags for the NAT gateways | `map(string)` | `{}` | no |
| <a name="input_one_nat_gateway_per_az"></a> [one\_nat\_gateway\_per\_az](#input\_one\_nat\_gateway\_per\_az) | Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs` | `bool` | `false` | no |
| <a name="input_outpost_acl_tags"></a> [outpost\_acl\_tags](#input\_outpost\_acl\_tags) | Additional tags for the outpost subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_outpost_arn"></a> [outpost\_arn](#input\_outpost\_arn) | ARN of Outpost you want to create a subnet in | `string` | `null` | no |
| <a name="input_outpost_az"></a> [outpost\_az](#input\_outpost\_az) | AZ where Outpost is anchored | `string` | `null` | no |
| <a name="input_outpost_dedicated_network_acl"></a> [outpost\_dedicated\_network\_acl](#input\_outpost\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for outpost subnets | `bool` | `false` | no |
| <a name="input_outpost_inbound_acl_rules"></a> [outpost\_inbound\_acl\_rules](#input\_outpost\_inbound\_acl\_rules) | Outpost subnets inbound network ACLs | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_outpost_outbound_acl_rules"></a> [outpost\_outbound\_acl\_rules](#input\_outpost\_outbound\_acl\_rules) | Outpost subnets outbound network ACLs | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_outpost_subnet_assign_ipv6_address_on_creation"></a> [outpost\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_outpost\_subnet\_assign\_ipv6\_address\_on\_creation) | Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false` | `bool` | `false` | no |
| <a name="input_outpost_subnet_enable_dns64"></a> [outpost\_subnet\_enable\_dns64](#input\_outpost\_subnet\_enable\_dns64) | Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true` | `bool` | `true` | no |
| <a name="input_outpost_subnet_enable_resource_name_dns_a_record_on_launch"></a> [outpost\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch](#input\_outpost\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false` | `bool` | `false` | no |
| <a name="input_outpost_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [outpost\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch](#input\_outpost\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true` | `bool` | `true` | no |
| <a name="input_outpost_subnet_ipv6_native"></a> [outpost\_subnet\_ipv6\_native](#input\_outpost\_subnet\_ipv6\_native) | Indicates whether to create an IPv6-only subnet. Default: `false` | `bool` | `false` | no |
| <a name="input_outpost_subnet_ipv6_prefixes"></a> [outpost\_subnet\_ipv6\_prefixes](#input\_outpost\_subnet\_ipv6\_prefixes) | Assigns IPv6 outpost subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_outpost_subnet_names"></a> [outpost\_subnet\_names](#input\_outpost\_subnet\_names) | Explicit values to use in the Name tag on outpost subnets. If empty, Name tags are generated | `list(string)` | `[]` | no |
| <a name="input_outpost_subnet_private_dns_hostname_type_on_launch"></a> [outpost\_subnet\_private\_dns\_hostname\_type\_on\_launch](#input\_outpost\_subnet\_private\_dns\_hostname\_type\_on\_launch) | The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name` | `string` | `null` | no |
| <a name="input_outpost_subnet_suffix"></a> [outpost\_subnet\_suffix](#input\_outpost\_subnet\_suffix) | Suffix to append to outpost subnets name | `string` | `"outpost"` | no |
| <a name="input_outpost_subnet_tags"></a> [outpost\_subnet\_tags](#input\_outpost\_subnet\_tags) | Additional tags for the outpost subnets | `map(string)` | `{}` | no |
| <a name="input_outpost_subnets"></a> [outpost\_subnets](#input\_outpost\_subnets) | A list of outpost subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_private_acl_tags"></a> [private\_acl\_tags](#input\_private\_acl\_tags) | Additional tags for the private subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_private_dedicated_network_acl"></a> [private\_dedicated\_network\_acl](#input\_private\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for private subnets | `bool` | `false` | no |
| <a name="input_private_inbound_acl_rules"></a> [private\_inbound\_acl\_rules](#input\_private\_inbound\_acl\_rules) | Private subnets inbound network ACLs | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_private_outbound_acl_rules"></a> [private\_outbound\_acl\_rules](#input\_private\_outbound\_acl\_rules) | Private subnets outbound network ACLs | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_private_route_table_routes"></a> [private\_route\_table\_routes](#input\_private\_route\_table\_routes) | A map of private route table IDs to a list of route objects. | <pre>map(list(object({<br/>    destination_cidr_block      = string<br/>    destination_ipv6_cidr_block = string<br/>    egress_only_gateway_id      = string<br/>    gateway_id                  = string<br/>    nat_gateway_id              = string<br/>    transit_gateway_id          = string<br/>    vpc_peering_connection_id   = string<br/>    local_gateway_id            = string<br/>    carrier_gateway_id          = string<br/>    destination_prefix_list_id  = string<br/>  })))</pre> | `{}` | no |
| <a name="input_private_route_table_tags"></a> [private\_route\_table\_tags](#input\_private\_route\_table\_tags) | Additional tags for the private route tables | `map(string)` | `{}` | no |
| <a name="input_private_subnet_assign_ipv6_address_on_creation"></a> [private\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_private\_subnet\_assign\_ipv6\_address\_on\_creation) | Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false` | `bool` | `false` | no |
| <a name="input_private_subnet_enable_dns64"></a> [private\_subnet\_enable\_dns64](#input\_private\_subnet\_enable\_dns64) | Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true` | `bool` | `true` | no |
| <a name="input_private_subnet_enable_resource_name_dns_a_record_on_launch"></a> [private\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch](#input\_private\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false` | `bool` | `false` | no |
| <a name="input_private_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [private\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch](#input\_private\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true` | `bool` | `true` | no |
| <a name="input_private_subnet_ipv6_native"></a> [private\_subnet\_ipv6\_native](#input\_private\_subnet\_ipv6\_native) | Indicates whether to create an IPv6-only subnet. Default: `false` | `bool` | `false` | no |
| <a name="input_private_subnet_ipv6_prefixes"></a> [private\_subnet\_ipv6\_prefixes](#input\_private\_subnet\_ipv6\_prefixes) | Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_private_subnet_names"></a> [private\_subnet\_names](#input\_private\_subnet\_names) | Explicit values to use in the Name tag on private subnets. If empty, Name tags are generated | `list(string)` | `[]` | no |
| <a name="input_private_subnet_private_dns_hostname_type_on_launch"></a> [private\_subnet\_private\_dns\_hostname\_type\_on\_launch](#input\_private\_subnet\_private\_dns\_hostname\_type\_on\_launch) | The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name` | `string` | `null` | no |
| <a name="input_private_subnet_suffix"></a> [private\_subnet\_suffix](#input\_private\_subnet\_suffix) | Suffix to append to private subnets name | `string` | `"private"` | no |
| <a name="input_private_subnet_tags"></a> [private\_subnet\_tags](#input\_private\_subnet\_tags) | Additional tags for the private subnets | `map(string)` | `{}` | no |
| <a name="input_private_subnet_tags_per_az"></a> [private\_subnet\_tags\_per\_az](#input\_private\_subnet\_tags\_per\_az) | Additional tags for the private subnets where the primary key is the AZ | `map(map(string))` | `{}` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_propagate_intra_route_tables_vgw"></a> [propagate\_intra\_route\_tables\_vgw](#input\_propagate\_intra\_route\_tables\_vgw) | Should be true if you want route table propagation | `bool` | `false` | no |
| <a name="input_propagate_private_route_tables_vgw"></a> [propagate\_private\_route\_tables\_vgw](#input\_propagate\_private\_route\_tables\_vgw) | Should be true if you want route table propagation | `bool` | `false` | no |
| <a name="input_propagate_public_route_tables_vgw"></a> [propagate\_public\_route\_tables\_vgw](#input\_propagate\_public\_route\_tables\_vgw) | Should be true if you want route table propagation | `bool` | `false` | no |
| <a name="input_public_acl_tags"></a> [public\_acl\_tags](#input\_public\_acl\_tags) | Additional tags for the public subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_public_dedicated_network_acl"></a> [public\_dedicated\_network\_acl](#input\_public\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for public subnets | `bool` | `false` | no |
| <a name="input_public_inbound_acl_rules"></a> [public\_inbound\_acl\_rules](#input\_public\_inbound\_acl\_rules) | Public subnets inbound network ACLs | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_public_outbound_acl_rules"></a> [public\_outbound\_acl\_rules](#input\_public\_outbound\_acl\_rules) | Public subnets outbound network ACLs | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_public_route_table_tags"></a> [public\_route\_table\_tags](#input\_public\_route\_table\_tags) | Additional tags for the public route tables | `map(string)` | `{}` | no |
| <a name="input_public_subnet_assign_ipv6_address_on_creation"></a> [public\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_public\_subnet\_assign\_ipv6\_address\_on\_creation) | Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false` | `bool` | `false` | no |
| <a name="input_public_subnet_enable_dns64"></a> [public\_subnet\_enable\_dns64](#input\_public\_subnet\_enable\_dns64) | Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true` | `bool` | `true` | no |
| <a name="input_public_subnet_enable_resource_name_dns_a_record_on_launch"></a> [public\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch](#input\_public\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false` | `bool` | `false` | no |
| <a name="input_public_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [public\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch](#input\_public\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true` | `bool` | `true` | no |
| <a name="input_public_subnet_ipv6_native"></a> [public\_subnet\_ipv6\_native](#input\_public\_subnet\_ipv6\_native) | Indicates whether to create an IPv6-only subnet. Default: `false` | `bool` | `false` | no |
| <a name="input_public_subnet_ipv6_prefixes"></a> [public\_subnet\_ipv6\_prefixes](#input\_public\_subnet\_ipv6\_prefixes) | Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_public_subnet_names"></a> [public\_subnet\_names](#input\_public\_subnet\_names) | Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated | `list(string)` | `[]` | no |
| <a name="input_public_subnet_private_dns_hostname_type_on_launch"></a> [public\_subnet\_private\_dns\_hostname\_type\_on\_launch](#input\_public\_subnet\_private\_dns\_hostname\_type\_on\_launch) | The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name` | `string` | `null` | no |
| <a name="input_public_subnet_suffix"></a> [public\_subnet\_suffix](#input\_public\_subnet\_suffix) | Suffix to append to public subnets name | `string` | `"public"` | no |
| <a name="input_public_subnet_tags"></a> [public\_subnet\_tags](#input\_public\_subnet\_tags) | Additional tags for the public subnets | `map(string)` | `{}` | no |
| <a name="input_public_subnet_tags_per_az"></a> [public\_subnet\_tags\_per\_az](#input\_public\_subnet\_tags\_per\_az) | Additional tags for the public subnets where the primary key is the AZ | `map(map(string))` | `{}` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_putin_khuylo"></a> [putin\_khuylo](#input\_putin\_khuylo) | Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo! | `bool` | `true` | no |
| <a name="input_redshift_acl_tags"></a> [redshift\_acl\_tags](#input\_redshift\_acl\_tags) | Additional tags for the redshift subnets network ACL | `map(string)` | `{}` | no |
| <a name="input_redshift_dedicated_network_acl"></a> [redshift\_dedicated\_network\_acl](#input\_redshift\_dedicated\_network\_acl) | Whether to use dedicated network ACL (not default) and custom rules for redshift subnets | `bool` | `false` | no |
| <a name="input_redshift_inbound_acl_rules"></a> [redshift\_inbound\_acl\_rules](#input\_redshift\_inbound\_acl\_rules) | Redshift subnets inbound network ACL rules | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_redshift_outbound_acl_rules"></a> [redshift\_outbound\_acl\_rules](#input\_redshift\_outbound\_acl\_rules) | Redshift subnets outbound network ACL rules | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "from_port": 0,<br/>    "protocol": "-1",<br/>    "rule_action": "allow",<br/>    "rule_number": 100,<br/>    "to_port": 0<br/>  }<br/>]</pre> | no |
| <a name="input_redshift_route_table_tags"></a> [redshift\_route\_table\_tags](#input\_redshift\_route\_table\_tags) | Additional tags for the redshift route tables | `map(string)` | `{}` | no |
| <a name="input_redshift_subnet_assign_ipv6_address_on_creation"></a> [redshift\_subnet\_assign\_ipv6\_address\_on\_creation](#input\_redshift\_subnet\_assign\_ipv6\_address\_on\_creation) | Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false` | `bool` | `false` | no |
| <a name="input_redshift_subnet_enable_dns64"></a> [redshift\_subnet\_enable\_dns64](#input\_redshift\_subnet\_enable\_dns64) | Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true` | `bool` | `true` | no |
| <a name="input_redshift_subnet_enable_resource_name_dns_a_record_on_launch"></a> [redshift\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch](#input\_redshift\_subnet\_enable\_resource\_name\_dns\_a\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false` | `bool` | `false` | no |
| <a name="input_redshift_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [redshift\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch](#input\_redshift\_subnet\_enable\_resource\_name\_dns\_aaaa\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true` | `bool` | `true` | no |
| <a name="input_redshift_subnet_group_name"></a> [redshift\_subnet\_group\_name](#input\_redshift\_subnet\_group\_name) | Name of redshift subnet group | `string` | `null` | no |
| <a name="input_redshift_subnet_group_tags"></a> [redshift\_subnet\_group\_tags](#input\_redshift\_subnet\_group\_tags) | Additional tags for the redshift subnet group | `map(string)` | `{}` | no |
| <a name="input_redshift_subnet_ipv6_native"></a> [redshift\_subnet\_ipv6\_native](#input\_redshift\_subnet\_ipv6\_native) | Indicates whether to create an IPv6-only subnet. Default: `false` | `bool` | `false` | no |
| <a name="input_redshift_subnet_ipv6_prefixes"></a> [redshift\_subnet\_ipv6\_prefixes](#input\_redshift\_subnet\_ipv6\_prefixes) | Assigns IPv6 redshift subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list | `list(string)` | `[]` | no |
| <a name="input_redshift_subnet_names"></a> [redshift\_subnet\_names](#input\_redshift\_subnet\_names) | Explicit values to use in the Name tag on redshift subnets. If empty, Name tags are generated | `list(string)` | `[]` | no |
| <a name="input_redshift_subnet_private_dns_hostname_type_on_launch"></a> [redshift\_subnet\_private\_dns\_hostname\_type\_on\_launch](#input\_redshift\_subnet\_private\_dns\_hostname\_type\_on\_launch) | The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name` | `string` | `null` | no |
| <a name="input_redshift_subnet_suffix"></a> [redshift\_subnet\_suffix](#input\_redshift\_subnet\_suffix) | Suffix to append to redshift subnets name | `string` | `"redshift"` | no |
| <a name="input_redshift_subnet_tags"></a> [redshift\_subnet\_tags](#input\_redshift\_subnet\_tags) | Additional tags for the redshift subnets | `map(string)` | `{}` | no |
| <a name="input_redshift_subnets"></a> [redshift\_subnets](#input\_redshift\_subnets) | A list of redshift subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_reuse_nat_ips"></a> [reuse\_nat\_ips](#input\_reuse\_nat\_ips) | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external\_nat\_ip\_ids' variable | `bool` | `false` | no |
| <a name="input_secondary_cidr_blocks"></a> [secondary\_cidr\_blocks](#input\_secondary\_cidr\_blocks) | List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool | `list(string)` | `[]` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_use_ipam_pool"></a> [use\_ipam\_pool](#input\_use\_ipam\_pool) | Determines whether IPAM pool is used for CIDR allocation | `bool` | `false` | no |
| <a name="input_vpc_flow_log_iam_policy_name"></a> [vpc\_flow\_log\_iam\_policy\_name](#input\_vpc\_flow\_log\_iam\_policy\_name) | Name of the IAM policy | `string` | `"vpc-flow-log-to-cloudwatch"` | no |
| <a name="input_vpc_flow_log_iam_policy_use_name_prefix"></a> [vpc\_flow\_log\_iam\_policy\_use\_name\_prefix](#input\_vpc\_flow\_log\_iam\_policy\_use\_name\_prefix) | Determines whether the name of the IAM policy (`vpc_flow_log_iam_policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_vpc_flow_log_iam_role_name"></a> [vpc\_flow\_log\_iam\_role\_name](#input\_vpc\_flow\_log\_iam\_role\_name) | Name to use on the VPC Flow Log IAM role created | `string` | `"vpc-flow-log-role"` | no |
| <a name="input_vpc_flow_log_iam_role_use_name_prefix"></a> [vpc\_flow\_log\_iam\_role\_use\_name\_prefix](#input\_vpc\_flow\_log\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`vpc_flow_log_iam_role_name_name`) is used as a prefix | `bool` | `true` | no |
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
| <a name="output_database_internet_gateway_route_id"></a> [database\_internet\_gateway\_route\_id](#output\_database\_internet\_gateway\_route\_id) | ID of the database internet gateway route |
| <a name="output_database_ipv6_egress_route_id"></a> [database\_ipv6\_egress\_route\_id](#output\_database\_ipv6\_egress\_route\_id) | ID of the database IPv6 egress route |
| <a name="output_database_nat_gateway_route_ids"></a> [database\_nat\_gateway\_route\_ids](#output\_database\_nat\_gateway\_route\_ids) | List of IDs of the database nat gateway route |
| <a name="output_database_network_acl_arn"></a> [database\_network\_acl\_arn](#output\_database\_network\_acl\_arn) | ARN of the database network ACL |
| <a name="output_database_network_acl_id"></a> [database\_network\_acl\_id](#output\_database\_network\_acl\_id) | ID of the database network ACL |
| <a name="output_database_route_table_association_ids"></a> [database\_route\_table\_association\_ids](#output\_database\_route\_table\_association\_ids) | List of IDs of the database route table association |
| <a name="output_database_route_table_ids"></a> [database\_route\_table\_ids](#output\_database\_route\_table\_ids) | List of IDs of database route tables |
| <a name="output_database_subnet_arns"></a> [database\_subnet\_arns](#output\_database\_subnet\_arns) | List of ARNs of database subnets |
| <a name="output_database_subnet_group"></a> [database\_subnet\_group](#output\_database\_subnet\_group) | ID of database subnet group |
| <a name="output_database_subnet_group_name"></a> [database\_subnet\_group\_name](#output\_database\_subnet\_group\_name) | Name of database subnet group |
| <a name="output_database_subnet_objects"></a> [database\_subnet\_objects](#output\_database\_subnet\_objects) | A list of all database subnets, containing the full objects. |
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
| <a name="output_elasticache_subnet_objects"></a> [elasticache\_subnet\_objects](#output\_elasticache\_subnet\_objects) | A list of all elasticache subnets, containing the full objects. |
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
| <a name="output_intra_subnet_objects"></a> [intra\_subnet\_objects](#output\_intra\_subnet\_objects) | A list of all intra subnets, containing the full objects. |
| <a name="output_intra_subnets"></a> [intra\_subnets](#output\_intra\_subnets) | List of IDs of intra subnets |
| <a name="output_intra_subnets_cidr_blocks"></a> [intra\_subnets\_cidr\_blocks](#output\_intra\_subnets\_cidr\_blocks) | List of cidr\_blocks of intra subnets |
| <a name="output_intra_subnets_ipv6_cidr_blocks"></a> [intra\_subnets\_ipv6\_cidr\_blocks](#output\_intra\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of intra subnets in an IPv6 enabled VPC |
| <a name="output_name"></a> [name](#output\_name) | The name of the VPC specified as argument to this module |
| <a name="output_nat_ids"></a> [nat\_ids](#output\_nat\_ids) | List of allocation ID of Elastic IPs created for AWS NAT Gateway |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | List of public Elastic IPs created for AWS NAT Gateway |
| <a name="output_natgw_ids"></a> [natgw\_ids](#output\_natgw\_ids) | List of NAT Gateway IDs |
| <a name="output_natgw_interface_ids"></a> [natgw\_interface\_ids](#output\_natgw\_interface\_ids) | List of Network Interface IDs assigned to NAT Gateways |
| <a name="output_outpost_network_acl_arn"></a> [outpost\_network\_acl\_arn](#output\_outpost\_network\_acl\_arn) | ARN of the outpost network ACL |
| <a name="output_outpost_network_acl_id"></a> [outpost\_network\_acl\_id](#output\_outpost\_network\_acl\_id) | ID of the outpost network ACL |
| <a name="output_outpost_subnet_arns"></a> [outpost\_subnet\_arns](#output\_outpost\_subnet\_arns) | List of ARNs of outpost subnets |
| <a name="output_outpost_subnet_objects"></a> [outpost\_subnet\_objects](#output\_outpost\_subnet\_objects) | A list of all outpost subnets, containing the full objects. |
| <a name="output_outpost_subnets"></a> [outpost\_subnets](#output\_outpost\_subnets) | List of IDs of outpost subnets |
| <a name="output_outpost_subnets_cidr_blocks"></a> [outpost\_subnets\_cidr\_blocks](#output\_outpost\_subnets\_cidr\_blocks) | List of cidr\_blocks of outpost subnets |
| <a name="output_outpost_subnets_ipv6_cidr_blocks"></a> [outpost\_subnets\_ipv6\_cidr\_blocks](#output\_outpost\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of outpost subnets in an IPv6 enabled VPC |
| <a name="output_private_ipv6_egress_route_ids"></a> [private\_ipv6\_egress\_route\_ids](#output\_private\_ipv6\_egress\_route\_ids) | List of IDs of the ipv6 egress route |
| <a name="output_private_nat_gateway_route_ids"></a> [private\_nat\_gateway\_route\_ids](#output\_private\_nat\_gateway\_route\_ids) | List of IDs of the private nat gateway route |
| <a name="output_private_network_acl_arn"></a> [private\_network\_acl\_arn](#output\_private\_network\_acl\_arn) | ARN of the private network ACL |
| <a name="output_private_network_acl_id"></a> [private\_network\_acl\_id](#output\_private\_network\_acl\_id) | ID of the private network ACL |
| <a name="output_private_route_table_association_ids"></a> [private\_route\_table\_association\_ids](#output\_private\_route\_table\_association\_ids) | List of IDs of the private route table association |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | List of IDs of private route tables |
| <a name="output_private_subnet_arns"></a> [private\_subnet\_arns](#output\_private\_subnet\_arns) | List of ARNs of private subnets |
| <a name="output_private_subnet_objects"></a> [private\_subnet\_objects](#output\_private\_subnet\_objects) | A list of all private subnets, containing the full objects. |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of IDs of private subnets |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | List of cidr\_blocks of private subnets |
| <a name="output_private_subnets_ipv6_cidr_blocks"></a> [private\_subnets\_ipv6\_cidr\_blocks](#output\_private\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of private subnets in an IPv6 enabled VPC |
| <a name="output_public_internet_gateway_ipv6_route_id"></a> [public\_internet\_gateway\_ipv6\_route\_id](#output\_public\_internet\_gateway\_ipv6\_route\_id) | ID of the IPv6 internet gateway route |
| <a name="output_public_internet_gateway_route_id"></a> [public\_internet\_gateway\_route\_id](#output\_public\_internet\_gateway\_route\_id) | ID of the internet gateway route |
| <a name="output_public_network_acl_arn"></a> [public\_network\_acl\_arn](#output\_public\_network\_acl\_arn) | ARN of the public network ACL |
| <a name="output_public_network_acl_id"></a> [public\_network\_acl\_id](#output\_public\_network\_acl\_id) | ID of the public network ACL |
| <a name="output_public_route_table_association_ids"></a> [public\_route\_table\_association\_ids](#output\_public\_route\_table\_association\_ids) | List of IDs of the public route table association |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | List of IDs of public route tables |
| <a name="output_public_subnet_arns"></a> [public\_subnet\_arns](#output\_public\_subnet\_arns) | List of ARNs of public subnets |
| <a name="output_public_subnet_objects"></a> [public\_subnet\_objects](#output\_public\_subnet\_objects) | A list of all public subnets, containing the full objects. |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of IDs of public subnets |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | List of cidr\_blocks of public subnets |
| <a name="output_public_subnets_ipv6_cidr_blocks"></a> [public\_subnets\_ipv6\_cidr\_blocks](#output\_public\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 cidr\_blocks of public subnets in an IPv6 enabled VPC |
| <a name="output_redshift_network_acl_arn"></a> [redshift\_network\_acl\_arn](#output\_redshift\_network\_acl\_arn) | ARN of the redshift network ACL |
| <a name="output_redshift_network_acl_id"></a> [redshift\_network\_acl\_id](#output\_redshift\_network\_acl\_id) | ID of the redshift network ACL |
| <a name="output_redshift_public_route_table_association_ids"></a> [redshift\_public\_route\_table\_association\_ids](#output\_redshift\_public\_route\_table\_association\_ids) | List of IDs of the public redshift route table association |
| <a name="output_redshift_route_table_association_ids"></a> [redshift\_route\_table\_association\_ids](#output\_redshift\_route\_table\_association\_ids) | List of IDs of the redshift route table association |
| <a name="output_redshift_route_table_ids"></a> [redshift\_route\_table\_ids](#output\_redshift\_route\_table\_ids) | List of IDs of redshift route tables |
| <a name="output_redshift_subnet_arns"></a> [redshift\_subnet\_arns](#output\_redshift\_subnet\_arns) | List of ARNs of redshift subnets |
| <a name="output_redshift_subnet_group"></a> [redshift\_subnet\_group](#output\_redshift\_subnet\_group) | ID of redshift subnet group |
| <a name="output_redshift_subnet_objects"></a> [redshift\_subnet\_objects](#output\_redshift\_subnet\_objects) | A list of all redshift subnets, containing the full objects. |
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
| <a name="output_vpc_flow_log_deliver_cross_account_role"></a> [vpc\_flow\_log\_deliver\_cross\_account\_role](#output\_vpc\_flow\_log\_deliver\_cross\_account\_role) | The ARN of the IAM role used when pushing logs cross account |
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
<!-- END_TF_DOCS -->

output-values:
  enabled: false
  from: ""

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

## Content Template

Generated content can be customized further away with `content` in configuration.
If the `content` is empty the default order of sections is used.

Compatible formatters for customized content are `asciidoc` and `markdown`. `content`
will be ignored for other formatters.

`content` is a Go template with following additional variables:

- `{{ .Header }}`
- `{{ .Footer }}`
- `{{ .Inputs }}`
- `{{ .Modules }}`
- `{{ .Outputs }}`
- `{{ .Providers }}`
- `{{ .Requirements }}`
- `{{ .Resources }}`

and following functions:

- `{{ include "relative/path/to/file" }}`

These variables are the generated output of individual sections in the selected
formatter. For example `{{ .Inputs }}` is Markdown Table representation of _inputs_
when formatter is set to `markdown table`.

Note that sections visibility (i.e. `sections.show` and `sections.hide`) takes
precedence over the `content`.

Additionally there's also one extra special variable avaialble to the `content`:

- `{{ .Module }}`

As opposed to the other variables mentioned above, which are generated sections
based on a selected formatter, the `{{ .Module }}` variable is just a `struct`
representing a [Terraform module].

````yaml
content: |-
  Any arbitrary text can be placed anywhere in the content

  {{ .Header }}

  and even in between sections

  {{ .Providers }}

  and they don't even need to be in the default order

  {{ .Outputs }}

  include any relative files

  {{ include "relative/path/to/file" }}

  {{ .Inputs }}

  # Examples

  ```hcl
  {{ include "examples/foo/main.tf" }}
  ```

  ## Resources

  {{ range .Module.Resources }}
  - {{ .GetMode }}.{{ .Spec }} ({{ .Position.Filename }}#{{ .Position.Line }})
  {{- end }}
````

## Build on top of terraform-docs

terraform-docs primary use-case is to be utilized as a standalone binary, but
some parts of it is also available publicly and can be imported in your project
as a library.

```go
import (
    "github.com/terraform-docs/terraform-docs/format"
    "github.com/terraform-docs/terraform-docs/print"
    "github.com/terraform-docs/terraform-docs/terraform"
)

// buildTerraformDocs for module root `path` and provided content `tmpl`.
func buildTerraformDocs(path string, tmpl string) (string, error) {
    config := print.DefaultConfig()
    config.ModuleRoot = path // module root path (can be relative or absolute)

    module, err := terraform.LoadWithOptions(config)
    if err != nil {
        return "", err
    }

    // Generate in Markdown Table format
    formatter := format.NewMarkdownTable(config)

    if err := formatter.Generate(module); err != nil {
        return "", err
    }

    // // Note: if you don't intend to provide additional template for the generated
    // // content, or the target format doesn't provide templating (e.g. json, yaml,
    // // xml, or toml) you can use `Content()` function instead of `Render()`.
    // // `Content()` returns all the sections combined with predefined order.
    // return formatter.Content(), nil

    return formatter.Render(tmpl)
}
```

## Plugin

Generated output can be heavily customized with [`content`], but if using that
is not enough for your use-case, you can write your own plugin.

In order to install a plugin the following steps are needed:

- download the plugin and place it in `~/.tfdocs.d/plugins` (or `./.tfdocs.d/plugins`)
- make sure the plugin file name is `tfdocs-format-<NAME>`
- modify [`formatter`] of `.terraform-docs.yml` file to be `<NAME>`

**Important notes:**

- if the plugin file name is different than the example above, terraform-docs won't
be able to to pick it up nor register it properly
- you can only use plugin thorough `.terraform-docs.yml` file and it cannot be used
with CLI arguments

To create a new plugin create a new repository called `tfdocs-format-<NAME>` with
following `main.go`:

```go
package main

import (
    _ "embed" //nolint

    "github.com/terraform-docs/terraform-docs/plugin"
    "github.com/terraform-docs/terraform-docs/print"
    "github.com/terraform-docs/terraform-docs/template"
    "github.com/terraform-docs/terraform-docs/terraform"
)

func main() {
    plugin.Serve(&plugin.ServeOpts{
        Name:    "<NAME>",
        Version: "0.1.0",
        Printer: printerFunc,
    })
}

//go:embed sections.tmpl
var tplCustom []byte

// printerFunc the function being executed by the plugin client.
func printerFunc(config *print.Config, module *terraform.Module) (string, error) {
    tpl := template.New(config,
        &template.Item{Name: "custom", Text: string(tplCustom)},
    )

    rendered, err := tpl.Render("custom", module)
    if err != nil {
        return "", err
    }

    return rendered, nil
}
```

Please refer to [tfdocs-format-template] for more details. You can create a new
repository from it by clicking on `Use this template` button.

## Documentation

- **Users**
  - Read the [User Guide] to learn how to use terraform-docs
  - Read the [Formats Guide] to learn about different output formats of terraform-docs
  - Refer to [Config File Reference] for all the available configuration options
- **Developers**
  - Read [Contributing Guide] before submitting a pull request

Visit [our website] for all documentation.

## Community

- Discuss terraform-docs on [Slack]

## License

MIT License - Copyright (c) 2021 The terraform-docs Authors.

[Chocolatey]: https://www.chocolatey.org
[Config File Reference]: https://terraform-docs.io/user-guide/configuration/
[`content`]: https://terraform-docs.io/user-guide/configuration/content/
[Contributing Guide]: CONTRIBUTING.md
[Formats Guide]: https://terraform-docs.io/reference/terraform-docs/
[`formatter`]: https://terraform-docs.io/user-guide/configuration/formatter/
[here]: https://golang.org/doc/code.html#GOPATH
[Homebrew]: https://brew.sh
[install pre-commit]: https://pre-commit.com/#install
[`output`]: https://terraform-docs.io/user-guide/configuration/output/
[releases]: https://github.com/terraform-docs/terraform-docs/releases
[Scoop]: https://scoop.sh/
[Slack]: https://slack.terraform-docs.io/
[terraform-docs GitHub Action]: https://github.com/terraform-docs/gh-actions
[Terraform module]: https://pkg.go.dev/github.com/terraform-docs/terraform-docs/terraform#Module
[tfdocs-format-template]: https://github.com/terraform-docs/tfdocs-format-template
[our website]: https://terraform-docs.io/
[User Guide]: https://terraform-docs.io/user-guide/introduction/
