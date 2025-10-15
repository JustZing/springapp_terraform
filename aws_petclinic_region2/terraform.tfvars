region = "us-east-1"
project_name = "awsinfra"

# VPC CIDR block
vpc_cidr = "172.16.0.0/16"

# Public subnets (typically in first two AZs)
public_subnet_az1_cidr  = "172.16.0.0/20"     # us-east-1a
public_subnet_az2_cidr  = "172.16.16.0/20"    # us-east-1b

# Private subnets (for app servers, ECS, EC2, etc.)
private_subnet_az1_cidr = "172.16.32.0/20"    # us-east-1a
private_subnet_az2_cidr = "172.16.48.0/20"    # us-east-1b

# Secure subnets (for databases, caches, etc.)
secure_subnet_az1_cidr  = "172.16.64.0/20"    # us-east-1a
secure_subnet_az2_cidr  = "172.16.80.0/20"    # us-east-1b

