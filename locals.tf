locals {
  current_account_id = data.aws_caller_identity.current.account_id
  selected_account = try(var.accounts[local.current_account_id],null)
}