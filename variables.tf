# ---------------------------------------------------------------
# Common tags — passed into every module
# ---------------------------------------------------------------
variable "common_tags" {
  description = "Common tags applied to every resource across all modules"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------
# VPC
# ---------------------------------------------------------------
variable "accounts" {
  description = "Map of AWS account numbers to their VPC configuration"
  type = map(object({
    vpc_cidr       = string
    subnet_details = list(object({
      name = string
      cidr = string
      az   = string
    }))
    igw_subnets = list(string)
    nat_subnets = list(string)
  }))
}

variable "account_name" {
  description = "Name for the account (used for naming resources)"
  type        = string
}