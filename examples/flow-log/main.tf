provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# Flow Log
################################################################################

module "flow_log" {
  source = "../../modules/flow-log"

  name   = local.name
  vpc_id = module.vpc.vpc_id

  traffic_type               = "ALL"
  max_aggregation_interval   = 60
  log_format                 = "$${version} $${vpc-id} $${subnet-id} $${srcaddr} $${dstaddr} $${action}"
  deliver_cross_account_role = null

  cloudwatch_log_group_name                        = "${local.name}-flow-log"
  cloudwatch_log_group_use_name_prefix             = true
  cloudwatch_log_group_retention_in_days           = 1
  cloudwatch_log_group_class                       = "STANDARD"
  cloudwatch_log_group_skip_destroy                = false
  cloudwatch_log_group_kms_key_id                  = null
  cloudwatch_log_group_deletion_protection_enabled = false
  cloudwatch_log_group_tags                        = { Destination = "cloud-watch-logs" }

  iam_role_name                 = "${local.name}-flow-log"
  iam_role_use_name_prefix      = true
  iam_role_path                 = "/"
  iam_role_description          = "VPC flow log role for ${local.name}"
  iam_role_permissions_boundary = null
  iam_role_tags                 = { Purpose = "flow-log" }
  iam_role_permissions = {
    logs = {
      actions   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups", "logs:DescribeLogStreams"]
      resources = ["*"]
    }
  }
  iam_role_trust_policy_permissions = {
    delivery = {
      actions = ["sts:AssumeRole"]
      principals = [{
        type        = "Service"
        identifiers = ["delivery.logs.amazonaws.com"]
      }]
    }
  }

  flow_log_tags = { Scope = "vpc" }

  tags = local.tags
}

# A flow log can target a subnet or a single network interface instead of the whole VPC
module "flow_log_subnet" {
  source = "../../modules/flow-log"

  name      = "${local.name}-subnet"
  subnet_id = element(module.vpc.private_subnets, 0)

  tags = local.tags
}

module "flow_log_eni" {
  source = "../../modules/flow-log"

  name   = "${local.name}-eni"
  eni_id = aws_network_interface.this.id

  tags = local.tags
}

module "flow_log_cloudwatch_external" {
  source = "../../modules/flow-log"

  name   = "${local.name}-cloudwatch-external"
  vpc_id = module.vpc.vpc_id

  create_cloudwatch_log_group = false
  log_destination             = module.flow_log_group.cloudwatch_log_group_arn

  create_iam_role = false
  iam_role_arn    = module.flow_log_role.arn

  tags = local.tags
}

module "flow_log_s3" {
  source = "../../modules/flow-log"

  name   = "${local.name}-s3"
  vpc_id = module.vpc.vpc_id

  log_destination_type = "s3"
  log_destination      = module.s3_bucket.s3_bucket_arn

  tags = local.tags
}

module "flow_log_s3_parquet" {
  source = "../../modules/flow-log"

  name   = "${local.name}-s3-parquet"
  vpc_id = module.vpc.vpc_id

  log_destination_type = "s3"
  log_destination      = module.s3_bucket.s3_bucket_arn
  destination_options = {
    file_format                = "parquet"
    hive_compatible_partitions = true
    per_hour_partition         = true
  }

  tags = local.tags
}

################################################################################
# VPC Module Flow Logs
################################################################################

# The root module can create the log group, the IAM role and the flow log itself
module "vpc_flow_log_cloudwatch" {
  source = "../../"

  name = "${local.name}-cloudwatch"
  cidr = "10.1.0.0/16"

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet("10.1.0.0/16", 8, k)]

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  flow_log_destination_type         = "cloud-watch-logs"
  flow_log_traffic_type             = "ALL"
  flow_log_max_aggregation_interval = 60
  flow_log_log_format               = "$${version} $${vpc-id} $${subnet-id} $${instance-id} $${srcaddr} $${dstaddr} $${action}"

  flow_log_cloudwatch_log_group_name_prefix       = "/aws/vpc-flow-log/"
  flow_log_cloudwatch_log_group_name_suffix       = local.name
  flow_log_cloudwatch_log_group_retention_in_days = 1
  flow_log_cloudwatch_log_group_class             = "STANDARD"
  flow_log_cloudwatch_log_group_skip_destroy      = false
  flow_log_cloudwatch_log_group_kms_key_id        = null

  flow_log_cloudwatch_iam_role_conditions = [
    {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    },
  ]

  vpc_flow_log_iam_role_name              = "${local.name}-flow-log"
  vpc_flow_log_iam_role_use_name_prefix   = true
  vpc_flow_log_iam_role_path              = "/"
  vpc_flow_log_iam_policy_name            = "${local.name}-flow-log"
  vpc_flow_log_iam_policy_use_name_prefix = true
  vpc_flow_log_permissions_boundary       = null
  vpc_flow_log_tags                       = { Destination = "cloud-watch-logs" }

  tags = local.tags
}

