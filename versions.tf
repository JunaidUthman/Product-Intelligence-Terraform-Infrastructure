terraform {
  required_version = ">= 1.10.0"

  # ============================================================================
  # Backend distant S3 avec verrouillage natif (Terraform 1.10+ / sans DynamoDB)
  # Créé préalablement via le sous-dossier bootstrap/
  # ============================================================================
  backend "s3" {
    bucket       = "product-intelligence-tfstate-<ACCOUNT_ID>" # Remplacer par le nom affiché par bootstrap
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # Verrouillage natif S3 moderne
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "product-intelligence"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

