# ---------------------------------------------------------------
# EC2 Instance Configuration
# ---------------------------------------------------------------
variable "instances" {
  description = "Map of EC2 instances to create"
  type = map(object({
    ami                    = string
    instance_type          = string
    subnet_id              = string  # Subnet name (will be resolved to ID)
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

# ---------------------------------------------------------------
# Subnet ID Mapping
# ---------------------------------------------------------------
variable "available_subnet_ids" {
  description = "Map of subnet names to IDs from VPC module (name => id)"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------
# Common Tags
# ---------------------------------------------------------------
variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
