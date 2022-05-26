# ---------------------------------------------------------------------------------------------------------------------
# Project
# ---------------------------------------------------------------------------------------------------------------------
module "barissat-infra" {
  source = "./modules/project"

  project_title = "Barissat's infrastructure"
  project_name  = "barissat-infra"

  gcp_enabled            = true
  gcp_organization_id    = var.gcp_organization_id
  gcp_billing_account_id = var.gcp_billing_account_id
  gcp_admin_users = {
    admin     = "user:${var.gcp_admin_email}",
    terraform = "serviceAccount:${module.romain-infra.gcp_terraform_user_email}"
  }
  gcp_enabled_apis = [
    "admin.googleapis.com",
    "cloudkms.googleapis.com",
  ]

  kms_enabled    = true
  kms_keyring_id = google_kms_key_ring.global.id

  github_enabled    = true
  github_visibility = "public"

  tfe_enabled           = true
  tfe_organization_name = var.tfe_organization_name
  tfe_oauth_token_id    = var.tfe_oauth_token_id

  // During testing I ran into quota limits and can't close sub-accounts before 30 days
  // Must disable AWS after June, 25th 2022 because I don't need it for this project
  aws_enabled       = true
  aws_account_email = "barissat-infra.aws.romain@${var.email_domain}"
  aws_admin_users = [
    aws_iam_user.global.name,
    module.romain-infra.aws_terraform_user_name
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Additional resources
# ---------------------------------------------------------------------------------------------------------------------
// Add Google Workspace credentials to Terraform Cloud
resource "tfe_variable" "googleworkspace_credentials" {
  workspace_id = module.barissat-infra.tfe_workspace_id
  category     = "env"
  description  = module.barissat-infra.gcp_terraform_user_email
  key          = "GOOGLEWORKSPACE_CREDENTIALS"
  value        = replace(base64decode(module.barissat-infra.gcp_terraform_user_secret_key), "\n", "")
  sensitive    = true
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "barissat-infra" {
  description = "barissat-infra project."
  value       = module.barissat-infra
  sensitive   = true
}

output "barissat_gcp_terraform_user_id" {
  description = "barissat-infra GCP Terraform user ID."
  value       = module.barissat-infra.gcp_terraform_user_id
}

output "barissat_kms_user_email" {
  description = "barissat-infra KMS user email."
  value       = module.barissat-infra.kms_user_email
}

output "barissat_kms_user_secret_key" {
  description = "barissat-infra KMS user secret key."
  value       = module.barissat-infra.kms_user_secret_key
  sensitive   = true
}

output "barissat_kms_key_id" {
  description = "Encryption/Decryption key ID for barissat-infra."
  value       = module.barissat-infra.kms_key_id
}

output "barissat-infra-envrc" {
  description = "Generate Terraform users credentials ready to be used in an .envrc file. View it with `terraform output -json barissat-infra-envrc | jq -r`"
  sensitive   = true
  value       = <<-EOF
    # ---------------------------------------------------------------------------------------------------------------------
    # Google (${module.barissat-infra.gcp_terraform_user_email})
    # ---------------------------------------------------------------------------------------------------------------------
    export GOOGLE_CREDENTIALS='${replace(base64decode(module.barissat-infra.gcp_terraform_user_secret_key), "\n", "")}'
    EOF
}
