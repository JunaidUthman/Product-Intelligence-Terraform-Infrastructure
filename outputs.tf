output "vpc_id" {
  description = "ID du VPC créé"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "IDs des sous-réseaux publics"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "IDs des sous-réseaux privés"
  value       = module.vpc.private_subnets
}

output "rds_security_group_id" {
  description = "ID du Security Group de la base RDS"
  value       = module.rds_security_group.security_group_id
}

output "rds_endpoint" {
  description = "Endpoint direct AWS RDS (host:port)"
  value       = module.db.db_instance_endpoint
}

output "rds_host" {
  description = "Nom d'hôte direct AWS RDS"
  value       = module.db.db_instance_address
}

output "rds_port" {
  description = "Port de connexion MySQL"
  value       = module.db.db_instance_port
}

output "rds_database_name" {
  description = "Nom de la base de données"
  value       = module.db.db_instance_name
}

output "rds_username" {
  description = "Utilisateur administrateur de la base"
  value       = module.db.db_instance_username
}

# ==============================================================================
# Sorties DNS Privées Route 53 (Nom fixe pour Kubernetes)
# ==============================================================================

output "private_db_host" {
  description = "Nom d'hôte DNS privé et fixe pour le cluster Kubernetes"
  value       = trimsuffix(aws_route53_record.db.fqdn, ".")
}

output "internal_database_url" {
  description = "Chaîne de connexion permanente utilisant le DNS privé Route 53"
  value       = "mysql://${module.db.db_instance_username}:${var.db_password}@${trimsuffix(aws_route53_record.db.fqdn, ".")}:${module.db.db_instance_port}/${module.db.db_instance_name}"
  sensitive   = true
}

output "external_database_url_local_dev" {
  description = "Chaîne de connexion directe via Internet pour tester depuis votre machine locale"
  value       = "mysql://${module.db.db_instance_username}:${var.db_password}@${module.db.db_instance_address}:${module.db.db_instance_port}/${module.db.db_instance_name}"
  sensitive   = true
}

# ==============================================================================
# Sorties EKS & IAM (Pour kubectl et l'AWS Load Balancer Controller)
# ==============================================================================

output "cluster_name" {
  description = "Nom du cluster EKS créé"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint API server du cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  description = "Commande pour configurer votre kubectl local vers le nouveau cluster EKS"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "aws_lbc_role_arn" {
  description = "ARN du rôle IAM IRSA pour l'AWS Load Balancer Controller"
  value       = module.aws_lbc_irsa.iam_role_arn
}

