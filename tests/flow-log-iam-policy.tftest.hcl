# Plan-only checks of the IAM policy the root module builds for CloudWatch flow logs.
# Needs Terraform >= 1.7 and no AWS access: credentials are fake and the caller identity is overridden.

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

override_data {
  target = data.aws_caller_identity.current[0]
  values = {
    account_id = "123456789012"
  }
}

variables {
  name            = "test"
  cidr            = "10.0.0.0/16"
  enable_flow_log = true

  create_flow_log_cloudwatch_iam_role       = true
  flow_log_cloudwatch_log_group_name_suffix = "test"
}

run "module_created_log_group" {
  command = plan

  variables {
    create_flow_log_cloudwatch_log_group = true
  }

  assert {
    condition = flatten([for s in jsondecode(data.aws_iam_policy_document.vpc_flow_log_cloudwatch[0].json).Statement : try(s.Resource, "no Resource")]) == [
      "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpc-flow-log/test:*",
      "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpc-flow-log/test",
    ]
    error_message = "The policy should be scoped to the log group created by the module"
  }
}

run "existing_log_group" {
  command = plan

  variables {
    create_flow_log_cloudwatch_log_group = false
    flow_log_destination_arn             = "arn:aws:logs:us-east-1:123456789012:log-group:/existing/vpc-flow-log"
  }

  assert {
    condition = flatten([for s in jsondecode(data.aws_iam_policy_document.vpc_flow_log_cloudwatch[0].json).Statement : try(s.Resource, "no Resource")]) == [
      "arn:aws:logs:us-east-1:123456789012:log-group:/existing/vpc-flow-log:*",
      "arn:aws:logs:us-east-1:123456789012:log-group:/existing/vpc-flow-log",
    ]
    error_message = "The policy should be scoped to the existing log group passed in `flow_log_destination_arn`"
  }
}

run "existing_log_group_arn_with_wildcard_suffix" {
  command = plan

  variables {
    create_flow_log_cloudwatch_log_group = false
    flow_log_destination_arn             = "arn:aws:logs:us-east-1:123456789012:log-group:/existing/vpc-flow-log:*"
  }

  assert {
    condition = flatten([for s in jsondecode(data.aws_iam_policy_document.vpc_flow_log_cloudwatch[0].json).Statement : try(s.Resource, "no Resource")]) == [
      "arn:aws:logs:us-east-1:123456789012:log-group:/existing/vpc-flow-log:*",
      "arn:aws:logs:us-east-1:123456789012:log-group:/existing/vpc-flow-log",
    ]
    error_message = "A trailing `:*` on `flow_log_destination_arn` should not be repeated"
  }
}
