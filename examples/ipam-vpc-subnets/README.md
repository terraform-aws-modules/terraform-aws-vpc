# VPC with IPAM Pool for Subnet Planning

This example demonstrates how to use the modernized IPAM implementation with native Terraform resources:

1. Create a VPC with IPAM-allocated CIDR
2. Create a VPC-scoped IPAM pool using native `aws_vpc_ipam_pool` resource with `source_resource` block
3. Share the IPAM pool via AWS RAM using native `aws_ram_*` resources
4. Create subnets from the IPAM pool using native `aws_subnet` resources with `ipv4_ipam_pool_id`

## Overview

AWS VPC IP Address Manager (IPAM) allows you to plan, track, and monitor IP addresses for your AWS workloads. This example demonstrates the **native Terraform resource approach** introduced in AWS provider version 6.28.0+, which eliminates the need for AWS CLI workarounds.

### What's New in the Modernized Implementation

**Native Resources (AWS Provider >= 6.28.0):**
- ✅ `aws_vpc_ipam_pool` with `source_resource` block for VPC-scoped pools
- ✅ `aws_vpc_ipam_pool_cidr` for CIDR provisioning
- ✅ `aws_subnet` with `ipv4_ipam_pool_id` for IPAM-allocated subnets
- ✅ `aws_ram_resource_share`, `aws_ram_resource_association`, `aws_ram_principal_association` for sharing
- ✅ Full Terraform state management (no file-based state)
- ✅ No AWS CLI dependencies
- ✅ No `null_resource` workarounds

**Old Implementation (Deprecated):**
- ❌ `null_resource` with AWS CLI commands
- ❌ File-based state in `.terraform/` directory
- ❌ Required AWS CLI installation
- ❌ Manual resource lifecycle management

### Architecture

```
Top-level IPAM (10.0.0.0/8)
    └── Top-level IPAM Pool (10.0.0.0/8)
        └── VPC IPAM Pool (10.0.0.0/16) - VPC-scoped via source_resource block
            ├── Private Subnet 1 (10.0.1.0/24) - Auto-allocated
            ├── Private Subnet 2 (10.0.2.0/24) - Auto-allocated
            ├── Private Subnet 3 (10.0.3.0/24) - Auto-allocated
            ├── Public Subnet 1 (10.0.4.0/24) - Auto-allocated
            ├── Public Subnet 2 (10.0.5.0/24) - Auto-allocated
            └── Public Subnet 3 (10.0.6.0/24) - Auto-allocated
```

### How It Works

1. **VPC Creation**: VPC is created with CIDR allocated from the top-level IPAM pool
2. **VPC-Scoped IPAM Pool**: The module creates an `aws_vpc_ipam_pool` resource with a `source_resource` block that associates the pool with the VPC:
   ```hcl
   source_resource {
     resource_id     = vpc_id
     resource_owner  = account_id
     resource_region = region
     resource_type   = "vpc"
   }
   ```
3. **CIDR Provisioning**: The VPC's CIDR is provisioned to the pool using `aws_vpc_ipam_pool_cidr`
4. **RAM Sharing**: The pool is shared using native `aws_ram_resource_share` and association resources
5. **Subnet Creation**: Subnets are created using `aws_subnet` with `ipv4_ipam_pool_id` and `ipv4_netmask_length`:
   ```hcl
   resource "aws_subnet" "ipam" {
     vpc_id              = vpc_id
     ipv4_ipam_pool_id   = ipam_pool_id
     ipv4_netmask_length = 24
     availability_zone   = "us-east-1a"
   }
   ```

## Requirements

**Minimum Versions:**
- Terraform: >= 1.0
- AWS Provider: **>= 6.28.0** (required for native IPAM support)

**AWS Permissions:**
- Create VPC and subnets
- Create IPAM resources (`ec2:CreateIpamPool`, `ec2:ProvisionIpamPoolCidr`, etc.)
- Create RAM shares (`ram:CreateResourceShare`, `ram:AssociateResourceShare`, etc.)

**No AWS CLI Required** - All operations use native Terraform resources

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

## Migration from Old Implementation

If you're upgrading from the old `null_resource` implementation:

### Breaking Changes

1. **Provider Version**: Requires AWS provider >= 6.28.0
2. **State Migration**: Resources are now managed in Terraform state instead of files
3. **No AWS CLI**: AWS CLI is no longer required

### Migration Steps

1. **Upgrade Provider**: Update your `required_providers` block:
   ```hcl
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = ">= 6.28.0"
       }
     }
   }
   ```

2. **Update Module Version**: Update to the latest version of terraform-aws-vpc module

3. **Remove AWS CLI Dependencies**: Remove any AWS CLI installation or profile configuration

4. **Apply Changes**: Run `terraform init -upgrade` and `terraform apply`

### What Changed Internally

The module now uses:
- `aws_vpc_ipam_pool` instead of `null_resource` with AWS CLI for pool creation
- `aws_subnet` with `ipv4_ipam_pool_id` instead of `null_resource` with AWS CLI for subnet creation
- `aws_ram_resource_share` and related resources instead of `null_resource` with AWS CLI for sharing
- Native Terraform state instead of file-based state in `.terraform/` directory

