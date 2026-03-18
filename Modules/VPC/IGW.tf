resource "aws_internet_gateway" "this" {
  count  = length(var.igw_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name      = "igw-${var.account_name}"
    AccountId = var.account_id
  })
}

resource "aws_route" "igw" {
  for_each = toset(var.igw_subnets)

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  depends_on = [aws_internet_gateway.this]
}
