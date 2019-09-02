locals {
  # Only create flow log if user selected to create a vpc as well
  enable_flow_log = var.create_vpc && var.enable_flow_log

  create_flow_log_s3_bucket            = local.enable_flow_log && var.push_flow_log_to_s3 && var.flow_log_destination_arn == ""
  create_flow_log_cloudwatch_iam_role  = local.enable_flow_log && !var.push_flow_log_to_s3 && var.flow_log_cloudwatch_iam_role_arn == ""
  create_flow_log_cloudwatch_log_group = local.enable_flow_log && !var.push_flow_log_to_s3 && var.flow_log_destination_arn == ""

  flow_log_cloudwatch_destination = local.create_flow_log_cloudwatch_log_group ? join("", aws_cloudwatch_log_group.flow_log.*.arn) : var.flow_log_destination_arn
  flow_log_s3_destination         = local.create_flow_log_s3_bucket ? join("", aws_s3_bucket.flow_log.*.arn) : var.flow_log_destination_arn

  flow_log_iam_role_arn = local.create_flow_log_cloudwatch_iam_role ? join("", aws_iam_role.vpc_flow_log_cloudwatch.*.arn) : var.flow_log_cloudwatch_iam_role_arn

  flow_log_destination = var.push_flow_log_to_s3 ? local.flow_log_s3_destination : local.flow_log_cloudwatch_destination

  flow_log_destination_type = var.push_flow_log_to_s3 ? "s3" : "cloud-watch-logs"
}

###################
# Flow Log
###################
resource "aws_flow_log" "this" {
  count = local.enable_flow_log ? 1 : 0

  log_destination_type = local.flow_log_destination_type
  log_destination      = local.flow_log_destination
  iam_role_arn         = local.flow_log_iam_role_arn
  vpc_id               = local.vpc_id
  traffic_type         = var.flow_log_traffic_type
}

#####################
# Flow Log CloudWatch
#####################
resource "aws_cloudwatch_log_group" "flow_log" {
  count = local.create_flow_log_cloudwatch_log_group ? 1 : 0

  name = "/aws/vpc/${local.vpc_id}/vpf-flow-log"

  tags = merge(var.tags, var.vpc_flow_log_tags)
}

#########################
# Flow Log CloudWatch IAM
#########################
resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role == true ? 1 : 0

  name = "flow-log-role-${local.vpc_id}"

  assume_role_policy = join("", data.aws_iam_policy_document.flow_log_cloudwatch_assume_role.*.json)

  tags = merge(var.tags, var.vpc_flow_log_tags)
}

data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  count = local.create_flow_log_cloudwatch_iam_role == true ? 1 : 0

  statement {
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role == true ? 1 : 0

  role       = join("", aws_iam_role.vpc_flow_log_cloudwatch.*.name)
  policy_arn = join("", aws_iam_policy.vpc_flow_log_cloudwatch.*.arn)
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role == true ? 1 : 0

  name   = "vpc-flow-log-to-cloudwatch-${local.vpc_id}"
  policy = join("", data.aws_iam_policy_document.flow_log_cloudwatch.*.json)
}

data "aws_iam_policy_document" "flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role == true ? 1 : 0

  statement {
    sid = "AWSVPCFlowLogsPushToCloudWatch"

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

#############
# Flow Log S3
#############
resource "aws_s3_bucket" "flow_log" {
  count = local.create_flow_log_s3_bucket ? 1 : 0

  bucket = "flow-log-${local.vpc_id}"
  policy = join("", data.aws_iam_policy_document.flow_log_s3.*.json)

  force_destroy = var.flow_log_force_destroy_s3_bucket

  tags = merge(var.tags, var.vpc_flow_log_tags)
}

data "aws_iam_policy_document" "flow_log_s3" {
  count = local.create_flow_log_s3_bucket ? 1 : 0

  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::flow-log-${local.vpc_id}/*"]
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = ["arn:aws:s3:::flow-log-${local.vpc_id}"]
  }
}
