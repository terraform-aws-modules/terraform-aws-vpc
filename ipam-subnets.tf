# IPAM Pool for VPC Subnet Planning
# This creates an IPAM pool scoped to the VPC for subnet allocation
# Uses null_resource because Terraform AWS Provider doesn't support --source-resource parameter

locals {
  create_vpc_ipam_pool = local.create_vpc && var.create_vpc_ipam_pool
  vpc_ipam_pool_description = coalesce(var.vpc_ipam_pool_description, "IPAM pool for ${var.name} VPC subnets")
  vpc_ipam_pool_name = coalesce(var.vpc_ipam_pool_name, "${var.name}-vpc-subnets")
}

# Create VPC-specific IPAM pool using AWS CLI (workaround for unsupported --source-resource)
resource "null_resource" "vpc_ipam_pool" {
  count = local.create_vpc_ipam_pool ? 1 : 0

  triggers = {
    vpc_id              = local.vpc_id
    vpc_cidr            = try(aws_vpc.this[0].cidr_block, "")
    ipam_scope_id       = var.vpc_ipam_scope_id
    source_pool_id      = var.vpc_ipam_source_pool_id
    locale              = var.vpc_ipam_pool_locale
    description         = local.vpc_ipam_pool_description
    pool_name           = local.vpc_ipam_pool_name
    default_netmask     = var.vpc_ipam_pool_allocation_default_netmask_length
    min_netmask         = var.vpc_ipam_pool_allocation_min_netmask_length
    max_netmask         = var.vpc_ipam_pool_allocation_max_netmask_length
    auto_import         = var.vpc_ipam_pool_auto_import
    region              = var.vpc_ipam_pool_region != null ? var.vpc_ipam_pool_region : var.region
    aws_profile         = var.vpc_ipam_pool_aws_profile
    vpc_aws_profile     = var.vpc_aws_profile
    ram_enabled         = var.vpc_ipam_pool_ram_share_enabled
    ram_share_name      = coalesce(var.vpc_ipam_pool_ram_share_name, "${var.name}-ipam-pool-share")
    ram_principals      = jsonencode(var.vpc_ipam_pool_ram_share_principals)
    ram_allow_external  = var.vpc_ipam_pool_ram_share_allow_external_principals
    tags                = jsonencode(merge(
      { "Name" = local.vpc_ipam_pool_name },
      var.tags,
      var.vpc_ipam_pool_tags,
    ))
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      ${self.triggers.aws_profile != "" ? "export AWS_PROFILE=${self.triggers.aws_profile}" : ""}
      ${self.triggers.region != null ? "export AWS_DEFAULT_REGION=${self.triggers.region}" : ""}
      
      # Wait for IPAM to discover the VPC (resource discovery can take 5-10 minutes)
      echo "Waiting 600 seconds (10 minutes) for IPAM resource discovery..."
      sleep 600
      
      # Get VPC owner account ID (use VPC account profile to describe VPC)
      VPC_OWNER=$(${self.triggers.vpc_aws_profile != "" ? "AWS_PROFILE=${self.triggers.vpc_aws_profile}" : ""} aws ec2 describe-vpcs --vpc-ids '${local.vpc_id}' --region '${self.triggers.locale}' --query 'Vpcs[0].OwnerId' --output text)
      
      # Create IPAM pool with VPC as source resource
      POOL_ID=$(aws ec2 create-ipam-pool \
        --ipam-scope-id '${self.triggers.ipam_scope_id}' \
        --description '${self.triggers.description}' \
        --address-family ipv4 \
        --locale '${self.triggers.locale}' \
        --source-ipam-pool-id '${self.triggers.source_pool_id}' \
        --source-resource ResourceId=${local.vpc_id},ResourceType=vpc,ResourceRegion=${self.triggers.locale},ResourceOwner=$VPC_OWNER \
        ${self.triggers.default_netmask != null ? "--allocation-default-netmask-length ${self.triggers.default_netmask}" : ""} \
        ${self.triggers.min_netmask != null ? "--allocation-min-netmask-length ${self.triggers.min_netmask}" : ""} \
        ${self.triggers.max_netmask != null ? "--allocation-max-netmask-length ${self.triggers.max_netmask}" : ""} \
        ${self.triggers.auto_import ? "--auto-import" : "--no-auto-import"} \
        --tag-specifications 'ResourceType=ipam-pool,Tags=[{Key=Name,Value=${self.triggers.pool_name}},{Key=ManagedBy,Value=Terraform}${join("", [for k, v in merge(var.tags, var.vpc_ipam_pool_tags) : ",{Key=${k},Value=${v}}"])}]' \
        --query 'IpamPool.IpamPoolId' \
        --output text)
      
      if [ -z "$POOL_ID" ] || [ "$POOL_ID" = "None" ]; then
        echo "ERROR: Failed to create IPAM pool"
        exit 1
      fi
      
      echo "Created IPAM pool: $POOL_ID"
      echo "$POOL_ID" > ${path.module}/.terraform/vpc-ipam-pool.id
      
      # Wait for pool to be in create-complete state
      echo "Waiting for IPAM pool to be ready..."
      for i in {1..30}; do
        POOL_STATE=$(aws ec2 describe-ipam-pools --ipam-pool-ids "$POOL_ID" --region '${self.triggers.region}' --query 'IpamPools[0].State' --output text)
        if [ "$POOL_STATE" = "create-complete" ]; then
          echo "IPAM pool is ready"
          break
        elif [ "$POOL_STATE" = "create-failed" ]; then
          echo "ERROR: IPAM pool creation failed"
          exit 1
        fi
        echo "Pool state: $POOL_STATE, waiting... ($i/30)"
        sleep 10
      done
      
      # Provision VPC CIDR to the pool
      echo "Provisioning VPC CIDR ${self.triggers.vpc_cidr} to pool $POOL_ID..."
      aws ec2 provision-ipam-pool-cidr \
        --ipam-pool-id "$POOL_ID" \
        --cidr '${self.triggers.vpc_cidr}' \
        --region '${self.triggers.region}'
      
      # Wait for CIDR to be provisioned
      echo "Waiting for CIDR to be provisioned..."
      for i in {1..30}; do
        CIDR_STATE=$(aws ec2 get-ipam-pool-cidrs --ipam-pool-id "$POOL_ID" --region '${self.triggers.region}' --query "IpamPoolCidrs[?Cidr=='${self.triggers.vpc_cidr}'].State | [0]" --output text)
        if [ "$CIDR_STATE" = "provisioned" ]; then
          echo "CIDR provisioned successfully"
          break
        elif [ "$CIDR_STATE" = "failed-provision" ]; then
          echo "ERROR: CIDR provisioning failed"
          exit 1
        fi
        echo "CIDR state: $CIDR_STATE, waiting... ($i/30)"
        sleep 10
      done
      
      # Store pool ARN for RAM sharing
      POOL_ARN=$(aws ec2 describe-ipam-pools --ipam-pool-ids "$POOL_ID" --region '${self.triggers.region}' --query 'IpamPools[0].IpamPoolArn' --output text)
      echo "$POOL_ARN" > ${path.module}/.terraform/vpc-ipam-pool.arn
      
      # Create RAM share if enabled
      if [ "${self.triggers.ram_enabled}" = "true" ]; then
        echo "Creating RAM resource share..."
        SHARE_ARN=$(aws ram create-resource-share \
          --name '${self.triggers.ram_share_name}' \
          ${self.triggers.ram_allow_external ? "--allow-external-principals" : "--no-allow-external-principals"} \
          --tags key=Name,value=${self.triggers.ram_share_name} key=ManagedBy,value=Terraform \
          --query 'resourceShare.resourceShareArn' \
          --output text)
        
        echo "Created RAM share: $SHARE_ARN"
        echo "$SHARE_ARN" > ${path.module}/.terraform/vpc-ipam-pool-ram-share.arn
        
        # Associate IPAM pool with RAM share
        echo "Associating pool with RAM share..."
        aws ram associate-resource-share \
          --resource-share-arn "$SHARE_ARN" \
          --resource-arns "$POOL_ARN"
        
        # Associate principals with RAM share
        PRINCIPALS='${self.triggers.ram_principals}'
        for PRINCIPAL in $(echo "$PRINCIPALS" | jq -r '.[]'); do
          echo "Associating principal $PRINCIPAL with RAM share..."
          aws ram associate-resource-share \
            --resource-share-arn "$SHARE_ARN" \
            --principals "$PRINCIPAL"
        done
        
        echo "RAM share configuration complete"
      fi
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      ${self.triggers.region != null ? "export AWS_DEFAULT_REGION=${self.triggers.region}" : ""}
      ${self.triggers.aws_profile != "" ? "export AWS_PROFILE=${self.triggers.aws_profile}" : ""}
      
      # Delete RAM share if it exists
      if [ -f ${path.module}/.terraform/vpc-ipam-pool-ram-share.arn ]; then
        SHARE_ARN=$(cat ${path.module}/.terraform/vpc-ipam-pool-ram-share.arn)
        aws ram delete-resource-share --resource-share-arn "$SHARE_ARN" || true
        rm -f ${path.module}/.terraform/vpc-ipam-pool-ram-share.arn
      fi
      
      # Delete IPAM pool with cascade (deletes CIDRs and releases allocations)
      if [ -f ${path.module}/.terraform/vpc-ipam-pool.id ]; then
        POOL_ID=$(cat ${path.module}/.terraform/vpc-ipam-pool.id)
        
        echo "Deleting pool $POOL_ID with cascade..."
        aws ec2 delete-ipam-pool --ipam-pool-id "$POOL_ID" --cascade || true
        
        rm -f ${path.module}/.terraform/vpc-ipam-pool.id
        rm -f ${path.module}/.terraform/vpc-ipam-pool.arn
      fi
    EOT
  }

  depends_on = [aws_vpc.this]
}

