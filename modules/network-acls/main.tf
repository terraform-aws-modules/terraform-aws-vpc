################################################################################
# this Network ACLs
################################################################################
resource "aws_network_acl" "this" {
  count = length(var.acl_name) > 0 ? 1 : 0

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  tags = merge(
    {
      "Name" = format("%s", var.acl_name)
    },
    var.tags
  )
}

resource "aws_network_acl_rule" "this_inbound" {
  count = length(var.inbound_acl_rules) > 0 ? length(var.inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.this[0].id

  egress          = false
  rule_number     = var.inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "this_outbound" {
  count = length(var.outbound_acl_rules) > 0 ? length(var.outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.this[0].id

  egress          = true
  rule_number     = var.outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}
