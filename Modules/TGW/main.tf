# ---------------------------------------------------------------
# Locals for route table and subnet mapping
# ---------------------------------------------------------------
locals {
  # Use existing TGW or reference the new one
  transit_gateway_id = var.shared_transit_gateway_id != "" ? var.shared_transit_gateway_id : aws_ec2_transit_gateway.this[0].id

  route_table_map = {
    for idx, rt in aws_ec2_transit_gateway_route_table.this :
    var.route_tables[idx].name => rt.id
  }

  # Map VPC attachments and resolve subnet names to IDs
  vpc_attachments_resolved = {
    for attachment in var.vpc_attachments :
    attachment.name => {
      vpc_id                              = attachment.vpc_id
      subnet_ids                          = [for subnet_name in attachment.subnet_names : var.available_subnet_ids[subnet_name]]
      default_route_table_association     = attachment.default_route_table_association
      default_route_table_propagation     = attachment.default_route_table_propagation
    }
  }
}

# ---------------------------------------------------------------
# Transit Gateway (create only if not using shared)
# ---------------------------------------------------------------
resource "aws_ec2_transit_gateway" "this" {
  count                           = var.shared_transit_gateway_id == "" ? 1 : 0
  
  description                     = var.description
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support

  tags = merge(var.common_tags, {
    Name = var.name
  })
}

# ---------------------------------------------------------------
# Transit Gateway Route Table (only if creating new TGW)
# ---------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "this" {
  count = var.shared_transit_gateway_id == "" ? length(var.route_tables) : 0

  transit_gateway_id = local.transit_gateway_id

  tags = merge(var.common_tags, {
    Name = var.route_tables[count.index].name
  })
}

# ---------------------------------------------------------------
# Transit Gateway VPC Attachments
# ---------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = local.vpc_attachments_resolved

  transit_gateway_id      = local.transit_gateway_id
  vpc_id                  = each.value.vpc_id
  subnet_ids              = each.value.subnet_ids
  transit_gateway_default_route_table_association = each.value.default_route_table_association
  transit_gateway_default_route_table_propagation = each.value.default_route_table_propagation

  tags = merge(var.common_tags, {
    Name = each.key
  })

  depends_on = [aws_ec2_transit_gateway_route_table.this]
}

# ---------------------------------------------------------------
# Transit Gateway Routes
# ---------------------------------------------------------------
resource "aws_ec2_transit_gateway_route" "this" {
  for_each = {
    for idx, route in var.tgw_routes :
    "${route.route_table_name}-${route.destination_cidr_block}" => route
  }

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_name].id
  transit_gateway_route_table_id = local.route_table_map[each.value.route_table_name]
  blackhole                      = each.value.blackhole
}
