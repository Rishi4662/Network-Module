# ---------------------------------------------------------------
# Transit Gateway Outputs
# ---------------------------------------------------------------
output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = local.transit_gateway_id
}

output "transit_gateway_arn" {
  description = "Transit Gateway ARN (null if using existing shared)"
  value       = try(aws_ec2_transit_gateway.this[0].arn, null)
}

output "transit_gateway_owner_id" {
  description = "Transit Gateway Owner ID (null if using existing shared)"
  value       = try(aws_ec2_transit_gateway.this[0].owner_id, null)
}

# ---------------------------------------------------------------
# Route Table Outputs
# ---------------------------------------------------------------
output "route_table_ids" {
  description = "Transit Gateway Route Table IDs"
  value       = {
    for idx, rt in aws_ec2_transit_gateway_route_table.this :
    var.route_tables[idx].name => rt.id
  }
}

# ---------------------------------------------------------------
# VPC Attachment Outputs
# ---------------------------------------------------------------
output "vpc_attachment_ids" {
  description = "VPC Attachment IDs"
  value       = {
    for name, attachment in aws_ec2_transit_gateway_vpc_attachment.this :
    name => attachment.id
  }
}

output "vpc_attachment_arns" {
  description = "VPC Attachment ARNs"
  value       = {
    for name, attachment in aws_ec2_transit_gateway_vpc_attachment.this :
    name => attachment.arn
  }
}
