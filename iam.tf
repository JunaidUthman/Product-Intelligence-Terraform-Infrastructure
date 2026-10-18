# ==============================================================================
# Rôles IAM pour Service Accounts (IRSA - IAM Roles for Service Accounts)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Rôle IAM pour AWS Load Balancer Controller (LBC)
# Permet au contrôleur dans le pod d'interagir avec les API EC2 et ELB d'AWS
# pour créer automatiquement les Application Load Balancers (ALB).
# ------------------------------------------------------------------------------
module "aws_lbc_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "aws-lbc-${var.cluster_name}"

  # Attache automatiquement la politique officielle AWSLoadBalancerControllerIAMPolicy
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn # Pointe vers l'URL d'identité de votre cluster EKS
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"] # Vous dites à AWS : "Même si le jeton d'authentification vient du bon cluster EKS, n'autorise l'accès qu'au Pod qui utilise le ServiceAccount nommé aws-load-balancer-controller et qui tourne strictement dans le namespace kube-system
    }
  }

  tags = {
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# 2. Rôle IAM pour AWS EBS CSI Driver
# Permet au contrôleur EBS de Kubernetes de provisionner et d'attacher
# dynamiquement des disques AWS EBS aux pods ayant des PersistentVolumeClaims.
# ------------------------------------------------------------------------------
module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "ebs-csi-${var.cluster_name}"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn 
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"] 
    }
  }

  tags = {
    Environment = var.environment
  }
}

