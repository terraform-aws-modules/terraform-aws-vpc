# AWS VPC IPAM Pool for Subnet Planning

This document explains the implementation of IPAM pool-based subnet creation within a VPC.

## Overview

AWS VPC IP Address Manager (IPAM) enables you to plan, track, and monitor IP addresses for your AWS workloads. This module now supports creating a VPC-specific IPAM pool for resource planning (planning IP space within a VPC) and creating subnets from that pool.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Top-level IPAM (Organization/Account Level)                 │
│   └── Top-level IPAM Pool (e.g., 10.0.0.0/8)               │
│       └── VPC IPAM Pool (e.g., 10.0.0.0/16)                │
│           ├── Subnet 1 (auto-allocated /28)                 │
│           ├── Subnet 2 (auto-allocated /28)                 │
│           └── Subnet 3 (auto-allocated /28)                 │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
                  ┌───────────────┐
                  │   RAM Share   │
                  │  (Optional)   │
                  └───────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  Shared Accounts      │
              │  Can create subnets   │
              │  from the pool        │
              └───────────────────────┘
```

## Implementation Details

### 1. VPC IPAM Pool Creation

The module creates an IPAM pool scoped to the VPC for subnet allocation:

```hcl
resource "aws_vpc_ipam_pool" "vpc_subnets" {
  description    = "IPAM pool for VPC subnets"
  address_family = "ipv4"
  ipam_scope_id  = var.vpc_ipam_scope_id
  locale         = var.vpc_ipam_pool_locale

  source_ipam_pool_id = var.vpc_ipam_source_pool_id

  allocation_default_netmask_length = var.vpc_ipam_pool_allocation_default_netmask_length
  allocation_max_netmask_length     = var.vpc_ipam_pool_allocation_max_netmask_length
  allocation_min_netmask_length     = var.vpc_ipam_pool_allocation_min_netmask_length
}
```

### 2. RAM Sharing

The IPAM pool can be shared with other AWS accounts via AWS Resource Access Manager (RAM):

```hcl
resource "aws_ram_resource_share" "vpc_ipam_pool" {
  name                      = "ipam-pool-share"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "vpc_ipam_pool" {
  resource_arn       = aws_vpc_ipam_pool.vpc_subnets.arn
  resource_share_arn = aws_ram_resource_share.vpc_ipam_pool.arn
}

resource "aws_ram_principal_association" "vpc_ipam_pool" {
  for_each = toset(var.vpc_ipam_pool_ram_share_principals)

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.vpc_ipam_pool.arn
}
```

### 3. Subnet Creation Workaround

**Current Limitation**: The Terraform AWS Provider does not yet support the `ipv4_ipam_pool_id` parameter for subnet resources.

**Workaround**: Use `null_resource` with `local-exec` provisioner to create subnets via AWS CLI:

```hcl
resource "null_resource" "ipam_subnets" {
  for_each = { for idx, subnet in var.ipam_subnets : idx => subnet }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      aws ec2 create-subnet \
        --vpc-id '${local.vpc_id}' \
        --availability-zone '${each.value.availability_zone}' \
        --ipv4-ipam-pool-id '${aws_vpc_ipam_pool.vpc_subnets.id}' \
        --ipv4-netmask-length '${each.value.netmask_length}' \
        --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=${each.value.name}}]'
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws ec2 delete-subnet --subnet-id '${self.triggers.subnet_id}'"
  }
}
```

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Enable VPC IPAM Pool
  create_vpc_ipam_pool = true
  vpc_ipam_scope_id    = aws_vpc_ipam.main.private_default_scope_id
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id
  vpc_ipam_pool_cidr   = "10.0.0.0/16"

  # Configure allocation constraints
  vpc_ipam_pool_allocation_default_netmask_length = 28
  vpc_ipam_pool_allocation_min_netmask_length     = 28
  vpc_ipam_pool_allocation_max_netmask_length     = 24

  # Create subnets from IPAM pool
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

### With RAM Sharing

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # ... VPC configuration ...

  # Enable VPC IPAM Pool
  create_vpc_ipam_pool = true
  vpc_ipam_scope_id    = aws_vpc_ipam.main.private_default_scope_id
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id
  vpc_ipam_pool_cidr   = "10.0.0.0/16"

  # Enable RAM sharing
  vpc_ipam_pool_ram_share_enabled    = true
  vpc_ipam_pool_ram_share_principals = [
    "123456789012",  # AWS Account ID
    "arn:aws:organizations::123456789012:organization/o-xxxxx"  # Organization
  ]

  # Create subnets from IPAM pool
  ipam_subnets = [
    {
      name              = "ipam-subnet-1"
      availability_zone = "eu-west-2a"
      netmask_length    = 28
    }
  ]
}
```

