provider "aws" {
  region = "eu-west-1"
}

locals {
  s3_bucket_name            = "vpc-flow-logs-to-s3-${random_pet.this.id}"
  cloudwatch_log_group_name = "vpc-flow-logs-to-cloudwatch-${random_pet.this.id}"
}

resource "random_pet" "this" {
  length = 2
}

###########################################################
# VPC flow logs => Cloudwatch logs (created automatically)
###########################################################
module "vpc_with_flow_logs_to_cloudwatch_logs_default" {
  source = "../../"

  name = "vpc-flow-logs-cloudwatch-logs-default"

  cidr = "10.10.0.0/16"

  azs            = ["eu-west-1a"]
  public_subnets = ["10.10.101.0/24"]

  # Cloudwatch log group and IAM role will be created
  enable_flow_log = true
}

########################################################
# VPC flow logs => Cloudwatch logs (created separately)
########################################################
module "vpc_with_flow_logs_to_cloudwatch_logs" {
  source = "../../"

  name = "vpc-flow-logs-cloudwatch-logs"

  cidr = "10.20.0.0/16"

  azs            = ["eu-west-1a"]
  public_subnets = ["10.20.101.0/24"]

  enable_flow_log           = true
  flow_log_destination_type = "cloud-watch-logs"
  flow_log_destination_arn  = aws_cloudwatch_log_group.flow_log.arn
}

#############################
# VPC flow logs => S3 bucket
#############################
module "vpc_with_flow_logs_to_s3_bucket" {
  source = "../../"

  name = "vpc-flow-logs-s3-bucket"

  cidr = "10.30.0.0/16"

  azs            = ["eu-west-1a"]
  public_subnets = ["10.30.101.0/24"]

  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.vpc_flow_logs_s3_bucket.this_s3_bucket_arn
}

#######################
# CloudWatch Log group
#######################
resource "aws_cloudwatch_log_group" "flow_log" {
  name = local.cloudwatch_log_group_name
}

############
# S3 bucket
############
module "vpc_flow_logs_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 1.0"

  bucket        = local.s3_bucket_name
  policy        = data.aws_iam_policy_document.flow_log_s3.json
  force_destroy = true
}

data "aws_iam_policy_document" "flow_log_s3" {
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

    resources = ["arn:aws:s3:::${local.s3_bucket_name}/AWSLogs/*"]
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

    resources = ["arn:aws:s3:::${local.s3_bucket_name}"]
  }
}
