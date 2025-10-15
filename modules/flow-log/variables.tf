variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Flow Log
################################################################################

variable "name" {
  description = "Name to use across resources created"
  type        = string
  default     = ""
}

variable "deliver_cross_account_role" {
  description = "ARN of the IAM role in the destination account used for cross-account delivery of flow logs"
  type        = string
  default     = null
}

variable "destination_options" {
  description = "Describes the destination options for a flow log"
  type = object({
    file_format                = optional(string)
    hive_compatible_partitions = optional(bool)
    per_hour_partition         = optional(bool)
  })
  default = null
}

variable "eni_id" {
  description = "Elastic Network Interface ID to attach to"
  type        = string
  default     = null
}

variable "log_destination_type" {
  description = "Logging destination type. Valid values: `cloud-watch-logs`, `s3`, `kinesis-data-firehose`. Default: `cloud-watch-logs`"
  type        = string
  default     = "cloud-watch-logs"
}

variable "log_destination" {
  description = "ARN of the logging destination"
  type        = string
  default     = null
}

variable "log_format" {
  description = "The fields to include in the flow log record"
  type        = string
  default     = null
}

variable "max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds (1 minute) or `600` seconds (10 minutes). Default: `600`. When `transit_gateway_id` or `transit_gateway_attachment_id` is specified, `max_aggregation_interval` must be 60 seconds (1 minute)"
  type        = number
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID to attach to"
  type        = string
  default     = null
}

variable "traffic_type" {
  description = "The type of traffic to capture. Valid values: `ACCEPT`, `REJECT`, `ALL`"
  type        = string
  default     = "ALL"
}

variable "transit_gateway_attachment_id" {
  description = "Transit Gateway Attachment ID to attach to"
  type        = string
  default     = null
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID to attach to"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID to attach to"
  type        = string
  default     = null
}

variable "flow_log_tags" {
  description = "Map of additional tags to add to the flow log "
  type        = map(string)
  default     = {}
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether to create a CloudWatch log group for the Flow Logs"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  description = "Name of the created CloudWatch log group"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_use_name_prefix" {
  description = "Determines whether the log group name should be used as a prefix"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_class" {
  description = "Specified the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS`"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Set to `0` to keep logs indefinitely"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_tags" {
  description = "Map of additional tags to add to the CloudWatch log group"
  type        = map(string)
  default     = {}
}

################################################################################
# IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether the ECS service IAM role should be created"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

variable "iam_role_trust_policy_permissions" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom trust policy permissions"
  type = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string, "Allow")
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = null
}

variable "iam_role_permissions" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for inline policy permissions"
  type = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string, "Allow")
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = null
}

variable "kinesis_data_firehose_arn" {
  description = "ARN of the existing Kinesis Data Firehose delivery stream. Required when `log_destination_type` is `kinesis-data-firehose`"
  type        = string
  default     = null
}
