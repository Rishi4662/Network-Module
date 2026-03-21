# ---------------------------------------------------------------
# Name Resource
# ---------------------------------------------------------------
account_name = "Deloitte"



# ---------------------------------------------------------------
# Common tags
# ---------------------------------------------------------------
common_tags = {
  Environment = "dev"
  Project     = "my-project"
  ManagedBy   = "terraform"
  Owner       = "platform-team"
}

# ---------------------------------------------------------------
# VPC
# ---------------------------------------------------------------
accounts = {
  "123456789" = {
    vpc_cidr = "10.0.0.0/16"
    subnet_details = [
      { name = "subnet-web", cidr = "10.0.1.0/24", az = "ap-south-1a" },
      { name = "subnet-app", cidr = "10.0.2.0/24", az = "ap-south-1b" },
      { name = "subnet-db", cidr = "10.0.3.0/24", az = "ap-south-1a" },
      { name = "subnet-pr", cidr = "10.0.4.0/24", az = "ap-south-1b" }
    ]
    igw_subnets = ["subnet-web", "subnet-pr"]
    nat_subnets = ["subnet-app", "subnet-db"]
  }
}

# ---------------------------------------------------------------
# Security Group
# ---------------------------------------------------------------
security_groups = {
  "web-sg" = {
    description = "Web SG"

    ingress_rules = [
      {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "Custom App Port"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
      }
    ]

    egress_rules = [
      {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "DNS"
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "All Traffic to VPC"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.0.0.0/16"]
      }
    ]
  }
}

# ---------------------------------------------------------------
# Transit Gateway (optional)
# ---------------------------------------------------------------
create_transit_gateway = true

transit_gateway = {
  name        = "my-tgw"
  description = "Transit Gateway for multi-VPC connectivity"
  
  route_tables = [
    {
      name = "main-rt"
    }
  ]
  
  vpc_attachments = [
    {
      name                = "vpc-attachment"
      vpc_id              = "auto"  # Will use the VPC created by the module
      subnet_names        = ["subnet-web", "subnet-app"]  # Select which subnets to attach
      default_route_table_association = true
      default_route_table_propagation = true
    }
  ]
  
  tgw_routes = [
    # {
    #   route_table_name       = "main-rt"
    #   attachment_name        = "vpc-attachment"
    #   destination_cidr_block = "10.0.0.0/16"
    # }
  ]
}

# ---------------------------------------------------------------
# Receiving Account Configuration
# ---------------------------------------------------------------
# Set to true if this account is receiving a shared TGW from another account
is_receiving_account = false

# Configure receiving account details (only used if is_receiving_account = true)
receiving_account_tgw = {
  name                      = "shared-tgw"
  shared_transit_gateway_id = ""  # TGW ID from owner account
  vpc_attachments = [
    # {
    #   name         = "my-vpc-attachment"
    #   vpc_id       = "vpc-xxxxx"
    #   subnet_names = ["subnet-web", "subnet-app"]
    # }
  ]
}

# ---------------------------------------------------------------
# EC2 Instances
# ---------------------------------------------------------------
ec2_instances = {
  "web-server-1" = {
    ami                = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 in ap-south-1 (update with correct AMI ID)
    instance_type      = "t3.micro"
    subnet_id          = "subnet-web"              # Reference to subnet name
    associate_public_ip = true
    monitoring         = false
    root_volume = {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
    }
    ebs_volumes = [
      # {
      #   device_name = "/dev/sdf"
      #   volume_size = 50
      #   volume_type = "gp3"
      #   encrypted   = true
      # }
    ]
    tags = {
      Environment = "production"
      Role        = "web"
    }
  }
  # "app-server-1" = {
  #   ami                = "ami-0c55b159cbfafe1f0"
  #   instance_type      = "t3.small"
  #   subnet_id          = "subnet-app"
  #   associate_public_ip = false
  #   monitoring         = true
  #   root_volume = {
  #     volume_size = 30
  #     volume_type = "gp3"
  #     encrypted   = true
  #   }
  #   tags = {
  #     Environment = "production"
  #     Role        = "application"
  #   }
  # }
}