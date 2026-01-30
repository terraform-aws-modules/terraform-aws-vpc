# Migration Guide: IPAM Modernization

This guide helps you migrate from the old IPAM implementation (using `null_resource` workarounds) to the new native Terraform AWS provider resources implementation.

## Overview

Version 6.x of this module modernizes the IPAM implementation by replacing `null_resource` workarounds with native Terraform AWS provider resources. This change provides:

- **Native Terraform State Management**: All IPAM resources are now managed through Terraform state
- **No AWS CLI Dependency**: The module no longer requires AWS CLI to be installed
- **Simplified Implementation**: Removed bash scripts and file-based state management
- **Better Error Handling**: Native AWS provider error messages and validation
- **Proper Resource Lifecycle**: Correct dependency management and drift detection

## Breaking Changes

### Provider Version Requirement

**Old**: AWS Provider >= 6.28.0  
**New**: AWS Provider >= 6.29.0

The new implementation requires AWS Provider version 6.29.0 or later for native support of:
- VPC-scoped IPAM pools (`aws_vpc_ipam_pool` with `source_resource` block)
- IPAM-allocated subnets (`aws_subnet` with `ipv4_ipam_pool_id` parameter)

### AWS CLI No Longer Required

**Old**: Required AWS CLI installed and configured  
**New**: No AWS CLI dependency

You can remove AWS CLI from your Terraform execution environment if it was only needed for this module.

### State Management Changes

**Old**: Used file-based state in `.terraform/` directory  
**New**: Uses native Terraform state

All IPAM resources are now tracked in Terraform state instead of files on disk.

## Migration Steps

### Step 1: Update Provider Version

Update your Terraform configuration to require AWS provider >= 6.29.0:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.29.0"
    }
  }
}
```

Run `terraform init -upgrade` to upgrade the provider.

### Step 2: Review Your Configuration

**Good News**: The module interface (variables and outputs) remains backward compatible. Your existing configuration should work without changes.

Review your current IPAM configuration:

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  # IPAM Pool Configuration
  create_vpc_ipam_pool    = true
  vpc_ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id
  vpc_ipam_pool_cidr      = "10.0.0.0/16"

  # Allocation Constraints
  vpc_ipam_pool_allocation_default_netmask_length = 28
  vpc_ipam_pool_allocation_min_netmask_length     = 28
  vpc_ipam_pool_allocation_max_netmask_length     = 24

  # RAM Sharing
  vpc_ipam_pool_ram_share_enabled    = true
  vpc_ipam_pool_ram_share_principals = ["123456789012"]

  # IPAM Subnets
  ipam_subnets = [
    {
      name              = "ipam-subnet-1"
      availability_zone = "eu-west-2a"
      netmask_length    = 28
    }
  ]
}
```

This configuration will continue to work with the new implementation.

### Step 3: Remove Deprecated Variables (Optional)

The following variables are deprecated and have no effect in the new implementation:

- `vpc_ipam_pool_aws_profile` - AWS CLI profile is no longer needed
- `vpc_aws_profile` - AWS CLI profile is no longer needed
- `vpc_ipam_pool_region` - Provider configuration handles region

You can safely remove these from your configuration, but they won't cause errors if left in place.

### Step 4: Plan the Migration

Run `terraform plan` to see what changes Terraform will make:

```bash
terraform plan
```

**Expected Changes**:

1. **IPAM Pool**: Replacement from `null_resource.vpc_ipam_pool` to `aws_vpc_ipam_pool.vpc`
2. **IPAM Pool CIDR**: New resource `aws_vpc_ipam_pool_cidr.vpc`
3. **RAM Share**: Replacement from `null_resource` to `aws_ram_resource_share.vpc_ipam_pool`
4. **RAM Associations**: New resources `aws_ram_resource_association` and `aws_ram_principal_association`
5. **Subnets**: Replacement from `null_resource.ipam_subnets` to `aws_subnet.ipam`

**Important**: Review the plan carefully. The resources will be replaced, which means:
- Old resources will be destroyed
- New resources will be created
- **Subnets will be recreated** - This will cause downtime for resources using those subnets

### Step 5: Apply the Migration

If you're comfortable with the plan, apply the changes:

```bash
terraform apply
```

**Warning**: This will recreate IPAM pools and subnets. Plan for downtime if you have resources using these subnets.

### Step 6: Verify the Migration

After applying, verify that:

1. IPAM pool is created and has the correct CIDR provisioned
2. RAM sharing is configured correctly (if enabled)
3. Subnets are created with the expected CIDR blocks
4. All outputs return the expected values

```bash
terraform output
```

### Step 7: Clean Up (Optional)

Remove AWS CLI from your Terraform execution environment if it was only needed for this module.

## Common Migration Scenarios

### Scenario 1: Simple IPAM Pool with Subnets

**Before** (using null_resource):
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Old version

  create_vpc_ipam_pool = true
  # ... other configuration
}
```

**After** (using native resources):
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"  # New version

  create_vpc_ipam_pool = true
  # ... same configuration, no changes needed
}
```

### Scenario 2: IPAM Pool with RAM Sharing

**Before**:
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  create_vpc_ipam_pool               = true
  vpc_ipam_pool_ram_share_enabled    = true
  vpc_ipam_pool_ram_share_principals = ["123456789012", "987654321098"]
  # ... other configuration
}
```

**After**:
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  create_vpc_ipam_pool               = true
  vpc_ipam_pool_ram_share_enabled    = true
  vpc_ipam_pool_ram_share_principals = ["123456789012", "987654321098"]
  # ... same configuration, no changes needed
}
```

