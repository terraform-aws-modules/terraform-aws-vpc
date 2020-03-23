#############################
# VPC flow logs => S3 bucket
#############################
module "vpc_with_flow_logs_s3_bucket" {
  source = "../../"

  name = "vpc-flow-logs-s3-bucket"

  cidr = "10.30.0.0/16"

  azs            = ["eu-west-1a"]
  public_subnets = ["10.30.101.0/24"]

  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.s3_bucket.this_s3_bucket_arn

  vpc_flow_log_tags = {
    Name = "vpc-flow-logs-s3-bucket"
  }
}

############
# S3 bucket
############
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 1.0"

  bucket        = local.s3_bucket_name
  policy        = data.aws_iam_policy_document.flow_log_s3.json
  force_destroy = true

  tags = {
    Name = "vpc-flow-logs-s3-bucket"
  }
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
