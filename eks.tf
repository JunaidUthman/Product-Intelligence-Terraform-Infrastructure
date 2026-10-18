# ==============================================================================
# Module Cluster Kubernetes Managé : AWS EKS (terraform-aws-modules/eks/aws)
# ==============================================================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  # BONNE PRATIQUE (Accès au Control Plane) :
  # - Accès public activé : pour exécuter 'kubectl' depuis votre poste de travail.
  # - Accès privé activé : pour que les nœuds communiquent avec l'API server en interne.
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets # ici le cluster k8s vas travailler sut tous les subnets indiqué(chaque subnet existe dans une AZ alors il vas travailler accross tous les AZs indiqué)
  control_plane_subnet_ids = module.vpc.private_subnets

  # BONNE PRATIQUE (EKS Access Entries - Nouvelle norme AWS sans le ConfigMap aws-auth) :
  # Donne automatiquement les droits ClusterAdmin à l'utilisateur/rôle IAM qui exécute Terraform en utilisant An Access Entry + EKS Access Policy.
  enable_cluster_creator_admin_permissions = true

  # ============================================================================
  # Add-ons EKS Officiels
  # ============================================================================
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    # Indispensable pour la création dynamique des volumes persistants (PVCs) sur AWS EBS
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn #IRSA : Le Pod du aws-ebs-csi-driver doit appeler l'API AWS EC2 pour créer et attacher des volumes de stockage. Pour qu'il ait l'autorisation de le faire, on lie son ServiceAccount Kubernetes à un vrai rôle IAM AWS via son ARN.
      #Cette ligne n'écrit pas le rôle IAM, elle fait uniquement le pont (le lien) entre un rôle IAM déjà créé et le composant Kubernetes.
    }
  }

  # ============================================================================
  # Managed Node Groups (Groupe de Nœuds de Travail EC2)
  # ============================================================================
  eks_managed_node_groups = {
    main = {
      name = "product-intelligence-workers"

      instance_types = var.eks_node_instance_types
      capacity_type  = "ON_DEMAND" # Possibilité de changer en "SPOT" pour réduire les coûts de 70%

      min_size     = var.eks_node_min_size
      max_size     = var.eks_node_max_size
      desired_size = var.eks_node_desired_size

      # BONNE PRATIQUE (Sécurité des Workers) :
      # Les nœuds tournent dans les sous-réseaux privés, invisibles depuis Internet
      subnet_ids = module.vpc.private_subnets

      labels = {
        role        = "worker"
        Environment = var.environment
      }

      tags = {
        Environment = var.environment
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}

