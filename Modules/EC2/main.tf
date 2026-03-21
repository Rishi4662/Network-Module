# ---------------------------------------------------------------
# Locals for subnet and security group mapping
# ---------------------------------------------------------------
locals {
  # Map instances with resolved subnet IDs
  instances_resolved = {
    for instance_name, instance_config in var.instances :
    instance_name => {
      ami                     = instance_config.ami
      instance_type           = instance_config.instance_type
      subnet_id               = var.available_subnet_ids[instance_config.subnet_id]
      security_group_ids      = instance_config.security_group_ids
      associate_public_ip     = instance_config.associate_public_ip
      disable_api_termination = instance_config.disable_api_termination
      monitoring              = instance_config.monitoring
      root_volume             = instance_config.root_volume
      ebs_volumes             = instance_config.ebs_volumes
      tags                    = instance_config.tags
    }
  }

  # Flatten EBS volumes for attachment
  ebs_volume_attachments = merge([
    for instance_name, instance_config in local.instances_resolved :
    {
      for idx, volume in instance_config.ebs_volumes :
      "${instance_name}-vol-${idx}" => {
        instance_name   = instance_name
        device_name     = volume.device_name
        volume_size     = volume.volume_size
        volume_type     = volume.volume_type
        encrypted       = volume.encrypted
      }
    }
  ]...)
}

# ---------------------------------------------------------------
# EC2 Instances
# ---------------------------------------------------------------
resource "aws_instance" "this" {
  for_each = local.instances_resolved

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  associate_public_ip_address = each.value.associate_public_ip
  disable_api_termination = each.value.disable_api_termination
  monitoring             = each.value.monitoring

  # Root volume configuration
  root_block_device {
    volume_size           = each.value.root_volume.volume_size
    volume_type           = each.value.root_volume.volume_type
    delete_on_termination = each.value.root_volume.delete_on_termination
    encrypted             = each.value.root_volume.encrypted

    tags = merge(var.common_tags, {
      Name = "${each.key}-root"
    })
  }

  tags = merge(var.common_tags, each.value.tags, {
    Name = each.key
  })
}

# ---------------------------------------------------------------
# Create Additional EBS Volumes
# ---------------------------------------------------------------
resource "aws_ebs_volume" "attached" {
  for_each = local.ebs_volume_attachments

  availability_zone = aws_instance.this[each.value.instance_name].availability_zone
  size               = each.value.volume_size
  type               = each.value.volume_type
  encrypted          = each.value.encrypted

  tags = merge(var.common_tags, {
    Name = each.key
  })
}

# ---------------------------------------------------------------
# Attach EBS Volumes to Instances
# ---------------------------------------------------------------
resource "aws_volume_attachment" "ebs" {
  for_each = local.ebs_volume_attachments

  instance_id   = aws_instance.this[each.value.instance_name].id
  volume_id     = aws_ebs_volume.attached[each.key].id
  device_name   = each.value.device_name
}
