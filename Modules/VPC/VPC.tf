locals {
  subnets = { for s in var.subnet_details : s.name => s }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name      = "vpc-${var.account_name}"
    AccountId = var.account_id
  })
}

resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.common_tags, {
    Name      = each.key
    AccountId = var.account_id
  })
}

# ---------------------------------------------------------------
# Outputs — consumed by SG, EC2, RDS, ALB modules via main.tf
# ---------------------------------------------------------------
output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value = { for k, v in aws_subnet.this : k => v.id }
}
