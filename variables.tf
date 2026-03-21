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
    vpc_cidr = string
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

# ---------------------------------------------------------------
# Security Group
# ---------------------------------------------------------------
variable "security_groups" {
  description = "Security group definitions"
  type = map(object({
    description = string

    ingress_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))

    egress_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
  default = {}
}

# ---------------------------------------------------------------
# Transit Gateway
# ---------------------------------------------------------------
variable "create_transit_gateway" {
  description = "Enable creation of Transit Gateway"
  type        = bool
  default     = false
}

variable "transit_gateway" {
  description = "Transit Gateway configuration"
  type = object({
    name                            = string
    description                     = optional(string, "")
    default_route_table_association = optional(bool, true)
    default_route_table_propagation = optional(bool, true)
    dns_support                     = optional(bool, true)
    vpn_ecmp_support                = optional(bool, true)
    route_tables = optional(list(object({
      name = string
    })), [])
    vpc_attachments = optional(list(object({
      name                                = string
      vpc_id                              = string  # Use "auto" to use the created VPC, or specify a VPC ID
      subnet_names                        = list(string)  # Specify subnet names to attach
      default_route_table_association     = optional(bool, true)
      default_route_table_propagation     = optional(bool, true)
    })), [])
    tgw_routes = optional(list(object({
      route_table_name       = string
      attachment_name        = string
      destination_cidr_block = string
      blackhole              = optional(bool, false)
    })), [])
  })
  default = {
    name = ""
  }
}

# ---------------------------------------------------------------
# Receiving Account Configuration (for RAM-shared TGW)
# ---------------------------------------------------------------
variable "is_receiving_account" {
  description = "Set to true if this account is receiving a shared TGW from another account"
  type        = bool
  default     = false
}

variable "receiving_account_tgw" {
  description = "Configuration for receiving account to attach to shared TGW"
  type = object({
    name                      = optional(string, "shared-tgw")
    shared_transit_gateway_id = string  # TGW ID from owner account
    vpc_attachments = optional(list(object({
      name                                = string
      vpc_id                              = string
      subnet_names                        = list(string)
      default_route_table_association     = optional(bool, true)
      default_route_table_propagation     = optional(bool, true)
    })), [])
  })
  default = {
    shared_transit_gateway_id = ""
  }
}

# ---------------------------------------------------------------
# EC2 Instances
# ---------------------------------------------------------------
variable "ec2_instances" {
  description = "EC2 instances to deploy"
  type = map(object({
    ami                    = string
    instance_type          = string
    subnet_id              = string  # Subnet name to attach to
    security_group_ids     = optional(list(string), [])
    associate_public_ip    = optional(bool, true)
    disable_api_termination = optional(bool, false)
    monitoring             = optional(bool, false)
    root_volume = optional(object({
      volume_size           = optional(number, 20)
      volume_type           = optional(string, "gp3")
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
    }), {})
    ebs_volumes = optional(list(object({
      device_name           = string
      volume_size           = number
      volume_type           = optional(string, "gp3")
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}