# Pointing at a log group and role created elsewhere, rather than having the module make them
module "vpc_flow_log_cloudwatch_external" {
  source = "../../"

  name = "${local.name}-cloudwatch-external"
  cidr = "10.3.0.0/16"

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet("10.3.0.0/16", 8, k)]

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = false
  create_flow_log_cloudwatch_iam_role  = false

  flow_log_destination_arn         = module.flow_log_group.cloudwatch_log_group_arn
  flow_log_cloudwatch_iam_role_arn = module.flow_log_role.arn

  tags = local.tags
}

# Delivering to S3 is what makes the Parquet and partitioning options meaningful
module "vpc_flow_log_s3" {
  source = "../../"

  name = "${local.name}-s3"
  cidr = "10.2.0.0/16"

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet("10.2.0.0/16", 8, k)]

  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.s3_bucket.s3_bucket_arn

  flow_log_file_format                = "parquet"
  flow_log_hive_compatible_partitions = true
  flow_log_per_hour_partition         = true
  flow_log_deliver_cross_account_role = null

  tags = local.tags
}

################################################################################
# Disabled
################################################################################

module "disabled" {
  source = "../../modules/flow-log"

  create = false

  transit_gateway_id            = "tgw-00000000000000000"
  transit_gateway_attachment_id = "tgw-attach-00000000000000000"
  kinesis_data_firehose_arn     = "arn:aws:firehose:eu-west-1:123456789012:deliverystream/example"
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source = "../../"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  tags = local.tags
}

# The bundled WAF log delivery policy is close but not sufficient: flow log delivery writes
# under `AWSLogs/aws-account-id=<id>/` when hive compatible partitions are on, and AWS adds
# that statement to the bucket policy itself. Since this module owns the policy, Terraform
# removes it again on the next plan, which is a permanent diff. Granting the path up front is
# what makes the second plan clean
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.0"

  bucket_prefix = "${local.name}-"
  force_destroy = true

  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSLogDeliveryAclCheck"
        Effect    = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = "_S3_BUCKET_ARN_"
        Condition = {
          StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
          ArnLike      = { "aws:SourceArn" = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:*" }
        }
      },
      {
        Sid       = "AWSLogDeliveryWrite"
        Effect    = "Allow"
        Principal = { Service = "delivery.logs.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource = [
          "_S3_BUCKET_ARN_/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
          "_S3_BUCKET_ARN_/AWSLogs/aws-account-id=${data.aws_caller_identity.current.account_id}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "s3:x-amz-acl"      = "bucket-owner-full-control"
          }
          ArnLike = { "aws:SourceArn" = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:*" }
        }
      },
    ]
  })

  tags = local.tags
}

module "flow_log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 5.0"

  name_prefix       = "/aws/flow-log/vpc/${module.vpc.vpc_id}/${local.name}-external-"
  retention_in_days = 7

  tags = local.tags
}

module "flow_log_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name            = "${local.name}-external"
  use_name_prefix = true

  trust_policy_permissions = {
    VPCFlowLogsAssume = {
      actions = ["sts:AssumeRole"]
      principals = [{
        type        = "Service"
        identifiers = ["vpc-flow-logs.amazonaws.com"]
      }]
    }
  }

  create_inline_policy = true
  inline_policy_permissions = {
    logs = {
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
      ]
      resources = [module.flow_log_group.cloudwatch_log_group_arn]
    }
  }

  tags = local.tags
}

resource "aws_network_interface" "this" {
  subnet_id = element(module.vpc.private_subnets, 0)

  tags = local.tags
}
