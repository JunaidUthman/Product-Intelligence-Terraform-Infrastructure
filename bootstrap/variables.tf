variable "aws_region" {
  description = "Région AWS où créer le bucket de state"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nom de l'environnement (ex: prod)"
  type        = string
  default     = "prod"
}

