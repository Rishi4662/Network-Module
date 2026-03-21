# ---------------------------------------------------------------
# EC2 Instance Outputs
# ---------------------------------------------------------------
output "instance_ids" {
  description = "EC2 Instance IDs"
  value = {
    for name, instance in aws_instance.this :
    name => instance.id
  }
}

output "instance_private_ips" {
  description = "Private IP addresses of EC2 instances"
  value = {
    for name, instance in aws_instance.this :
    name => instance.private_ip
  }
}

output "instance_public_ips" {
  description = "Public IP addresses of EC2 instances (if assigned)"
  value = {
    for name, instance in aws_instance.this :
    name => instance.public_ip if instance.public_ip != null
  }
}

output "instance_details" {
  description = "Detailed information about EC2 instances"
  value = {
    for name, instance in aws_instance.this :
    name => {
      id             = instance.id
      private_ip     = instance.private_ip
      public_ip      = instance.public_ip
      instance_type  = instance.instance_type
      subnet_id      = instance.subnet_id
      availability_zone = instance.availability_zone
    }
  }
}

# ---------------------------------------------------------------
# EBS Volume Outputs
# ---------------------------------------------------------------
output "ebs_volume_ids" {
  description = "IDs of attached EBS volumes"
  value = {
    for key, volume in aws_ebs_volume.attached :
    key => volume.id
  }
}
