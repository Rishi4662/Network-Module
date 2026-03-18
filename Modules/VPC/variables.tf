# ---------------------------------------------------------------
# Account ID (used for naming & tagging)
# ---------------------------------------------------------------
variable "account_id" {
  description = "AWS account identifier (used for naming resources)"
  type        = string
}

# ---------------------------------------------------------------
# Common Tags
# ---------------------------------------------------------------
variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------
# VPC CIDR
# ---------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# ---------------------------------------------------------------
# Subnet Details
# ---------------------------------------------------------------
variable "subnet_details" {
  description = "List of subnet configurations"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

# ---------------------------------------------------------------
# IGW Subnets (Public Subnets)
# ---------------------------------------------------------------
variable "igw_subnets" {
  description = "List of subnet names that should have Internet Gateway access"
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------
# NAT Subnets (Private Subnets)
# ---------------------------------------------------------------
variable "nat_subnets" {
  description = "List of subnet names that should route traffic via NAT Gateway"
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------
# Account Name (Name For All Resources)
# ---------------------------------------------------------------
variable "account_name" {
  description = "Name for the account (used for naming resources)"
  type        = string
}