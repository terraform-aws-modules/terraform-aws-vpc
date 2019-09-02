provider "aws" {
  region = "eu-west-1"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "../../"

  name = "flow-log-provided-s3-bucket"

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = false
  create_flow_log_cloudwatch_iam_role  = false
  push_flow_log_to_s3                  = true
  flow_log_destination_arn             = aws_s3_bucket.vpf_flow_log.arn

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "vpf_flow_log" {
  bucket = "aws-vpc-module-test-flow-logs"
  policy = data.aws_iam_policy_document.flow_log_s3.json

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

    resources = ["arn:aws:s3:::aws-vpc-module-test-flow-logs/optional_folder/AWSLogs/*"]
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

    resources = ["arn:aws:s3:::aws-vpc-module-test-flow-logs"]
  }
}
