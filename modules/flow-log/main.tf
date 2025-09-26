data "aws_region" "current" {
  count = var.create && var.log_destination_type != "s3" ? 1 : 0

  region = var.region
}

data "aws_caller_identity" "current" {
  count = var.create && var.log_destination_type != "s3" ? 1 : 0
}

data "aws_partition" "current" {
  count = var.create && var.log_destination_type != "s3" ? 1 : 0
}

locals {
  region     = try(data.aws_region.current[0].region, "")
  account_id = try(data.aws_caller_identity.current[0].account_id, "")
  partition  = try(data.aws_partition.current[0].partition, "aws")

  destination_is_cloudwatch = var.log_destination_type == "cloud-watch-logs"
  destination_is_kinesis    = var.log_destination_type == "kinesis-data-firehose"
  destination_is_s3         = var.log_destination_type == "s3"
}

################################################################################
# Flow Log
################################################################################

resource "aws_flow_log" "this" {
  count = var.create ? 1 : 0

  region = var.region

  deliver_cross_account_role = var.deliver_cross_account_role

  dynamic "destination_options" {
    for_each = var.destination_options != null ? [var.destination_options] : []

    content {
      file_format                = destination_options.value.file_format
      hive_compatible_partitions = destination_options.value.hive_compatible_partitions
      per_hour_partition         = destination_options.value.per_hour_partition
    }
  }

  eni_id                        = var.eni_id
  iam_role_arn                  = try(aws_iam_role.this[0].arn, var.iam_role_arn)
  log_destination_type          = var.log_destination_type
  log_destination               = try(aws_cloudwatch_log_group.this[0].arn, var.log_destination)
  log_format                    = var.log_format
  max_aggregation_interval      = var.transit_gateway_attachment_id != null || var.transit_gateway_id != null ? 60 : var.max_aggregation_interval
  subnet_id                     = var.subnet_id
  traffic_type                  = var.traffic_type
  transit_gateway_attachment_id = var.transit_gateway_attachment_id
  transit_gateway_id            = var.transit_gateway_id
  vpc_id                        = var.vpc_id

  tags = merge(
    var.tags,
    { for k, v in { Name = var.name } : k => v if v != "" },
    var.flow_log_tags,
  )
}

################################################################################
# CloudWatch Log Group
################################################################################

locals {
  create_cloudwatch_log_group = var.create && var.create_cloudwatch_log_group && local.destination_is_cloudwatch

  # Try to create a "sane" default log group name based on the resource the flow log is attached to
  eni_suffix        = var.eni_id != null ? "eni/${var.eni_id}" : null
  subnet_suffix     = var.subnet_id != null ? "subnet/${var.subnet_id}" : null
  tgw_attach_suffix = var.transit_gateway_attachment_id != null ? "tgw-attachment/${var.transit_gateway_attachment_id}" : null
  tgw_suffix        = var.transit_gateway_id != null ? "tgw/${var.transit_gateway_id}" : null
  vpc_suffix        = var.vpc_id != null ? "vpc/${var.vpc_id}" : null
  log_group_suffix  = coalesce(local.eni_suffix, local.subnet_suffix, local.tgw_attach_suffix, local.tgw_suffix, local.vpc_suffix, "unknown")

  cloudwatch_log_group_name = coalesce(var.cloudwatch_log_group_name, var.name != "" ? "/aws/flow-log/${var.name}" : "/aws/flow-log/${local.log_group_suffix}")
}

resource "aws_cloudwatch_log_group" "this" {
  count = local.create_cloudwatch_log_group ? 1 : 0

  region = var.region

  name              = var.cloudwatch_log_group_use_name_prefix ? null : local.cloudwatch_log_group_name
  name_prefix       = var.cloudwatch_log_group_use_name_prefix ? "${local.cloudwatch_log_group_name}-" : null
  log_group_class   = var.cloudwatch_log_group_class
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = merge(
    var.tags,
    var.cloudwatch_log_group_tags,
  )
}

################################################################################
# IAM Role
################################################################################

locals {
  create_iam_role = var.create && var.create_iam_role && !local.destination_is_s3

  iam_role_name = coalesce(var.iam_role_name, var.name, replace(local.log_group_suffix, "/", "-"))
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_iam_role ? 1 : 0

  dynamic "statement" {
    for_each = local.destination_is_cloudwatch ? [1] : []

    content {
      sid     = "VPCFlowLogs"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "Service"
        identifiers = ["vpc-flow-logs.amazonaws.com"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [local.account_id]
      }

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:vpc-flow-log/*"]
      }
    }
  }

  dynamic "statement" {
    for_each = local.destination_is_kinesis ? [1] : []

    content {
      sid     = "KinesisDataFirehose"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "Service"
        identifiers = ["firehose.amazonaws.com"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [local.account_id]
      }

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:vpc-flow-log/*"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.iam_role_trust_policy_permissions != null ? var.iam_role_trust_policy_permissions : {}

    content {
      sid           = try(coalesce(statement.value.sid, statement.key))
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role" "this" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(
    var.tags,
    var.iam_role_tags,
  )
}

################################################################################
# IAM Policy
################################################################################

resource "aws_iam_policy" "this" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  policy = data.aws_iam_policy_document.this[0].json

  tags = merge(
    var.tags,
    var.iam_role_tags,
  )
}

data "aws_iam_policy_document" "this" {
  count = local.create_iam_role ? 1 : 0

  dynamic "statement" {
    for_each = local.destination_is_cloudwatch ? [1] : []

    content {
      sid = "CloudWatch"
      actions = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
      ]

      resources = local.create_cloudwatch_log_group ? aws_cloudwatch_log_group.this[*].arn : [var.log_destination]
    }
  }

  dynamic "statement" {
    for_each = local.destination_is_kinesis && var.kinesis_data_firehose_arn != null ? [1] : []

    content {
      sid = "KinesisDataFirehose"
      actions = [
        "logs:CreateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:GetLogDelivery",
        "firehose:TagDeliveryStream",
      ]

      resources = [var.kinesis_data_firehose_arn]
    }
  }

  dynamic "statement" {
    for_each = var.iam_role_permissions != null ? var.iam_role_permissions : {}

    content {
      sid           = try(coalesce(statement.value.sid, statement.key))
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count = local.create_iam_role ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}
