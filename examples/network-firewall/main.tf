provider "aws" {
  region = local.region
}

locals {
  region = "ap-southeast-1"
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../"
  cidr   = "10.0.0.0/16"
  name   = "multiple-nat-firewall"
  azs    = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

  enable_firewall      = true
  enable_firewall_logs = true
  firewall_log_types   = ["FLOW", "ALERT"]
  firewall_policy_arn  = aws_networkfirewall_firewall_policy.example.arn

  firewall_subnets = [
    "10.0.3.0/28",
    "10.0.3.16/28",
    "10.0.3.32/28",
  ]

  private_subnets = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]

  public_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
  ]
}

################################################################################
# Network firewall Policy
################################################################################

resource "aws_networkfirewall_firewall_policy" "example" {
  name = "example"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.example.arn
    }
  }
}
resource "aws_networkfirewall_rule_group" "example" {
  description = "Stateless Rate Limiting Rule"
  capacity    = 100
  name        = "example"
  type        = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        custom_action {
          action_definition {
            publish_metric_action {
              dimension {
                value = "2"
              }
            }
          }
          action_name = "ExampleMetricsAction"
        }
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:pass", "ExampleMetricsAction"]
            match_attributes {
              source {
                address_definition = "1.2.3.4/32"
              }
              source_port {
                from_port = 443
                to_port   = 443
              }
              destination {
                address_definition = "124.1.1.5/32"
              }
              destination_port {
                from_port = 443
                to_port   = 443
              }
              protocols = [6]
              tcp_flag {
                flags = ["SYN"]
                masks = ["SYN", "ACK"]
              }
            }
          }
        }
      }
    }
  }

}