## VPC-Scoped IPAM Pools Explained

A **VPC-scoped IPAM pool** is an IPAM pool that is associated with a specific VPC using the `source_resource` block. This allows you to:

- **Plan subnet allocations** within a VPC's CIDR range
- **Track IP usage** at the VPC level
- **Share the pool** across accounts for centralized IP management
- **Automatically allocate** subnet CIDRs without manual CIDR planning

The `source_resource` block tells IPAM that this pool is scoped to a specific VPC:
```hcl
source_resource {
  resource_id     = "vpc-abc123"           # VPC ID
  resource_owner  = "123456789012"         # AWS account ID
  resource_region = "us-east-1"            # VPC region
  resource_type   = "vpc"                  # Resource type
}
```

This is different from a top-level IPAM pool, which is not scoped to any specific resource and serves as a source for allocating CIDRs to VPCs or other pools.

## Cross-Region IPAM Setup

This example demonstrates a cross-region IPAM setup where:
- **IPAM resources** are created in `eu-west-1` (IPAM region)
- **VPC and subnets** are created in `eu-west-2` (VPC region)

This is a best practice for centralized IPAM management. The `locale` parameter on IPAM pools specifies where the pool operates (VPC region), while the provider determines where the IPAM resource is created.

## Notes

- All resources are managed through native Terraform state
- CIDR blocks are automatically allocated based on specified netmask lengths
- RAM sharing enables cross-account subnet creation from the same IPAM pool
- The VPC IPAM pool is scoped to the VPC using the `source_resource` block
- No manual CIDR planning required - IPAM handles allocation automatically

## Troubleshooting

### Provider Version Error

If you see an error about unsupported arguments:
```
Error: Unsupported argument: An argument named "source_resource" is not expected here
```

**Solution**: Upgrade your AWS provider to >= 6.28.0:
```bash
terraform init -upgrade
```

### CIDR Allocation Errors

If subnet creation fails with insufficient IP space:
```
Error: InsufficientFreeAddressesInSubnet
```

**Solution**: Either reduce the number of subnets, increase netmask length (smaller subnets), or provision more CIDR space to the IPAM pool.

### RAM Share Not Working

If cross-account subnet creation fails:
```
Error: UnauthorizedOperation: You are not authorized to use IPAM pool
```

**Solution**: Ensure the RAM share invitation is accepted in the target account and the account has the necessary permissions.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.28 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../.. | n/a |

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
| <a name="input_ram_share_principals"></a> [ram\_share\_principals](#input\_ram\_share\_principals) | List of AWS account IDs or Organization/OU ARNs to share the IPAM pool with | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ipam_subnets"></a> [ipam\_subnets](#output\_ipam\_subnets) | Map of IPAM-created subnet IDs (from aws\_subnet resources with ipv4\_ipam\_pool\_id) |
| <a name="output_ipam_subnets_availability_zones"></a> [ipam\_subnets\_availability\_zones](#output\_ipam\_subnets\_availability\_zones) | Map of IPAM-created subnet availability zones |
| <a name="output_ipam_subnets_cidr_blocks"></a> [ipam\_subnets\_cidr\_blocks](#output\_ipam\_subnets\_cidr\_blocks) | Map of IPAM-allocated subnet CIDR blocks (automatically allocated based on netmask\_length) |
| <a name="output_top_level_ipam_id"></a> [top\_level\_ipam\_id](#output\_top\_level\_ipam\_id) | The ID of the top-level IPAM instance |
| <a name="output_top_level_ipam_pool_id"></a> [top\_level\_ipam\_pool\_id](#output\_top\_level\_ipam\_pool\_id) | The ID of the top-level IPAM pool (source pool for VPC-scoped pools) |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC (allocated from top-level IPAM pool) |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_ipam_pool_arn"></a> [vpc\_ipam\_pool\_arn](#output\_vpc\_ipam\_pool\_arn) | The ARN of the VPC-scoped IPAM pool (from aws\_vpc\_ipam\_pool resource) |
| <a name="output_vpc_ipam_pool_cidr"></a> [vpc\_ipam\_pool\_cidr](#output\_vpc\_ipam\_pool\_cidr) | The CIDR provisioned to the VPC IPAM pool (from aws\_vpc\_ipam\_pool\_cidr resource) |
| <a name="output_vpc_ipam_pool_id"></a> [vpc\_ipam\_pool\_id](#output\_vpc\_ipam\_pool\_id) | The ID of the VPC-scoped IPAM pool for subnet allocation (from aws\_vpc\_ipam\_pool resource) |
| <a name="output_vpc_ipam_pool_ram_share_arn"></a> [vpc\_ipam\_pool\_ram\_share\_arn](#output\_vpc\_ipam\_pool\_ram\_share\_arn) | The ARN of the RAM resource share (from aws\_ram\_resource\_share resource) |
| <a name="output_vpc_ipam_pool_ram_share_id"></a> [vpc\_ipam\_pool\_ram\_share\_id](#output\_vpc\_ipam\_pool\_ram\_share\_id) | The ID of the RAM resource share (from aws\_ram\_resource\_share resource) |
<!-- END_TF_DOCS -->
