# ==============================================================================
# Security Group pour RDS MySQL
# ==============================================================================

resource "aws_security_group" "rds" {
  name        = "product-intelligence-rds-sg"
  description = "Autorise le port MySQL 3306 depuis votre IP locale"
  vpc_id      = aws_vpc.main.id

  # Accès entrant limité strictement à votre adresse IP publique
  ingress {
    description = "MySQL access from local developer machine"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_address]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "product-intelligence-rds-sg"
  }
}

# ==============================================================================
# DB Subnet Group
# ==============================================================================

resource "aws_db_subnet_group" "rds" {
  name        = "product-intelligence-db-subnet-group"
  description = "Subnet group pour RDS MySQL (subnets publics en Phase 1 pour accessibilite)"
  subnet_ids  = aws_subnet.public[*].id

  tags = {
    Name = "product-intelligence-db-subnet-group"
  }
}

# ==============================================================================
# Instance RDS MySQL
# ==============================================================================

resource "aws_db_instance" "mysql" {
  identifier            = "product-intelligence-mysql"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 50
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Phase 1 : accessible publiquement (restreint par le Security Group a votre IP)
  publicly_accessible = true

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "product-intelligence-mysql"
  }
}
