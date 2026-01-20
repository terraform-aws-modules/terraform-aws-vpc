# VPC with IPAM Pool for Subnet Planning

This example demonstrates how to:

1. Create a VPC with traditional CIDR-based subnets
2. Create an IPAM pool scoped to the VPC for resource planning (plan IP space within a VPC)
3. Share the IPAM pool via AWS RAM
4. Create subnets from the IPAM pool using the CLI workaround

## Overview

AWS VPC IP Address Manager (IPAM) allows you to plan, track, and monitor IP addresses for your AWS workloads. This example shows how to create a VPC-specific IPAM pool that can be used for subnet allocation.

### Architecture

```
Top-level IPAM (10.0.0.0/8)
    └── Top-level IPAM Pool
        └── VPC IPAM Pool (10.0.0.0/16) - Scoped to VPC
            ├── IPAM Subnet 1 (/28)
            ├── IPAM Subnet 2 (/28)
            └── IPAM Subnet 3 (/28)
```

## Workaround for Subnet Creation

The Terraform AWS Provider currently does not support creating subnets with `ipv4_ipam_pool_id`. This example uses a `null_resource` with `local-exec` provisioner to create subnets via AWS CLI as a workaround.

**Reference:** [Workaround for Unsupported Config in Terraform AWS Provider](https://kieranyio.medium.com/workaround-for-unsupported-config-in-terraform-aws-provider-31337208705f)

### How it works:

1. **VPC Creation**: Standard VPC is created with CIDR block
2. **IPAM Pool Creation**: A VPC-specific IPAM pool is created for subnet planning
3. **RAM Sharing**: The IPAM pool is shared via AWS RAM to specified principals
4. **Subnet Creation**: Subnets are created using AWS CLI via `null_resource`:
   ```bash
   aws ec2 create-subnet \
     --vpc-id 'vpc-xxx' \
     --ipv4-ipam-pool-id 'ipam-pool-xxx' \
     --ipv4-netmask-length '28' \
     --availability-zone 'eu-west-2a'
   ```

## Usage

To run this example:

```bash
terraform init
terraform plan
terraform apply
```

### With RAM Sharing

To share the IPAM pool with other AWS accounts:

```bash
terraform apply -var='ram_share_principals=["123456789012", "987654321098"]'
```

Or with an Organization/OU:

```bash
terraform apply -var='ram_share_principals=["arn:aws:organizations::123456789012:organization/o-xxxxx"]'
```

## Requirements

- AWS CLI must be installed and configured
- Appropriate AWS credentials with permissions to:
  - Create VPC and subnets
  - Create IPAM resources
  - Create RAM shares
  - Use AWS CLI to create subnets

## Subnet Creation via CLI

The example creates subnets using the following command pattern:

```bash
aws ec2 create-subnet \
  --vpc-id 'vpc-050cd69cb278b47c3' \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=my-subnet}]' \
  --ipv4-ipam-pool-id 'ipam-pool-0dbc9eeb0ecd6148c' \
  --ipv4-netmask-length '28' \
  --availability-zone 'eu-west-2a'
```

## Limitations

1. **Terraform State**: Subnets created via `null_resource` are not fully managed by Terraform. The subnet IDs are retrieved via data sources.
2. **Drift Detection**: Changes made outside Terraform won't be detected automatically.
3. **Deletion**: Subnet deletion is handled via the `destroy` provisioner, but may fail if resources are still attached.

## Future Improvements

Once the Terraform AWS Provider adds native support for `ipv4_ipam_pool_id` in subnet resources, this workaround can be replaced with standard `aws_subnet` resources.

## Notes

- The VPC IPAM pool is scoped to the VPC, allowing for resource planning within the VPC
- RAM sharing enables cross-account subnet creation from the same IPAM pool
- Subnet CIDR blocks are automatically allocated from the IPAM pool based on the specified netmask length
- All subnets created from the IPAM pool are tracked and managed by IPAM

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 6.28 |
| null | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.28 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vpc | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_vpc_ipam.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam) | resource |
| [aws_vpc_ipam_pool.top_level](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool) | resource |
| [aws_vpc_ipam_pool_cidr.top_level](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool_cidr) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ram_share_principals | List of AWS account IDs or Organization/OU ARNs to share the IPAM pool with | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| ipam_subnets | Map of IPAM-created subnet IDs |
| ipam_subnets_availability_zones | Map of IPAM-created subnet availability zones |
| ipam_subnets_cidr_blocks | Map of IPAM-created subnet CIDR blocks |
| top_level_ipam_id | The ID of the top-level IPAM |
| top_level_ipam_pool_id | The ID of the top-level IPAM pool |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_id | The ID of the VPC |
| vpc_ipam_pool_arn | The ARN of the VPC IPAM pool |
| vpc_ipam_pool_cidr | The CIDR provisioned to the VPC IPAM pool |
| vpc_ipam_pool_id | The ID of the VPC IPAM pool for subnet allocation |
| vpc_ipam_pool_ram_share_arn | The ARN of the RAM resource share |
| vpc_ipam_pool_ram_share_id | The ID of the RAM resource share |
<!-- END_TF_DOCS -->
