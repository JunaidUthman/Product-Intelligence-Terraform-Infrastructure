# ==============================================================================
# Module Réseau : VPC & Subnets (terraform-aws-modules/vpc/aws)
# ==============================================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "product-intelligence-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Optimisation des coûts Phase 1 (évite ~32$/mois par NAT Gateway)
  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  # Tags requis par AWS Load Balancer Controller pour les ALBs publics
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  # Tags requis par AWS Load Balancer Controller pour les ALBs internes (futurs microservices)
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"     #indiquer au aws lb controller ou exactemet poser le LB
    "kubernetes.io/cluster/${var.cluster_name}" = "owned" #Ce sous-réseau appartient strictement et uniquement à product-intelligence-cluster. Si un autre cluster essaie de l'utiliser, AWS bloquera l'opération.
  }

  tags = {
    Environment = var.environment
  }
}

