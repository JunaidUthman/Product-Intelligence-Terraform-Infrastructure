output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "IDs des sous-réseaux publics"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "IDs des sous-réseaux privés"
  value       = aws_subnet.private[*].id
}

output "rds_endpoint" {
  description = "Endpoint complet de connexion RDS (host:port)"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_host" {
  description = "Nom d'hôte (DNS) de la base de données RDS"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  description = "Port de connexion MySQL"
  value       = aws_db_instance.mysql.port
}

output "rds_database_name" {
  description = "Nom de la base de données"
  value       = aws_db_instance.mysql.db_name
}

output "rds_username" {
  description = "Utilisateur administrateur de la base"
  value       = aws_db_instance.mysql.username
}

output "database_url_example" {
  description = "Format de la chaîne de connexion DATABASE_URL à utiliser dans vos secrets"
  value       = "mysql://${aws_db_instance.mysql.username}:${var.db_password}@${aws_db_instance.mysql.address}:${aws_db_instance.mysql.port}/${aws_db_instance.mysql.db_name}"
  sensitive   = true
}

