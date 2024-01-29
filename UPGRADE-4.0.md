# Upgrade from v3.x to v4.x

If you have any questions regarding this upgrade process, please consult the [`examples`](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/) directory:

If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- The minimum required Terraform version is now 1.0
- The minimum required AWS provider version is now 4.x (4.35.0 at time of writing)
- `assign_ipv6_address_on_creation` has been removed; use the respective subnet type equivalent instead (i.e. - `public_subnet_assign_ipv6_address_on_creation`)
- `enable_classiclink` has been removed; it is no longer supported by AWS https://github.com/hashicorp/terraform/issues/31730
- `enable_classiclink_dns_support` has been removed; it is no longer supported by AWS https://github.com/hashicorp/terraform/issues/31730

## Additional changes

### Modified

- `map_public_ip_on_launch` now defaults to `false`
- `enable_dns_hostnames` now defaults to `true`
- `enable_dns_support` now defaults to `true`
- `manage_default_security_group` now defaults to `true`
- `manage_default_route_table` now defaults to `true`
- `manage_default_network_acl` now defaults to `true`
- The default name for the default security group, route table, and network ACL has changed to fallback to append `-default` to the VPC name if a specific name is not provided
- The default fallback value for outputs has changed from an empty string to `null`

### Variable and output changes

1. Removed variables:

    - `assign_ipv6_address_on_creation` has been removed; use the respective subnet type equivalent instead (i.e. - `public_subnet_assign_ipv6_address_on_creation`)
    - `enable_classiclink` has been removed; it is no longer supported by AWS https://github.com/hashicorp/terraform/issues/31730
    - `enable_classiclink_dns_support` has been removed; it is no longer supported by AWS https://github.com/hashicorp/terraform/issues/31730

2. Renamed variables:

    - None

3. Added variables:

    - VPC
      - `ipv6_cidr_block_network_border_group`
      - `enable_network_address_usage_metrics`
    - Subnets
      - `*_subnet_enable_dns64` for each subnet type
      - `*_subnet_enable_resource_name_dns_aaaa_record_on_launch` for each subnet type
      - `*_subnet_enable_resource_name_dns_a_record_on_launch` for each subnet type
      - `*_subnet_ipv6_native` for each subnet type
      - `*_subnet_private_dns_hostname_type_on_launch` for each subnet type

4. Removed outputs:

    - None

5. Renamed outputs:

    - None

6. Added outputs:

    - None

### State Changes

None
