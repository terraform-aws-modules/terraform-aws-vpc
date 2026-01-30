# Cross-Account VPC with IPAM Pool

This example demonstrates cross-account IPAM configuration where:
- **IPAM resources** (IPAM instance, top-level pool) are in a **networking account**
- **VPC and subnets** are in an **application account**
- **IPAM pool is shared** via AWS RAM from networking account to application account

This pattern enables centralized IP address management across multiple AWS accounts.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Networking Account (111111111111)                      │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ IPAM Instance                                      │ │
│  │   └── Private Default Scope                       │ │
│  │       └── Top-level Pool (10.0.0.0/8)             │ │
│  │           └── Shared via RAM                      │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
                          │ RAM Share
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Application Account (222222222222)                     │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ VPC (10.0.0.0/16)                                  │ │
│  │   └── VPC-scoped IPAM Pool                        │ │
│  │       ├── Private Subnet 1 (10.0.1.0/24)          │ │
│  │       ├── Private Subnet 2 (10.0.2.0/24)          │ │
│  │       └── Private Subnet 3 (10.0.3.0/24)          │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

### AWS Accounts

You need access to two AWS accounts:
- **Networking Account**: Where IPAM resources will be created
- **Application Account**: Where VPC and subnets will be created

### Terraform Provider Version

- Terraform: >= 1.0
- AWS Provider: **>= 6.29.0** (required for native IPAM support)

### IAM Permissions

#### Networking Account

The role/user needs permissions to:
- Create and manage IPAM resources
- Create and manage RAM shares
- Share resources with other accounts

Example IAM policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateIpam",
        "ec2:DeleteIpam",
        "ec2:DescribeIpams",
        "ec2:ModifyIpam",
        "ec2:CreateIpamPool",
        "ec2:DeleteIpamPool",
        "ec2:DescribeIpamPools",
        "ec2:ModifyIpamPool",
        "ec2:ProvisionIpamPoolCidr",
        "ec2:DeprovisionIpamPoolCidr",
        "ec2:GetIpamPoolCidrs",
        "ram:CreateResourceShare",
        "ram:DeleteResourceShare",
        "ram:GetResourceShares",
        "ram:AssociateResourceShare",
        "ram:DisassociateResourceShare",
        "ram:GetResourceShareAssociations"
      ],
      "Resource": "*"
    }
  ]
}
```

#### Application Account

The role/user needs permissions to:
- Create and manage VPC resources
- Create VPC-scoped IPAM pools
- Accept RAM share invitations
- Use shared IPAM pools

Example IAM policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:DescribeVpcs",
        "ec2:ModifyVpcAttribute",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:DescribeSubnets",
        "ec2:ModifySubnetAttribute",
        "ec2:CreateIpamPool",
        "ec2:DeleteIpamPool",
        "ec2:DescribeIpamPools",
        "ec2:ModifyIpamPool",
        "ec2:ProvisionIpamPoolCidr",
        "ec2:DeprovisionIpamPoolCidr",
        "ec2:GetIpamPoolCidrs",
        "ram:AcceptResourceShareInvitation",
        "ram:GetResourceShareInvitations"
      ],
      "Resource": "*"
    }
  ]
}
```

### Authentication Setup

You have two options for authentication:

#### Option 1: AWS Profiles (Local Development)

Configure AWS profiles in `~/.aws/credentials`:

```ini
[networking]
aws_access_key_id = AKIA...
aws_secret_access_key = ...

[application]
aws_access_key_id = AKIA...
aws_secret_access_key = ...
```

Or in `~/.aws/config` with assume role:

```ini
[profile networking]
role_arn = arn:aws:iam::111111111111:role/TerraformNetworkingRole
source_profile = default

[profile application]
role_arn = arn:aws:iam::222222222222:role/TerraformApplicationRole
source_profile = default
```

#### Option 2: Assume Role (CI/CD)

Configure provider to assume roles directly (see `providers.tf` in this example).

## Configuration

### Step 1: Update Account IDs

Edit `terraform.tfvars` and update the account IDs:

```hcl
networking_account_id  = "111111111111"  # Replace with your networking account ID
application_account_id = "222222222222"  # Replace with your application account ID
```

### Step 2: Configure Authentication

Choose your authentication method:

**For AWS Profiles** (local development):
```hcl
# In providers.tf, uncomment the profile lines:
provider "aws" {
  alias   = "networking"
  region  = var.region
  profile = "networking"  # Uncomment this
}

provider "aws" {
  alias   = "application"
  region  = var.region
  profile = "application"  # Uncomment this
}
```

