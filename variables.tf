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
  default     = ["10.0.10.0/24", "10.0.11.0/24"] #ici, automatiquement le 1er element de la list(10.0.10.0/24) vas etre affecté au premier AZ crée(us-east-1a) etc
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

variable "private_dns_zone" {
  description = "Nom de domaine pour la zone DNS privée Route 53 interne au VPC"
  type        = string
  default     = "product-intelligence.internal"
}

# ==============================================================================
# Variables du Cluster Kubernetes (EKS)
# ==============================================================================

variable "kubernetes_version" {
  description = "Version de Kubernetes pour le cluster EKS"
  type        = string
  default     = "1.30"
}

variable "eks_node_instance_types" {
  description = "Types d'instances EC2 pour les nœuds de travail EKS"
  type        = list(string)
  default     = ["m7i-flex.large"]
}

variable "eks_node_desired_size" {
  description = "Nombre désiré de nœuds de travail EKS"
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "Nombre minimum de nœuds de travail EKS"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Nombre maximum de nœuds de travail EKS (auto-scaling)"
  type        = number
  default     = 4
}



