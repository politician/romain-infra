# Inception mode! (this repo manages itself)

# ---------------------------------------------------------------------------------------------------------------------
# Project
# ---------------------------------------------------------------------------------------------------------------------
module "romain-infra" {
  source = "./modules/project"

  project_title = "Romain's infrastructure"
  project_name  = "romain-infra"

  gcp_enabled            = true
  gcp_organization_id    = var.gcp_organization_id
  gcp_billing_account_id = var.gcp_billing_account_id
  gcp_admin_users = {
    admin = "user:${var.gcp_admin_email}"
  }
  gcp_enabled_apis = [
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
  ]

  github_enabled    = true
  github_visibility = "public"

  tfe_enabled           = true
  tfe_organization_name = var.tfe_organization_name
  tfe_oauth_token_id    = var.tfe_oauth_token_id

  aws_enabled       = true
  aws_account_email = "romain-infra.aws.romain@${var.email_domain}"
  aws_admin_users   = [aws_iam_user.global.name]
}

# ---------------------------------------------------------------------------------------------------------------------
# Google Cloud Platform Permissions
# ---------------------------------------------------------------------------------------------------------------------
// Terraform user can manage project / billing accounts links
resource "google_billing_account_iam_member" "terraform_billing" {
  billing_account_id = var.gcp_billing_account_id
  role               = "roles/billing.user"
  member             = "serviceAccount:${module.romain-infra.gcp_terraform_user_email}"
}

// Terraform user can manage IAM policies at the organization level
resource "google_organization_iam_member" "terraform_org-admin" {
  org_id = var.gcp_organization_id
  role   = "roles/resourcemanager.organizationAdmin"
  member = "serviceAccount:${module.romain-infra.gcp_terraform_user_email}"
}

// Terraform user can create projects
resource "google_organization_iam_member" "terraform_project-creator" {
  org_id = var.gcp_organization_id
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${module.romain-infra.gcp_terraform_user_email}"
}

// Terraform user can delete projects
resource "google_organization_iam_member" "terraform_project-deleter" {
  org_id = var.gcp_organization_id
  role   = "roles/resourcemanager.projectDeleter"
  member = "serviceAccount:${module.romain-infra.gcp_terraform_user_email}"
}

# resource "google_project_iam_member" "terraform_owner" {
#   project = var.gcp_iam_project_id
#   role    = "roles/owner"
#   member  = "serviceAccount:${module.romain-infra.gcp_terraform_user_email}"
# }

# // Terraform user can manage any IAM policy in the users project
# resource "google_project_iam_member" "terraform_users-iam-admin" {
#   project = var.gcp_iam_project_id
#   role    = "roles/iam.securityAdmin"
#   member  = "serviceAccount:${module.romain-infra.gcp_terraform_user_email}"
# }

# // Terraform user can manage service accounts in the users project
# resource "google_project_iam_member" "terraform_users-serviceaccount-admin" {
#   project = var.gcp_iam_project_id
#   role    = "roles/iam.serviceAccountAdmin"
#   member  = "serviceAccount:${module.romain-infra.gcp_terraform_user_email}"
# }

# // Terraform user can manage keys for service accounts in the users project
# resource "google_project_iam_member" "terraform_users-serviceaccountkey-admin" {
#   project = var.gcp_iam_project_id
#   role    = "roles/iam.serviceAccountKeyAdmin"
#   member  = "serviceAccount:${module.romain-infra.gcp_terraform_user_email}"
# }

# ---------------------------------------------------------------------------------------------------------------------
# AWS Permissions
# ---------------------------------------------------------------------------------------------------------------------
// Allow Terraform user to manage IAM users
resource "aws_iam_user_policy_attachment" "romain-infra_iam-admin" {
  user       = module.romain-infra.aws_terraform_user_name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

// Allow Terraform user to manage organization accounts
resource "aws_iam_user_policy_attachment" "romain-infra_org-admin" {
  user       = module.romain-infra.aws_terraform_user_name
  policy_arn = "arn:aws:iam::aws:policy/AWSOrganizationsFullAccess"
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "romain-infra" {
  description = "romain-infra project."
  value       = module.romain-infra
  sensitive   = true
}

output "romain-infra-envrc" {
  description = "Generate Terraform users credentials ready to be used in an .envrc file. View it with `terraform output -json romain-infra-envrc | jq -r`"
  sensitive   = true
  value       = <<-EOF
    # ---------------------------------------------------------------------------------------------------------------------
    # AWS (${module.romain-infra.aws_terraform_user_arn})
    # ---------------------------------------------------------------------------------------------------------------------
    export AWS_ACCESS_KEY_ID="${module.romain-infra.aws_terraform_user_access_key_id}"
    export AWS_SECRET_ACCESS_KEY="${module.romain-infra.aws_terraform_user_access_key_secret}"
    
    # ---------------------------------------------------------------------------------------------------------------------
    # Google (${module.romain-infra.gcp_terraform_user_email})
    # ---------------------------------------------------------------------------------------------------------------------
    export GOOGLE_CREDENTIALS='${replace(base64decode(module.romain-infra.gcp_terraform_user_secret_key), "\n", "")}'
    EOF
}
