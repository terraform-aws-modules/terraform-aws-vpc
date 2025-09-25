################################################################################
# Flow Log
################################################################################

output "id" {
  description = "The ID of the Flow Log"
  value       = module.flow_log.id
}

output "arn" {
  description = "The ARN of the Flow Log"
  value       = module.flow_log.arn
}

################################################################################
# CloudWatch Log Group
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group created"
  value       = module.flow_log.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch log group created"
  value       = module.flow_log.cloudwatch_log_group_arn
}

################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = module.flow_log.iam_role_name
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.flow_log.iam_role_arn
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.flow_log.iam_role_unique_id
}
