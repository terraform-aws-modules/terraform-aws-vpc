# VPC flow log - Cloudwatch logs (default)
output "vpc_with_flow_logs_cloudwatch_logs_default_vpc_flow_log_id" {
  description = "The ID of the Flow Log resource"
  value       = module.vpc_with_flow_logs_cloudwatch_logs_default.vpc_flow_log_id
}

output "vpc_with_flow_logs_cloudwatch_logs_default_vpc_flow_log_destination_arn" {
  description = "The ARN of the destination for VPC Flow Logs"
  value       = module.vpc_with_flow_logs_cloudwatch_logs_default.vpc_flow_log_destination_arn
}

output "vpc_with_flow_logs_cloudwatch_logs_default_vpc_flow_log_destination_type" {
  description = "The type of the destination for VPC Flow Logs"
  value       = module.vpc_with_flow_logs_cloudwatch_logs_default.vpc_flow_log_destination_type
}

output "vpc_with_flow_logs_cloudwatch_logs_default_vpc_flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN of the IAM role used when pushing logs to Cloudwatch log group"
  value       = module.vpc_with_flow_logs_cloudwatch_logs_default.vpc_flow_log_cloudwatch_iam_role_arn
}

# VPC flow log - Cloudwatch logs (created separately)
output "vpc_with_flow_logs_cloudwatch_logs_vpc_flow_log_id" {
  description = "The ID of the Flow Log resource"
  value       = module.vpc_with_flow_logs_cloudwatch_logs.vpc_flow_log_id
}

output "vpc_with_flow_logs_cloudwatch_logs_vpc_flow_log_destination_arn" {
  description = "The ARN of the destination for VPC Flow Logs"
  value       = module.vpc_with_flow_logs_cloudwatch_logs.vpc_flow_log_destination_arn
}

output "vpc_with_flow_logs_cloudwatch_logs_vpc_flow_log_destination_type" {
  description = "The type of the destination for VPC Flow Logs"
  value       = module.vpc_with_flow_logs_cloudwatch_logs.vpc_flow_log_destination_type
}

output "vpc_with_flow_logs_cloudwatch_logs_vpc_flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN of the IAM role used when pushing logs to Cloudwatch log group"
  value       = module.vpc_with_flow_logs_cloudwatch_logs.vpc_flow_log_cloudwatch_iam_role_arn
}

# VPC flow log - S3 bucket
output "vpc_flow_logs_s3_bucket_vpc_flow_log_id" {
  description = "The ID of the Flow Log resource"
  value       = module.vpc_with_flow_logs_s3_bucket.vpc_flow_log_id
}

output "vpc_flow_logs_s3_bucket_vpc_flow_log_destination_arn" {
  description = "The ARN of the destination for VPC Flow Logs"
  value       = module.vpc_with_flow_logs_s3_bucket.vpc_flow_log_destination_arn
}

output "vpc_flow_logs_s3_bucket_vpc_flow_log_destination_type" {
  description = "The type of the destination for VPC Flow Logs"
  value       = module.vpc_with_flow_logs_s3_bucket.vpc_flow_log_destination_type
}