**For Assume Role** (CI/CD):
```hcl
# In providers.tf, uncomment the assume_role blocks:
provider "aws" {
  alias  = "networking"
  region = var.region
  
  assume_role {
    role_arn = "arn:aws:iam::${var.networking_account_id}:role/TerraformNetworkingRole"
  }
}

provider "aws" {
  alias  = "application"
  region = var.region
  
  assume_role {
    role_arn = "arn:aws:iam::${var.application_account_id}:role/TerraformApplicationRole"
  }
}
```

### Step 3: Review Configuration

Review the configuration in `main.tf`:
- IPAM instance and top-level pool in networking account
- RAM share configuration
- VPC and VPC-scoped IPAM pool in application account
- Subnet creation from shared IPAM pool

## Usage

### Deploy the Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### Verify the Deployment

```bash
# Check IPAM resources in networking account
aws ec2 describe-ipams --profile networking --region us-east-1

# Check RAM share in networking account
aws ram get-resource-shares --resource-owner SELF --profile networking --region us-east-1

# Check VPC and subnets in application account
aws ec2 describe-vpcs --profile application --region us-east-1
aws ec2 describe-subnets --profile application --region us-east-1

# View Terraform outputs
terraform output
```

### Clean Up

```bash
terraform destroy
```

## How It Works

### 1. IPAM Resources in Networking Account

The example creates IPAM resources in the networking account:

```hcl
# IPAM instance
resource "aws_vpc_ipam" "main" {
  provider = aws.networking
  
  operating_regions {
    region_name = var.region
  }
}

# Top-level IPAM pool
resource "aws_vpc_ipam_pool" "top_level" {
  provider = aws.networking
  
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.main.private_default_scope_id
  locale         = var.region
}

# Provision CIDR to top-level pool
resource "aws_vpc_ipam_pool_cidr" "top_level" {
  provider = aws.networking
  
  ipam_pool_id = aws_vpc_ipam_pool.top_level.id
  cidr         = "10.0.0.0/8"
}
```

### 2. RAM Sharing

The top-level IPAM pool is shared with the application account via RAM:

```hcl
# Create RAM share
resource "aws_ram_resource_share" "ipam_pool" {
  provider = aws.networking
  
  name                      = "ipam-pool-cross-account-share"
  allow_external_principals = false
}

# Associate IPAM pool with RAM share
resource "aws_ram_resource_association" "ipam_pool" {
  provider = aws.networking
  
  resource_arn       = aws_vpc_ipam_pool.top_level.arn
  resource_share_arn = aws_ram_resource_share.ipam_pool.arn
}

# Share with application account
resource "aws_ram_principal_association" "application_account" {
  provider = aws.networking
  
  principal          = var.application_account_id
  resource_share_arn = aws_ram_resource_share.ipam_pool.arn
}
```

### 3. VPC and Subnets in Application Account

The VPC module creates resources in the application account using the shared IPAM pool:

```hcl
module "vpc" {
  source = "../.."
  
  # Use application account provider
  providers = {
    aws = aws.application
  }
  
  name = "cross-account-vpc"
  cidr = "10.0.0.0/16"
  
  # Create VPC-scoped IPAM pool using shared top-level pool
  create_vpc_ipam_pool    = true
  vpc_ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id
  vpc_ipam_pool_cidr      = "10.0.0.0/16"
  
  # Create subnets from VPC-scoped IPAM pool
  ipam_subnets = [
    {
      name              = "private-subnet-1"
      availability_zone = "${var.region}a"
      netmask_length    = 24
    },
    {
      name              = "private-subnet-2"
      availability_zone = "${var.region}b"
      netmask_length    = 24
    },
    {
      name              = "private-subnet-3"
      availability_zone = "${var.region}c"
      netmask_length    = 24
    }
  ]
}
```

### 4. Resource Dependencies

Terraform automatically handles dependencies:
1. IPAM instance created first
2. Top-level pool created and CIDR provisioned
3. RAM share created and associations established
4. VPC created in application account
5. VPC-scoped IPAM pool created (depends on RAM share)
6. Subnets created from VPC-scoped pool

## Key Concepts

### Provider Aliases

Provider aliases allow Terraform to manage resources in multiple AWS accounts:

```hcl
provider "aws" {
  alias = "networking"
  # ... authentication for networking account
}

provider "aws" {
  alias = "application"
  # ... authentication for application account
}
```

Resources specify which provider to use:

```hcl
resource "aws_vpc_ipam" "main" {
  provider = aws.networking  # Created in networking account
}

module "vpc" {
  providers = {
    aws = aws.application  # Created in application account
  }
}
```

### VPC-Scoped IPAM Pool

