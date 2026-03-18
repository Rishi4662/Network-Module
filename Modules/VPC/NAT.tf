resource "aws_eip" "nat" {
  count  = length(var.nat_subnets) > 0 ? 1 : 0
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name      = "eip-nat-${var.account_name}"
    AccountId = var.account_id
  })
}

resource "aws_nat_gateway" "this" {
  count         = length(var.nat_subnets) > 0 ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.this[var.igw_subnets[0]].id

  tags = merge(var.common_tags, {
    Name      = "nat-${var.account_name}"
    AccountId = var.account_id
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "nat" {
  for_each = toset(var.nat_subnets)

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id

  depends_on = [aws_nat_gateway.this]
}
