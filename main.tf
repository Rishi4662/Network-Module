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
  source = "./Modules/VPC"
  account_name   = var.account_name
  account_id     = local.current_account_id
  vpc_cidr       = local.selected_account.vpc_cidr
  subnet_details = local.selected_account.subnet_details
  igw_subnets    = local.selected_account.igw_subnets
  nat_subnets    = local.selected_account.nat_subnets
  common_tags    = var.common_tags

  depends_on = [null_resource.validate_account]
}