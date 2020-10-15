###########################################################
# VPC flow logs => Cloudwatch logs (created automatically)
###########################################################
module "vpc_with_flow_logs_cloudwatch_logs_default" {
  source = "../../"

  name = "vpc-flow-logs-cloudwatch-logs-default"

  cidr = "10.10.0.0/16"

  azs            = ["eu-west-1a"]
  public_subnets = ["10.10.101.0/24"]

  # Cloudwatch log group and IAM role will be created
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  vpc_flow_log_tags = {
    Name = "vpc-flow-logs-cloudwatch-logs-default"
  }
}

########################################################
# VPC flow logs => Cloudwatch logs (CloudWatch Log Group and IAM role created separately)
########################################################
module "vpc_with_flow_logs_cloudwatch_logs" {
  source = "../../"

  name = "vpc-flow-logs-cloudwatch-logs"

  cidr = "10.20.0.0/16"

  azs            = ["eu-west-1a"]
  public_subnets = ["10.20.101.0/24"]

  enable_flow_log                  = true
  flow_log_destination_type        = "cloud-watch-logs"
  flow_log_destination_arn         = aws_cloudwatch_log_group.flow_log.arn
  flow_log_cloudwatch_iam_role_arn = aws_iam_role.vpc_flow_log_cloudwatch.arn

  vpc_flow_log_tags = {
    Name = "vpc-flow-logs-cloudwatch-logs"
  }
}

#######################
# CloudWatch Log group
#######################
resource "aws_cloudwatch_log_group" "flow_log" {
  name = local.cloudwatch_log_group_name
}

###########
# IAM Role
###########
resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
  name_prefix        = "vpc-flow-log-role-"
  assume_role_policy = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role.json
}

data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
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
  role       = aws_iam_role.vpc_flow_log_cloudwatch.name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch.arn
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  name_prefix = "vpc-flow-log-cloudwatch-"
  policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch.json
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
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