The VPC-scoped IPAM pool is created in the **application account** but uses the shared top-level pool as its source:

- **Created in**: Application account (where VPC exists)
- **Source pool**: Top-level pool in networking account (shared via RAM)
- **Purpose**: Allocate subnet CIDRs within the VPC's CIDR range

The `source_resource` block associates the pool with the VPC:

```hcl
source_resource {
  resource_id     = vpc_id
  resource_owner  = application_account_id
  resource_region = region
  resource_type   = "vpc"
}
```

### RAM Share Acceptance

When sharing within the same AWS Organization with `allow_external_principals = false`, the RAM share is automatically accepted. For external accounts or when `allow_external_principals = true`, manual acceptance is required.

## Troubleshooting

### Issue: RAM Share Not Visible

**Problem**: Application account cannot see the shared IPAM pool.

**Solution**:
1. Verify RAM share was created successfully:
   ```bash
   aws ram get-resource-shares --resource-owner SELF --profile networking
   ```

2. Check RAM share invitation status:
   ```bash
   aws ram get-resource-share-invitations --profile application
   ```

3. Accept invitation if pending:
   ```bash
   aws ram accept-resource-share-invitation \
     --resource-share-invitation-arn "arn:aws:ram:..." \
     --profile application
   ```

### Issue: Authentication Fails

**Problem**: Provider cannot authenticate to AWS account.

**Solution**:
1. Verify AWS profiles are configured correctly in `~/.aws/credentials`
2. Test authentication manually:
   ```bash
   aws sts get-caller-identity --profile networking
   aws sts get-caller-identity --profile application
   ```
3. For assume role, verify trust relationships allow your execution role to assume the target roles

### Issue: IPAM Pool Access Denied

**Problem**: Application account cannot use the shared IPAM pool.

**Solution**:
1. Verify RAM share is accepted
2. Check IAM permissions in application account include IPAM operations
3. Verify IPAM pool locale matches VPC region

### Issue: Subnet Creation Fails

**Problem**: Subnets cannot be created from IPAM pool.

**Solution**:
1. Verify VPC CIDR is provisioned to VPC-scoped IPAM pool
2. Check allocation constraints allow the requested netmask length
3. Ensure sufficient IP space is available in the pool

## Customization

### Add More Subnets

Edit the `ipam_subnets` list in `main.tf`:

```hcl
ipam_subnets = [
  {
    name              = "private-subnet-1"
    availability_zone = "${var.region}a"
    netmask_length    = 24
  },
  {
    name              = "private-subnet-2"
    availability_zone = "${var.region}b"
    netmask_length    = 24
  },
  {
    name              = "public-subnet-1"
    availability_zone = "${var.region}a"
    netmask_length    = 28
    tags = {
      Type = "public"
    }
  }
]
```

### Share with Multiple Accounts

Add more principal associations:

```hcl
resource "aws_ram_principal_association" "dev_account" {
  provider = aws.networking
  
  principal          = "333333333333"
  resource_share_arn = aws_ram_resource_share.ipam_pool.arn
}

resource "aws_ram_principal_association" "prod_account" {
  provider = aws.networking
  
  principal          = "444444444444"
  resource_share_arn = aws_ram_resource_share.ipam_pool.arn
}
```

### Change CIDR Ranges

Update the CIDR ranges in `main.tf`:

```hcl
# Top-level pool CIDR
resource "aws_vpc_ipam_pool_cidr" "top_level" {
  cidr = "172.16.0.0/12"  # Change to your desired range
}

# VPC CIDR
module "vpc" {
  cidr = "172.16.0.0/16"  # Must be within top-level pool range
  vpc_ipam_pool_cidr = "172.16.0.0/16"
}
```

## Additional Resources

- [Cross-Account IPAM Configuration Guide](../../docs/CROSS_ACCOUNT_IPAM.md)
- [IPAM Subnet Planning Guide](../../IPAM_SUBNET_PLANNING.md)
- [Migration Guide](../../MIGRATION.md)
- [AWS IPAM Documentation](https://docs.aws.amazon.com/vpc/latest/ipam/)
- [AWS RAM Documentation](https://docs.aws.amazon.com/ram/)

## Summary

This example demonstrates:
- ✅ Cross-account IPAM configuration with provider aliases
- ✅ Native Terraform resources (no AWS CLI required)
- ✅ RAM sharing for cross-account IPAM pool access
- ✅ VPC-scoped IPAM pools for subnet planning
- ✅ Automatic subnet CIDR allocation from shared pools
- ✅ Proper resource dependencies and lifecycle management

The modernized IPAM implementation makes cross-account scenarios straightforward and reliable using native Terraform resources.
