terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  alias  = var.region
}

module "region_infra" {
  source       = "../main"
  project_name = var.project_name
  region       = var.region

  vpc_cidr                = var.vpc_cidr
  public_subnet_az1_cidr  = var.public_subnet_az1_cidr
  public_subnet_az2_cidr  = var.public_subnet_az2_cidr
  private_subnet_az1_cidr = var.private_subnet_az1_cidr
  private_subnet_az2_cidr = var.private_subnet_az2_cidr
  secure_subnet_az1_cidr  = var.secure_subnet_az1_cidr
  secure_subnet_az2_cidr  = var.secure_subnet_az2_cidr
}
