output "s3_bucket_name" {
  description = "Nom du bucket S3 créé pour le state Terraform"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN du bucket S3"
  value       = aws_s3_bucket.terraform_state.arn
}

output "backend_config_instructions" {
  description = "Instructions pour configurer le backend dans versions.tf"
  value       = <<-EOT
    Copiez ce bloc dans 'product-intelligence-terraform-infrastructure/versions.tf' :

    backend "s3" {
      bucket       = "${aws_s3_bucket.terraform_state.id}"
      key          = "prod/terraform.tfstate"
      region       = "${var.aws_region}"
      encrypt      = true
      use_lockfile = true
    }
  EOT
}

