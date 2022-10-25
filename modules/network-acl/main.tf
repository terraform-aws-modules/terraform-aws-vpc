resource "aws_network_acl" "this" {
  count = var.create ? 1 : 0

  vpc_id = var.vpc_id
  tags   = var.tags
}

resource "aws_network_acl_rule" "inbound" {
  count = var.create && length(var.inbound_acl_rules) > 0 ? length(var.inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.this.id

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

resource "aws_network_acl_rule" "outbound" {
  count = local.create && length(var.outbound_acl_rules) > 0 ? length(var.outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.this.id

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

resource "aws_network_acl_association" "this" {
  count = local.create && length(var.subnet_ids) > 0 ? length(var.subnet_ids) : 0

  network_acl_id = aws_network_acl.this.id
  subnet_id      = var.subnet_ids[count.index]
}
