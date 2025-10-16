# Data source: Availability Zones
data "aws_availability_zones" "available_zones" {}

# Security Group for RDS
resource "aws_security_group" "database_security_group" {
  name        = "database-security-group"
  description = "Enable MySQL/Aurora access on port 3306"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL/Aurora access from ALB"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "database-security-group" }
}

# DB Subnet Group
resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "db-secure-subnets"
  subnet_ids  = [var.secure_subnet_az1_id, var.secure_subnet_az2_id]
  description = "RDS in secure subnet"

  tags = { Name = "db-secure-subnets" }
}

# RDS Instance
resource "aws_db_instance" "db_instance" {
  engine                 = "mysql"
  engine_version         = "8.0.31"
  multi_az               = false
  identifier             = "petclinic"
  username               = var.db_username
  password               = var.db_password
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  publicly_accessible    = var.publicly_accessible
  db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  availability_zone      = data.aws_availability_zones.available_zones.names[0]
  db_name                = var.db_name
  skip_final_snapshot    = true

  tags = { Name = "petclinic-db" }
}

