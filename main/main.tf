# -------------------------------
# Providers for multi-region
# -------------------------------
variable "regions" {
  type    = list(string)
  default = ["ap-south-1", "us-east-1"] # add your regions here
}

provider "aws" {
  alias  = "default"
  region = var.regions[0]
}

# Dynamically create aliased providers for each region
locals {
  region_map = { for r in var.regions : r => r }
}

provider "aws" {
  for_each = local.region_map
  alias    = each.key
  region   = each.key
}

# -------------------------------
# Local CIDRs per region
# -------------------------------
variable "project_name" {}
variable "vpc_cidrs" {
  type = map(object({
    vpc                  : string
    public_subnet_az1    : string
    public_subnet_az2    : string
    private_subnet_az1   : string
    private_subnet_az2   : string
    secure_subnet_az1    : string
    secure_subnet_az2    : string
  }))
}

# -------------------------------
# VPC Module
# -------------------------------
module "vpc" {
  for_each  = local.region_map
  source    = "../modules/vpc"
  providers = { aws = aws[each.key] }

  region                  = each.key
  project_name            = var.project_name
  vpc_cidr                = var.vpc_cidrs[each.key].vpc
  public_subnet_az1_cidr  = var.vpc_cidrs[each.key].public_subnet_az1
  public_subnet_az2_cidr  = var.vpc_cidrs[each.key].public_subnet_az2
  private_subnet_az1_cidr = var.vpc_cidrs[each.key].private_subnet_az1
  private_subnet_az2_cidr = var.vpc_cidrs[each.key].private_subnet_az2
  secure_subnet_az1_cidr  = var.vpc_cidrs[each.key].secure_subnet_az1
  secure_subnet_az2_cidr  = var.vpc_cidrs[each.key].secure_subnet_az2
}

# -------------------------------
# NAT Gateway Module
# -------------------------------
module "natgateway" {
  for_each  = local.region_map
  source    = "../modules/natgateway"
  providers = { aws = aws[each.key] }

  public_subnet_az1_id  = module.vpc[each.key].public_subnet_az1_id
  public_subnet_az2_id  = module.vpc[each.key].public_subnet_az2_id
  private_subnet_az1_id = module.vpc[each.key].private_subnet_az1_id
  private_subnet_az2_id = module.vpc[each.key].private_subnet_az2_id
  vpc_id                = module.vpc[each.key].vpc_id
  internet_gateway      = module.vpc[each.key].internet_gateway
}

# -------------------------------
# Security Group Module
# -------------------------------
module "security_group" {
  for_each  = local.region_map
  source    = "../modules/security_group"
  providers = { aws = aws[each.key] }

  vpc_id = module.vpc[each.key].vpc_id
}

# -------------------------------
# ALB Module
# -------------------------------
module "application_load_balancer" {
  for_each  = local.region_map
  source    = "../modules/alb"
  providers = { aws = aws[each.key] }

  project_name          = var.project_name
  alb_security_group_id = module.security_group[each.key].alb_security_group_id
  public_subnet_az1_id  = module.vpc[each.key].public_subnet_az1_id
  public_subnet_az2_id  = module.vpc[each.key].public_subnet_az2_id
  vpc_id                = module.vpc[each.key].vpc_id
}

# -------------------------------
# EC2 Module
# -------------------------------
module "ec2" {
  for_each  = local.region_map
  source    = "../modules/ec2"
  providers = { aws = aws[each.key] }

  region = each.key
  vpc_id = module.vpc[each.key].vpc_id
}

# -------------------------------
# RDS Module
# -------------------------------
module "rds" {
  for_each  = local.region_map
  source    = "../modules/rds"
  providers = { aws = aws[each.key] }

  vpc_id                = module.vpc[each.key].vpc_id
  alb_security_group_id = module.security_group[each.key].alb_security_group_id
  secure_subnet_az1_id  = module.vpc[each.key].secure_subnet_az1_id
  secure_subnet_az2_id  = module.vpc[each.key].secure_subnet_az2_id
}

# -------------------------------
# Auto Scaling Group Module
# -------------------------------
module "asg" {
  for_each  = local.region_map
  source    = "../modules/asg"
  providers = { aws = aws[each.key] }

  project_name              = var.project_name
  rds_db_endpoint           = module.rds[each.key].rds_db_endpoint
  private_subnet_az1_id     = module.vpc[each.key].private_subnet_az1_id
  private_subnet_az2_id     = module.vpc[each.key].private_subnet_az2_id
  application_load_balancer = module.application_load_balancer[each.key].application_load_balancer
  alb_target_group_arn      = module.application_load_balancer[each.key].alb_target_group_arn
  alb_security_group_id     = module.security_group[each.key].alb_security_group_id
  iam_ec2_instance_profile  = module.ec2[each.key].iam_ec2_instance_profile
}
