# ==============================================================================
# 1. Identifiant du compte AWS (pour garantir un nom de bucket unique au monde)
# ==============================================================================

data "aws_caller_identity" "current" {} # cette valeurs est recuperé pour etre utilisé dans le nom du bucket

# ==============================================================================
# 2. Bucket S3 pour le Remote State Terraform
# ==============================================================================

resource "aws_s3_bucket" "terraform_state" {
  bucket = "product-intelligence-tfstate-${data.aws_caller_identity.current.account_id}" #nom du bucket

  # Protection contre la suppression accidentelle
  lifecycle {
    prevent_destroy = true # si quelqu'un tape terrfaorm destroy, le bucket ne vas pas etre detruit
  }

  tags = {
    Name        = "product-intelligence-tfstate"
    Description = "Bucket securise pour le stockage du state Terraform avec verrouillage natif S3"
  }
}

# ==============================================================================
# 3. Activation du Versioning (Obligatoire pour la sécurité du state)
# Permet de restaurer un ancien état si un terraform apply corrompt le state.
# ==============================================================================

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled" # comme ca, il ya un versionnement des fichiers tfstate. alors on peut revenir a l'mport quel version.
  }
}

# ==============================================================================
# 4. Chiffrement au repos (Server-Side Encryption AES256)
# ==============================================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ==============================================================================
# 5. Blocage strict de tout accès public (Sécurité maximale)
# ==============================================================================

resource "aws_s3_bucket_public_access_block" "state_public_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true # Rejette toute ACL qui tenterait de rendre un fichier public.
  block_public_policy     = true # Ignore toutes les ACLs publiques existantes.
  ignore_public_acls      = true # Rejette toute politique de bucket (bucket policy) qui autoriserait un accès public.
  restrict_public_buckets = true # Restreint l'accès uniquement aux utilisateurs authentifiés et autorisés de votre compte AWS.
}

