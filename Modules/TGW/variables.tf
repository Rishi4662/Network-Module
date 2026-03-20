# ---------------------------------------------------------------
# Transit Gateway Configuration
# ---------------------------------------------------------------
variable "name" {
  description = "Name of the Transit Gateway"
  type        = string
}

variable "description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = ""
}

variable "shared_transit_gateway_id" {
  description = "ID of existing shared Transit Gateway (leave empty to create new)"
  type        = string
  default     = ""
  # If provided, module will use this existing TGW instead of creating a new one
}

variable "default_route_table_association" {
  description = "Enable default route table association"
  type        = bool
  default     = true
}

variable "default_route_table_propagation" {
  description = "Enable default route table propagation"
  type        = bool
  default     = true
}

variable "dns_support" {
  description = "Enable DNS support"
  type        = bool
  default     = true
}

variable "vpn_ecmp_support" {
  description = "Enable VPN ECMP support"
  type        = bool
  default     = true
}

# ---------------------------------------------------------------
# Transit Gateway Route Tables
# ---------------------------------------------------------------
variable "route_tables" {
  description = "List of route tables to create"
  type = list(object({
    name = string
  }))
  default = []
}

# ---------------------------------------------------------------
# VPC Attachments
# ---------------------------------------------------------------
variable "vpc_attachments" {
  description = "VPC attachments configuration with subnet names"
  type = list(object({
    name                                = string
    vpc_id                              = string
    subnet_names                        = list(string)  # User specifies subnet names
    default_route_table_association     = optional(bool, true)
    default_route_table_propagation     = optional(bool, true)
  }))
  default = []
}

# ---------------------------------------------------------------
# Available Subnet IDs Mapping from VPC
# ---------------------------------------------------------------
variable "available_subnet_ids" {
  description = "Map of available subnet names to IDs from VPC module (name => id)"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------
# Transit Gateway Routes
# ---------------------------------------------------------------
variable "tgw_routes" {
  description = "Transit Gateway routes"
  type = list(object({
    route_table_name           = string
    attachment_name            = string
    destination_cidr_block     = string
    blackhole                  = optional(bool, false)
  }))
  default = []
}

# ---------------------------------------------------------------
# Common Tags
# ---------------------------------------------------------------
variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
