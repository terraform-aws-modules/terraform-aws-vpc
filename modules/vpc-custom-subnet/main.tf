################################################################################
# Custom subnet(s)
################################################################################

resource "aws_subnet" "custom" {
  count = var.create_vpc && length(var.custom_subnets) > 0 ? length(var.custom_subnets) : 0

  vpc_id               = var.vpc_id
  cidr_block           = var.custom_subnets[count.index]["cidr_block"]

  availability_zone    = length(regexall("^[a-z]{2}-", var.custom_subnets[count.index]["az"])) > 0 ? var.custom_subnets[count.index]["az"] : null
  availability_zone_id = length(regexall("^[a-z]{2}-", var.custom_subnets[count.index]["az"])) == 0 ? var.custom_subnets[count.index]["az"] : null

  tags = merge(
    {
      "Name" = format(
        "${var.name}-${var.custom_subnets[count.index]["subnet_suffix"]}-%s",
        var.custom_subnets[count.index]["az"]
      )
    },
    var.tags,
    var.custom_subnets[count.index]["tags"],
  )
}