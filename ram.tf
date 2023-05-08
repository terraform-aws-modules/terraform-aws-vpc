################################################################################
# Resource Access Manager
################################################################################

resource "aws_ram_resource_share" "this" {
  count = var.create_vpc && var.share_vpc ? 1 : 0

  name                      = coalesce(var.ram_name, var.name)
  allow_external_principals = var.ram_allow_external_principals

  tags = merge(
    var.tags,
    { Name = coalesce(var.ram_name, var.name) },
    var.ram_tags,
  )
}

resource "aws_ram_resource_association" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  resource_arn       = element(aws_subnet.private[*].arn, count.index)
  resource_share_arn = aws_ram_resource_share.this[0].id
}

resource "aws_ram_resource_association" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  resource_arn       = element(aws_subnet.public[*].arn, count.index)
  resource_share_arn = aws_ram_resource_share.this[0].id
}

resource "aws_ram_principal_association" "this" {
  for_each           = toset(var.ram_principals)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this[0].arn
}
