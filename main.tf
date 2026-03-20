resource "null_resource" "validate_account" {
  count = local.selected_account == null ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERROR: Account ${local.current_account_id} not found in terraform.tfvars' && exit 1"
  }
}


# ---------------------------------------------------------------
# VPC — one instance per account
# ---------------------------------------------------------------
module "vpc" {
  source         = "./Modules/VPC"
  account_name   = var.account_name
  account_id     = local.current_account_id
  vpc_cidr       = local.selected_account.vpc_cidr
  subnet_details = local.selected_account.subnet_details
  igw_subnets    = local.selected_account.igw_subnets
  nat_subnets    = local.selected_account.nat_subnets
  common_tags    = var.common_tags

  depends_on = [null_resource.validate_account]
}

# ---------------------------------------------------------------
# Security Groups — one instance per SG defined in terraform.tfvars
# ---------------------------------------------------------------
module "sg" {
  for_each      = var.security_groups
  source        = "./Modules/SG"
  name          = each.key
  vpc_id        = module.vpc.vpc_id
  ingress_rules = each.value.ingress_rules
  egress_rules  = each.value.egress_rules
  common_tags   = var.common_tags
}

# ---------------------------------------------------------------
# Transit Gateway
# ---------------------------------------------------------------
module "tgw" {
  count = var.create_transit_gateway ? 1 : 0
  
  source                          = "./Modules/TGW"
  name                            = var.transit_gateway.name
  description                     = var.transit_gateway.description
  default_route_table_association = var.transit_gateway.default_route_table_association
  default_route_table_propagation = var.transit_gateway.default_route_table_propagation
  dns_support                     = var.transit_gateway.dns_support
  vpn_ecmp_support                = var.transit_gateway.vpn_ecmp_support
  route_tables                    = var.transit_gateway.route_tables
  vpc_attachments                 = local.tgw_vpc_attachments
  tgw_routes                      = var.transit_gateway.tgw_routes
  available_subnet_ids            = module.vpc.subnet_ids
  common_tags                     = var.common_tags
  
  depends_on = [module.vpc, module.sg]
}

# ---------------------------------------------------------------
# Transit Gateway - Receiving Account (attach to shared TGW)
# ---------------------------------------------------------------
module "tgw_receiving" {
  count = var.is_receiving_account ? 1 : 0
  
  source                          = "./Modules/TGW"
  name                            = var.receiving_account_tgw.name
  shared_transit_gateway_id       = var.receiving_account_tgw.shared_transit_gateway_id
  vpc_attachments                 = var.receiving_account_tgw.vpc_attachments
  available_subnet_ids            = module.vpc.subnet_ids
  route_tables                    = []
  tgw_routes                      = []
  common_tags                     = var.common_tags
  
  depends_on = [module.vpc]
}