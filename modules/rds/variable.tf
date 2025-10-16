# VPC & Networking
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where RDS will be deployed"
}

variable "secure_subnet_az1_id" {
  type        = string
  description = "First secure subnet ID for RDS"
}

variable "secure_subnet_az2_id" {
  type        = string
  description = "Second secure subnet ID for RDS"
}

variable "alb_security_group_id" {
  type        = string
  description = "ALB security group allowed to access RDS"
}

# Database credentials
variable "db_username" {
  type        = string
  description = "RDS master username"
}

variable "db_password" {
  type        = string
  description = "RDS master password"
  sensitive   = true
}

# Optional RDS settings
variable "db_instance_class" {
  type        = string
  description = "RDS instance type"
  default     = "db.t2.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "RDS allocated storage in GB"
  default     = 20
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "petclinic"
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether the DB is publicly accessible"
  default     = true
}