# Data source to retrieve created IPAM pool information
# This reads the pool ID and ARN from files created by the null_resource
locals {
  vpc_ipam_pool_id  = local.create_vpc_ipam_pool && fileexists("${path.module}/.terraform/vpc-ipam-pool.id") ? trimspace(file("${path.module}/.terraform/vpc-ipam-pool.id")) : ""
  vpc_ipam_pool_arn = local.create_vpc_ipam_pool && fileexists("${path.module}/.terraform/vpc-ipam-pool.arn") ? trimspace(file("${path.module}/.terraform/vpc-ipam-pool.arn")) : ""
}

# Subnets from IPAM Pool using null_resource workaround
# This is a workaround until Terraform AWS Provider supports ipam_pool_id for subnets
# Reference: https://kieranyio.medium.com/workaround-for-unsupported-config-in-terraform-aws-provider-31337208705f

locals {
  create_ipam_subnets = local.create_vpc_ipam_pool && length(var.ipam_subnets) > 0
}

resource "null_resource" "ipam_subnets" {
  for_each = local.create_ipam_subnets ? { for idx, subnet in var.ipam_subnets : idx => subnet } : {}

  triggers = {
    vpc_id              = local.vpc_id
    ipam_pool_id        = local.vpc_ipam_pool_id
    availability_zone   = each.value.availability_zone
    netmask_length      = each.value.netmask_length
    subnet_name         = each.value.name
    tags                = jsonencode(merge(var.tags, lookup(each.value, "tags", {})))
    region              = var.vpc_ipam_pool_locale != null ? var.vpc_ipam_pool_locale : var.region
    aws_profile         = var.vpc_aws_profile
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      ${self.triggers.aws_profile != "" ? "export AWS_PROFILE=${self.triggers.aws_profile}" : ""}
      ${self.triggers.region != null ? "export AWS_DEFAULT_REGION=${self.triggers.region}" : ""}
      
      # Read pool ID from file (created by null_resource.vpc_ipam_pool)
      if [ ! -f ${path.module}/.terraform/vpc-ipam-pool.id ]; then
        echo "ERROR: Pool ID file not found"
        exit 1
      fi
      POOL_ID=$(cat ${path.module}/.terraform/vpc-ipam-pool.id)
      
      # Wait for RAM share to propagate (cross-account sharing takes time)
      echo "Waiting 60 seconds for RAM share propagation..."
      sleep 60
      
      SUBNET_ID=$(aws ec2 create-subnet \
        --vpc-id '${local.vpc_id}' \
        --availability-zone '${each.value.availability_zone}' \
        --ipv4-ipam-pool-id "$POOL_ID" \
        --ipv4-netmask-length '${each.value.netmask_length}' \
        --region '${self.triggers.region}' \
        --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=${each.value.name}},{Key=ManagedBy,Value=Terraform}${join("", [for k, v in merge(var.tags, lookup(each.value, "tags", {})) : ",{Key=${k},Value=${v}}"])}]' \
        --query 'Subnet.SubnetId' \
        --output text)
      
      echo "Created subnet: $SUBNET_ID"
      echo "$SUBNET_ID" > ${path.module}/.terraform/ipam-subnet-${each.key}.id
      
      # Wait a bit for AWS to index the subnet
      sleep 5
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      ${self.triggers.aws_profile != "" ? "export AWS_PROFILE=${self.triggers.aws_profile}" : ""}
      ${self.triggers.region != null ? "export AWS_DEFAULT_REGION=${self.triggers.region}" : ""}
      
      if [ -f ${path.module}/.terraform/ipam-subnet-${each.key}.id ]; then
        SUBNET_ID=$(cat ${path.module}/.terraform/ipam-subnet-${each.key}.id)
        aws ec2 delete-subnet --subnet-id "$SUBNET_ID" || true
        rm -f ${path.module}/.terraform/ipam-subnet-${each.key}.id
      fi
    EOT
  }

  depends_on = [
    null_resource.vpc_ipam_pool,
    aws_vpc.this
  ]
}

# Data source to retrieve created subnet information
data "aws_subnet" "ipam_subnets" {
  for_each = local.create_ipam_subnets ? { for idx, subnet in var.ipam_subnets : idx => subnet } : {}

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = [each.value.name]
  }

  depends_on = [null_resource.ipam_subnets]
}