## CLI Usage

Once the IPAM pool is created and shared, you can create subnets manually via CLI:

```bash
aws ec2 create-subnet \
  --vpc-id 'vpc-050cd69cb278b47c3' \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=my-subnet}]' \
  --ipv4-ipam-pool-id 'ipam-pool-0dbc9eeb0ecd6148c' \
  --ipv4-netmask-length '28' \
  --availability-zone 'eu-west-2a' \
  --profile poc-net3 \
  --region eu-west-2
```

## Variables

### IPAM Pool Configuration

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `create_vpc_ipam_pool` | Controls if an IPAM pool should be created | `bool` | `false` |
| `vpc_ipam_scope_id` | The ID of the IPAM scope | `string` | `null` |
| `vpc_ipam_source_pool_id` | The ID of the source IPAM pool | `string` | `null` |
| `vpc_ipam_pool_cidr` | The CIDR to provision to the pool | `string` | `null` |
| `vpc_ipam_pool_allocation_default_netmask_length` | Default netmask length for allocations | `number` | `null` |
| `vpc_ipam_pool_allocation_min_netmask_length` | Minimum netmask length | `number` | `null` |
| `vpc_ipam_pool_allocation_max_netmask_length` | Maximum netmask length | `number` | `null` |

### RAM Sharing Configuration

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `vpc_ipam_pool_ram_share_enabled` | Enable RAM sharing | `bool` | `false` |
| `vpc_ipam_pool_ram_share_principals` | List of principals to share with | `list(string)` | `[]` |
| `vpc_ipam_pool_ram_share_allow_external_principals` | Allow external principals | `bool` | `false` |

### Subnet Configuration

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `ipam_subnets` | List of subnets to create from IPAM pool | `list(object)` | `[]` |

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_ipam_pool_id` | The ID of the VPC IPAM pool |
| `vpc_ipam_pool_arn` | The ARN of the VPC IPAM pool |
| `vpc_ipam_pool_cidr` | The CIDR provisioned to the pool |
| `vpc_ipam_pool_ram_share_id` | The ID of the RAM share |
| `ipam_subnets` | Map of IPAM-created subnet IDs |
| `ipam_subnets_cidr_blocks` | Map of IPAM-created subnet CIDR blocks |

## Requirements

- AWS CLI installed and configured
- Terraform >= 1.0
- AWS Provider >= 6.28
- Null Provider >= 3.0

## Limitations

1. **Terraform State Management**: Subnets created via `null_resource` are not fully managed by Terraform. They are imported via data sources.
2. **Drift Detection**: Manual changes to subnets won't be detected by Terraform.
3. **Deletion Dependencies**: Subnet deletion may fail if resources are still attached.
4. **AWS CLI Dependency**: Requires AWS CLI to be installed and configured.

## Future Improvements

Once the Terraform AWS Provider adds native support for `ipv4_ipam_pool_id` in `aws_subnet` resources, this workaround can be replaced with standard resource declarations.

## References

- [AWS IPAM Documentation](https://docs.aws.amazon.com/vpc/latest/ipam/)
- [Terraform AWS Provider Issue](https://github.com/hashicorp/terraform-provider-aws/issues/new)
- [Workaround Article](https://kieranyio.medium.com/workaround-for-unsupported-config-in-terraform-aws-provider-31337208705f)
- [AWS CLI create-subnet](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-subnet.html)

## Support

For issues or questions:
1. Check the [examples/ipam-vpc-subnets](./examples/ipam-vpc-subnets) directory
2. Review the [GitHub Issues](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues)
3. Consult AWS IPAM documentation
