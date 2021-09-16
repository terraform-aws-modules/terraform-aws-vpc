locals {
  enable_firewall_logs = var.create_vpc && var.enable_firewall && var.enable_firewall_logs
}

########################
# Network Firewall Logs
########################
resource "aws_networkfirewall_logging_configuration" "this" {
  count        = local.enable_firewall_logs && length(var.firewall_log_types) > 0 ? 1 : 0
  depends_on   = [aws_cloudwatch_log_group.firewall_log]
  firewall_arn = aws_networkfirewall_firewall.this[0].arn

  logging_configuration {
    dynamic "log_destination_config" {
      for_each = var.firewall_log_types

      content {
        log_destination = {
          logGroup = aws_cloudwatch_log_group.firewall_log[log_destination_config.key].id
        }
        log_destination_type = "CloudWatchLogs"
        log_type             = log_destination_config.value
      }
    }
  }
}

###################################
# Network Firewall Logs Cloudwatch
###################################
resource "aws_cloudwatch_log_group" "firewall_log" {
  count = local.enable_firewall_logs ? length(var.firewall_log_types) : 0

  name              = "${var.firewall_log_cloudwatch_log_group_name_prefix}${local.vpc_id}-${lower(element(var.firewall_log_types, count.index))}"
  retention_in_days = var.firewall_log_cloudwatch_log_group_retention_in_days
  kms_key_id        = var.firewall_log_cloudwatch_log_group_kms_key_id

  tags = merge(var.tags, var.firewall_log_tags)
}
