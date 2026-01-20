# Quick Start: IPAM Pool for VPC Subnet Planning

This guide will help you quickly set up IPAM pool-based subnet creation for your VPC.

## Prerequisites

1. AWS CLI installed and configured
2. Terraform >= 1.0
3. An existing IPAM instance (or create one as shown below)

## Step 1: Create Top-Level IPAM Resources

First, create the top-level IPAM and pool:

```hcl
# Create IPAM
resource "aws_vpc_ipam" "main" {
  description = "Main IPAM"
  
  operating_regions {
    region_name = "eu-west-2"
  }
}

# Create top-level pool
resource "aws_vpc_ipam_pool" "top_level" {
  description                       = "Top-level IPv4 pool"
  address_family                    = "ipv4"
  ipam_scope_id                     = aws_vpc_ipam.main.private_default_scope_id
  locale                            = "eu-west-2"
  allocation_default_netmask_length = 16
}

# Provision CIDR to top-level pool
resource "aws_vpc_ipam_pool_cidr" "top_level" {
  ipam_pool_id = aws_vpc_ipam_pool.top_level.id
  cidr         = "10.0.0.0/8"
}
```

## Step 2: Create VPC with IPAM Pool

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Step 2a: Enable VPC IPAM Pool
  create_vpc_ipam_pool    = true
  vpc_ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id
  vpc_ipam_pool_cidr      = "10.0.0.0/16"

  # Step 2b: Configure allocation constraints
  vpc_ipam_pool_allocation_default_netmask_length = 28
  vpc_ipam_pool_allocation_min_netmask_length     = 28
  vpc_ipam_pool_allocation_max_netmask_length     = 24

  # Step 2c: Create subnets from IPAM pool
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

## Step 3: (Optional) Enable RAM Sharing

To share the IPAM pool with other accounts:

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # ... previous configuration ...

  # Enable RAM sharing
  vpc_ipam_pool_ram_share_enabled = true
  vpc_ipam_pool_ram_share_principals = [
    "123456789012",  # AWS Account ID
    "arn:aws:organizations::123456789012:organization/o-xxxxx"  # Organization ARN
  ]
}
```

## Step 4: Apply Configuration

```bash
terraform init
terraform plan
terraform apply
```

## Step 5: Verify Subnet Creation

Check the outputs:

```bash
terraform output ipam_subnets
terraform output ipam_subnets_cidr_blocks
```

## Step 6: Create Additional Subnets via CLI

Once the IPAM pool is created and shared, you can create additional subnets manually:

```bash
# Get the IPAM pool ID
IPAM_POOL_ID=$(terraform output -raw vpc_ipam_pool_id)
VPC_ID=$(terraform output -raw vpc_id)

# Create a new subnet
aws ec2 create-subnet \
  --vpc-id "$VPC_ID" \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=my-new-subnet}]" \
  --ipv4-ipam-pool-id "$IPAM_POOL_ID" \
  --ipv4-netmask-length 28 \
  --availability-zone eu-west-2a \
  --region eu-west-2
```

## Common Configurations

### Minimal Configuration

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  create_vpc_ipam_pool    = true
  vpc_ipam_scope_id       = aws_vpc_ipam.main.private_default_scope_id
  vpc_ipam_source_pool_id = aws_vpc_ipam_pool.top_level.id
  vpc_ipam_pool_cidr      = "10.0.0.0/16"

  ipam_subnets = [
    {
      name              = "subnet-1"
      availability_zone = "eu-west-2a"
      netmask_length    = 24
    }
  ]
}
```

### With Custom Tags

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # ... basic configuration ...

  ipam_subnets = [
    {
      name              = "app-subnet"
      availability_zone = "eu-west-2a"
      netmask_length    = 28
      tags = {
        Environment = "production"
        Application = "web"
        Tier        = "private"
      }
    }
  ]
}
```

### Multi-Account Setup

```hcl
# Account A: Create and share IPAM pool
module "vpc_account_a" {
  source = "terraform-aws-modules/vpc/aws"

  name = "shared-vpc"
  cidr = "10.0.0.0/16"

  create_vpc_ipam_pool               = true
  vpc_ipam_scope_id                  = aws_vpc_ipam.main.private_default_scope_id
  vpc_ipam_source_pool_id            = aws_vpc_ipam_pool.top_level.id
  vpc_ipam_pool_cidr                 = "10.0.0.0/16"
  vpc_ipam_pool_ram_share_enabled    = true
  vpc_ipam_pool_ram_share_principals = ["123456789012"]  # Account B
}

# Account B: Create subnets from shared pool via CLI
# aws ec2 create-subnet --vpc-id vpc-xxx --ipv4-ipam-pool-id ipam-pool-xxx ...
```

## Troubleshooting

### Issue: "AWS CLI not found"

**Solution**: Install AWS CLI:
```bash
# macOS
brew install awscli

# Linux
pip install awscli

# Verify
aws --version
```

### Issue: "Access Denied" when creating subnet

**Solution**: Ensure your IAM role/user has the following permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:DescribeSubnets",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
```

### Issue: "IPAM pool has no available space"

**Solution**: Check the pool allocation:
```bash
aws ec2 get-ipam-pool-allocations --ipam-pool-id ipam-pool-xxx
```

Ensure the pool has sufficient CIDR space provisioned.

### Issue: Subnet not appearing in Terraform state

**Solution**: This is expected. Subnets created via `null_resource` are retrieved via data sources. To see them:
```bash
terraform refresh
terraform output ipam_subnets
```

## Next Steps

- Review the [full documentation](./IPAM_SUBNET_PLANNING.md)
- Check the [complete example](./examples/ipam-vpc-subnets)
- Learn about [IPAM best practices](https://docs.aws.amazon.com/vpc/latest/ipam/best-practices-ipam.html)

## Support

For issues or questions:
- Check [GitHub Issues](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues)
- Review [AWS IPAM Documentation](https://docs.aws.amazon.com/vpc/latest/ipam/)
- See the [workaround article](https://kieranyio.medium.com/workaround-for-unsupported-config-in-terraform-aws-provider-31337208705f)