### Scenario 3: Cross-Account IPAM

**Before**:
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  create_vpc_ipam_pool    = true
  vpc_ipam_pool_aws_profile = "account-a"  # DEPRECATED
  vpc_aws_profile           = "account-b"  # DEPRECATED
  # ... other configuration
}
```

**After**:
```hcl
# Use provider aliases instead of AWS CLI profiles
provider "aws" {
  alias  = "ipam_account"
  region = "us-east-1"
  # ... authentication configuration
}

provider "aws" {
  alias  = "vpc_account"
  region = "us-east-1"
  # ... authentication configuration
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  providers = {
    aws = aws.vpc_account
  }

  create_vpc_ipam_pool = true
  # Remove deprecated profile variables
  # ... other configuration
}
```

## Troubleshooting

### Issue: Provider version error

**Error**:
```
Error: Unsupported Terraform Core version
```

**Solution**: Upgrade your AWS provider to >= 6.29.0:
```bash
terraform init -upgrade
```

### Issue: Resource replacement causes downtime

**Problem**: Subnets are being recreated, causing downtime for resources.

**Solution**: Plan for a maintenance window. The subnet recreation is unavoidable when migrating from null_resource to native resources.

**Alternative**: If downtime is not acceptable, consider:
1. Creating new subnets with the native implementation
2. Migrating resources to the new subnets
3. Removing the old subnets

### Issue: State migration errors

**Error**:
```
Error: Resource already exists
```

**Solution**: This usually indicates a state conflict. Options:
1. Use `terraform state rm` to remove the old null_resource from state before applying
2. Use `terraform import` to import existing resources if they weren't properly tracked

### Issue: CIDR allocation conflicts

**Problem**: New subnets get different CIDR blocks than expected.

**Solution**: IPAM allocates CIDRs dynamically. If you need specific CIDRs:
1. Ensure your IPAM pool has the correct allocation constraints
2. Consider using explicit CIDR blocks instead of IPAM allocation for critical subnets

## Rollback Procedure

If you need to rollback to the old implementation:

1. **Downgrade the module version**:
   ```hcl
   module "vpc" {
     source = "terraform-aws-modules/vpc/aws"
     version = "~> 5.0"  # Previous version
     # ... configuration
   }
   ```

2. **Downgrade the provider** (if needed):
   ```hcl
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 6.28.0"
       }
     }
   }
   ```

3. **Run terraform init and apply**:
   ```bash
   terraform init -upgrade
   terraform apply
   ```

**Note**: Rollback will also cause resource recreation and downtime.

## Benefits of the New Implementation

After migration, you'll benefit from:

1. **Simplified Operations**: No need to manage AWS CLI credentials or profiles
2. **Better State Management**: All resources tracked in Terraform state
3. **Improved Error Messages**: Native AWS provider errors are more informative
4. **Drift Detection**: Terraform can detect and correct configuration drift
5. **Cleaner Code**: No bash scripts or workarounds in the module
6. **Better Testing**: Native resources are easier to test and validate

## Support

If you encounter issues during migration:

1. Check the [module documentation](./README.md)
2. Review the [IPAM subnet planning guide](./IPAM_SUBNET_PLANNING.md)
3. Open an issue on [GitHub](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues)

## Example: Complete Migration

Here's a complete example of migrating a VPC with IPAM:

**Before** (v5.x with null_resource):
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  create_vpc_ipam_pool    = true
  vpc_ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id
  vpc_ipam_pool_cidr      = "10.0.0.0/16"

  vpc_ipam_pool_allocation_default_netmask_length = 28
  vpc_ipam_pool_allocation_min_netmask_length     = 28
  vpc_ipam_pool_allocation_max_netmask_length     = 24

  vpc_ipam_pool_ram_share_enabled    = true
  vpc_ipam_pool_ram_share_principals = ["123456789012"]

  ipam_subnets = [
    {
      name              = "ipam-subnet-1"
      availability_zone = "eu-west-2a"
      netmask_length    = 28
    },
    {
      name              = "ipam-subnet-2"
      availability_zone = "eu-west-2b"
      netmask_length    = 28
    }
  ]
}
```

**After** (v6.x with native resources):
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.29.0"
    }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  # Same configuration - no changes needed!
  create_vpc_ipam_pool    = true
  vpc_ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id
  vpc_ipam_pool_cidr      = "10.0.0.0/16"

  vpc_ipam_pool_allocation_default_netmask_length = 28
  vpc_ipam_pool_allocation_min_netmask_length     = 28
  vpc_ipam_pool_allocation_max_netmask_length     = 24

  vpc_ipam_pool_ram_share_enabled    = true
  vpc_ipam_pool_ram_share_principals = ["123456789012"]

  ipam_subnets = [
    {
      name              = "ipam-subnet-1"
      availability_zone = "eu-west-2a"
      netmask_length    = 28
    },
    {
      name              = "ipam-subnet-2"
      availability_zone = "eu-west-2b"
      netmask_length    = 28
    }
  ]
}
```

**Migration commands**:
```bash
# 1. Update provider
terraform init -upgrade

# 2. Review changes
terraform plan

# 3. Apply migration (during maintenance window)
terraform apply

# 4. Verify outputs
terraform output
```

## Conclusion

The migration to native Terraform resources provides a more robust and maintainable IPAM implementation. While the migration requires resource recreation, the long-term benefits of simplified operations and better state management make it worthwhile.

Plan your migration during a maintenance window, review the plan carefully, and test in a non-production environment first.
