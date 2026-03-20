locals {
  current_account_id = data.aws_caller_identity.current.account_id
  selected_account   = try(var.accounts[local.current_account_id], null)

  # Resolve VPC attachments: replace "auto" vpc_id with the actual VPC ID from module.vpc
  tgw_vpc_attachments = [
    for attachment in var.transit_gateway.vpc_attachments :
    {
      name                                = attachment.name
      vpc_id                              = attachment.vpc_id == "auto" ? module.vpc.vpc_id : attachment.vpc_id
      subnet_names                        = attachment.subnet_names
      default_route_table_association     = attachment.default_route_table_association
      default_route_table_propagation     = attachment.default_route_table_propagation
    }
  ]
}