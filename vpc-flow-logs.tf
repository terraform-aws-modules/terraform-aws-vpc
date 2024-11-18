data "aws_region" "current" {
  # Call this API only if create_vpc and enable_flow_log are true
  count = var.create_vpc && var.enable_flow_log ? 1 : 0
}

data "aws_caller_identity" "current" {
  # Call this API only if create_vpc and enable_flow_log are true
  count = var.create_vpc && var.enable_flow_log ? 1 : 0
}

data "aws_partition" "current" {
  # Call this API only if create_vpc and enable_flow_log are true
  count = var.create_vpc && var.enable_flow_log ? 1 : 0
}

locals {
  # Only create flow log if user selected to create a VPC as well
  enable_flow_log = var.create_vpc && var.enable_flow_log

  create_flow_log_cloudwatch_iam_role  = local.enable_flow_log && var.flow_log_destination_type != "s3" && var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = local.enable_flow_log && var.flow_log_destination_type != "s3" && var.create_flow_log_cloudwatch_log_group

  flow_log_destination_arn                  = local.create_flow_log_cloudwatch_log_group ? try(aws_cloudwatch_log_group.flow_log[0].arn, null) : var.flow_log_destination_arn
  flow_log_iam_role_arn                     = var.flow_log_destination_type != "s3" && local.create_flow_log_cloudwatch_iam_role ? try(aws_iam_role.vpc_flow_log_cloudwatch[0].arn, null) : var.flow_log_cloudwatch_iam_role_arn
  flow_log_cloudwatch_log_group_name_suffix = var.flow_log_cloudwatch_log_group_name_suffix == "" ? local.vpc_id : var.flow_log_cloudwatch_log_group_name_suffix
  flow_log_group_arns = [
    for log_group in aws_cloudwatch_log_group.flow_log :
    "arn:${data.aws_partition.current[0].partition}:logs:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:log-group:${log_group.name}:*"
  ]
}

################################################################################
# Flow Log
################################################################################

resource "aws_flow_log" "this" {
  count = local.enable_flow_log ? 1 : 0

  log_destination_type       = var.flow_log_destination_type
  log_destination            = local.flow_log_destination_arn
  log_format                 = var.flow_log_log_format
  iam_role_arn               = local.flow_log_iam_role_arn
  deliver_cross_account_role = var.flow_log_deliver_cross_account_role
  traffic_type               = var.flow_log_traffic_type
  vpc_id                     = local.vpc_id
  max_aggregation_interval   = var.flow_log_max_aggregation_interval

  dynamic "destination_options" {
    for_each = var.flow_log_destination_type == "s3" ? [true] : []

    content {
      file_format                = var.flow_log_file_format
      hive_compatible_partitions = var.flow_log_hive_compatible_partitions
      per_hour_partition         = var.flow_log_per_hour_partition
    }
  }

  tags = merge(var.tags, var.vpc_flow_log_tags)
}

################################################################################
# Flow Log CloudWatch
################################################################################

resource "aws_cloudwatch_log_group" "flow_log" {
  count = local.create_flow_log_cloudwatch_log_group ? 1 : 0

  name              = "${var.flow_log_cloudwatch_log_group_name_prefix}${local.flow_log_cloudwatch_log_group_name_suffix}"
  retention_in_days = var.flow_log_cloudwatch_log_group_retention_in_days
  kms_key_id        = var.flow_log_cloudwatch_log_group_kms_key_id
  skip_destroy      = var.flow_log_cloudwatch_log_group_skip_destroy
  log_group_class   = var.flow_log_cloudwatch_log_group_class

  tags = merge(var.tags, var.vpc_flow_log_tags)
}

resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  name        = var.vpc_flow_log_iam_role_use_name_prefix ? null : var.vpc_flow_log_iam_role_name
  name_prefix = var.vpc_flow_log_iam_role_use_name_prefix ? "${var.vpc_flow_log_iam_role_name}-" : null

  assume_role_policy   = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role[0].json
  permissions_boundary = var.vpc_flow_log_permissions_boundary

  tags = merge(var.tags, var.vpc_flow_log_tags)
}

data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  statement {
    sid = "AWSVPCFlowLogsAssumeRole"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = ["sts:AssumeRole"]

    dynamic "condition" {
      for_each = var.flow_log_cloudwatch_iam_role_conditions
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  role       = aws_iam_role.vpc_flow_log_cloudwatch[0].name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch[0].arn
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  name        = var.vpc_flow_log_iam_policy_use_name_prefix ? null : var.vpc_flow_log_iam_policy_name
  name_prefix = var.vpc_flow_log_iam_policy_use_name_prefix ? "${var.vpc_flow_log_iam_policy_name}-" : null
  policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch[0].json
  tags        = merge(var.tags, var.vpc_flow_log_tags)
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  statement {
    sid = "AWSVPCFlowLogsPushToCloudWatch"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = local.flow_log_group_arns
  }
}
