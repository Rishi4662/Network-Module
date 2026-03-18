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
  "464666914899" = {
    vpc_cidr = "10.0.0.0/16"
    subnet_details = [
      { name = "subnet-web", cidr = "10.0.1.0/24", az = "ap-south-1a" },
      { name = "subnet-app", cidr = "10.0.2.0/24", az = "ap-south-1b" },
      { name = "subnet-db",  cidr = "10.0.3.0/24", az = "ap-south-1a" },
      { name = "subnet-pr",  cidr = "10.0.4.0/24", az = "ap-south-1b" }
    ]
    igw_subnets = ["subnet-web", "subnet-pr"]
    nat_subnets = ["subnet-app", "subnet-db"]
  }
}


