# ---------------------------------------------------------------
# VPC Outputs
# ---------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs by name"
  value       = module.vpc.subnet_ids
}

# ---------------------------------------------------------------
# Security Group Outputs
# ---------------------------------------------------------------
output "security_group_ids" {
  description = "Security Group IDs by name"
  value = {
    for name, sg in module.sg :
    name => sg.security_group_id
  }
}

# ---------------------------------------------------------------
# Transit Gateway Outputs
# ---------------------------------------------------------------
output "transit_gateway_id" {
  description = "Transit Gateway ID (if created)"
  value       = try(module.tgw[0].transit_gateway_id, null)
}

output "tgw_vpc_attachment_ids" {
  description = "Transit Gateway VPC Attachment IDs"
  value       = try(module.tgw[0].vpc_attachment_ids, {})
}

# ---------------------------------------------------------------
# EC2 Outputs
# ---------------------------------------------------------------
output "ec2_instance_ids" {
  description = "EC2 Instance IDs by name"
  value       = try(module.ec2[0].instance_ids, {})
}

output "ec2_instance_private_ips" {
  description = "EC2 Instance Private IPs"
  value       = try(module.ec2[0].instance_private_ips, {})
}

output "ec2_instance_public_ips" {
  description = "EC2 Instance Public IPs"
  value       = try(module.ec2[0].instance_public_ips, {})
}

output "ec2_instance_details" {
  description = "Detailed EC2 Instance Information"
  value       = try(module.ec2[0].instance_details, {})
}
