# ==============================================================================
# Module Sécurité : Security Group RDS (terraform-aws-modules/security-group/aws)
# ==============================================================================

module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "product-intelligence-rds-sg"
  description = "Security group RDS autorisant le port 3306 depuis votre IP locale"
  vpc_id      = module.vpc.vpc_id

  # Accès entrant strictement restreint à votre adresse IP publique
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from local developer machine"
      cidr_blocks = var.my_ip_address
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Environment = var.environment
  }
}

# ==============================================================================
# Module Base de Données : RDS MySQL (terraform-aws-modules/rds/aws)
# ==============================================================================

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "product-intelligence-mysql"

  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" # Paramètre pour DB parameter group
  major_engine_version = "8.0"      # Paramètre pour DB option group
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 50 # Auto-scaling du stockage jusqu'à 50 Go
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username
  port     = 3306

  manage_master_user_password = false
  password                    = var.db_password

  # Phase 1 : accessible publiquement depuis votre PC via l'Internet Gateway
  publicly_accessible = true

  # Subnets publics pour la Phase 1 afin d'assurer le routage Internet direct
  create_db_subnet_group = true
  subnet_ids             = module.vpc.public_subnets

  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Environment = var.environment
  }
}

