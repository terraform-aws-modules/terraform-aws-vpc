locals {
  #aws_managed_rules_prefix_arn = "arn:aws:network-firewall:${data.aws_region.current.name}:aws-managed:stateful-rulegroup"
  aws_managed_rules_prefix_arn = "arn:aws:network-firewall:us-east-2:aws-managed:stateful-rulegroup" // TODO - review this region

  // TODO - Review these rules
  firewall_managed_rules = distinct(concat([
    "AbusedLegitMalwareDomainsStrictOrder",
    "BotNetCommandAndControlDomainsStrictOrder",
    "AbusedLegitBotNetCommandAndControlDomainsStrictOrder",
    "MalwareDomainsStrictOrder",
    "ThreatSignaturesIOCStrictOrder",
    "ThreatSignaturesPhishingStrictOrder",
    "ThreatSignaturesBotnetWebStrictOrder",
    "ThreatSignaturesEmergingEventsStrictOrder",
    "ThreatSignaturesDoSStrictOrder",
    "ThreatSignaturesMalwareWebStrictOrder",
    "ThreatSignaturesExploitsStrictOrder",
    "ThreatSignaturesWebAttacksStrictOrder",
    "ThreatSignaturesScannersStrictOrder",
    "ThreatSignaturesBotnetStrictOrder",
    "ThreatSignaturesMalwareStrictOrder",
    "ThreatSignaturesMalwareCoinminingStrictOrder",
    "ThreatSignaturesFUPStrictOrder",
    "ThreatSignaturesSuspectStrictOrder",
    "ThreatSignaturesBotnetWindowsStrictOrder",
  ], var.firewall_managed_rules))

  name = "${var.name}-network-firewall"
}

module "firewall" {
  source = "terraform-aws-modules/network-firewall/aws"

  count = var.create_network_firewall ? 1 : 0

  # Firewall
  name        = local.name
  description = var.description

  # Only for example
  delete_protection                 = var.delete_protection
  firewall_policy_change_protection = var.firewall_policy_change_protection
  subnet_change_protection          = var.subnet_change_protection

  vpc_id = aws_vpc.this[0].id
  subnet_mapping = { for subnet_id in aws_subnet.firewall.*.id :
    "subnet-${subnet_id}" => {
      subnet_id       = subnet_id
      ip_address_type = "IPV4"
    }
  }

  # Logging configuration
  create_logging_configuration = true
  logging_configuration_destination_config = [
    {
      log_destination = {
        logGroup = module.logs_alerts[0].cloudwatch_log_group_name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    },
    {
      log_destination = {
        logGroup = module.logs_flow[0].cloudwatch_log_group_name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    },
  ]

  encryption_configuration = {
    key_id = module.kms[0].key_arn
    type   = "CUSTOMER_KMS"
  }

  # Policy
  policy_name        = local.name
  policy_description = "Default network firewall policy for ${local.name}"

  # policy_stateful_rule_group_reference = {}
  policy_stateful_rule_group_reference = {
    for i, rule_group in local.firewall_managed_rules : rule_group => {
      resource_arn = "${local.aws_managed_rules_prefix_arn}/${rule_group}",
      priority     = i + 1,
    }
  }

  policy_stateful_engine_options = {
    rule_order = "STRICT_ORDER"
  }
  policy_stateless_default_actions          = ["aws:forward_to_sfe"]
  policy_stateless_fragment_default_actions = ["aws:forward_to_sfe"]

  tags = var.tags // TODO - review these tags

  depends_on = [module.kms]
}

module "logs_alerts" {
  source       = "git::https://github.com/withclutch/terraform-modules-registry?ref=aws-log-group_v1.194"

  count = var.create_network_firewall ? 1 : 0

  name        = "${local.name}-alerts"
  tenant      = var.tenant
  region      = var.region
  environment = var.environment

  retention_in_days                  = var.logs_retention_in_days
  kms_key_arn                        = var.logs_kms_key_arn
  create_datadog_subscription_filter = true
}

// TODO review if this module is really necessary
module "logs_flow" {
  source      = "git::https://github.com/withclutch/terraform-modules-registry?ref=aws-log-group_v1.194"

  count       = var.create_network_firewall ? 1 : 0

  name        = "${local.name}-flow" // TODO - review this name
  tenant      = var.tenant
  region      = var.region
  environment = var.environment

  retention_in_days                  = var.logs_retention_in_days
  kms_key_arn                        = var.logs_kms_key_arn
  create_datadog_subscription_filter = false
}

module "kms" {
  source      = "git::https://github.com/withclutch/terraform-modules-registry?ref=aws-kms_v1.194"

  count = var.create_network_firewall ? 1 : 0

  description = "KMS key used for ${var.name} AWS Network Firewall"
  name        = var.name // TODO - review this name
  region      = var.region
  environment = var.environment
  namespace   = var.namespace
  tenant      = var.tenant
  tags        = var.tags
}

