# ==============================================================================
# Zone DNS Privée Route 53 (Service Discovery Interne au VPC)
# ==============================================================================

resource "aws_route53_zone" "private" {
  name    = var.private_dns_zone
  comment = "Zone DNS privee interne au VPC pour la decouverte automatique de la base de donnees"

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  tags = {
    Environment = var.environment
  }
}

# ==============================================================================
# Enregistrement CNAME fixe pour la base de données RDS
# db.product-intelligence.internal -> RDS instance endpoint
# ==============================================================================

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.${var.private_dns_zone}"
  type    = "CNAME"
  ttl     = 300
  records = [module.db.db_instance_address]
}

