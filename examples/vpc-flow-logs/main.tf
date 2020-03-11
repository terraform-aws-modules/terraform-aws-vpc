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
