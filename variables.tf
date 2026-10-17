variable "aws_region" {
  description = "Région AWS où déployer l'infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nom de l'environnement (ex: dev, prod)"
  type        = string
  default     = "prod"
}

variable "cluster_name" {
  description = "Nom du cluster EKS (doit correspondre à l'argument --cluster-name du contrôleur ALB)"
  type        = string
  default     = "realestate-prod-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zones de disponibilité AWS (au moins 2 pour la haute disponibilité)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks des sous-réseaux publics (avec tags pour ALB)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks des sous-réseaux privés (futur EKS)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "db_name" {
  description = "Nom de la base de données MySQL"
  type        = string
  default     = "product_intelligence"
}

variable "db_username" {
  description = "Nom d'utilisateur administrateur de la base MySQL"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Mot de passe de la base de données (garder secret)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Type d'instance pour RDS MySQL (ex: db.t4g.micro, db.t3.micro)"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Taille du stockage RDS alloué en Go"
  type        = number
  default     = 20
}

variable "my_ip_address" {
  description = "Votre adresse IP publique avec /32 (ex: 82.64.12.34/32) pour autoriser l'accès depuis votre PC"
  type        = string
}

