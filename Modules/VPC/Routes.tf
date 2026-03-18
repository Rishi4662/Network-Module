resource "aws_route_table" "this" {
  for_each = local.subnets

  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags, {
    Name      = "rt-${each.key}"
    AccountId = var.account_id
  })
}

resource "aws_route_table_association" "this" {
  for_each = local.subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}
