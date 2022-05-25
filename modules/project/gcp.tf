# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
// Generate unique ID for naming KMS key
resource "random_integer" "gcp" {
  for_each = toset(var.gcp_enabled ? ["main"] : [])

  min = 100000
  max = 999999
}

locals {
  # gcp_terraform_user = format("%s-terraform", local.project_name)
  gcp_terraform_user = "terraform"
}

# ---------------------------------------------------------------------------------------------------------------------
# Project
# ---------------------------------------------------------------------------------------------------------------------
resource "google_project" "gcp" {
  for_each = toset(var.gcp_enabled ? ["main"] : [])

  name            = var.project_title
  project_id      = format("%s-%s", local.project_name, random_integer.gcp["main"].id)
  org_id          = var.gcp_organization_id
  labels          = local.tags
  billing_account = var.gcp_billing_account_id

  lifecycle {
    create_before_destroy = true
  }
}

// Enable APIs
resource "google_project_service" "enabled" {
  for_each = toset(var.gcp_enabled ? var.gcp_enabled_apis : [])

  project                    = google_project.gcp["main"].id
  service                    = each.value
  disable_dependent_services = true
}

# ---------------------------------------------------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------------------------------------------------
// Terraform user
resource "google_service_account" "terraform" {
  for_each = toset(var.gcp_enabled ? ["main"] : [])

  project      = google_project.gcp["main"].project_id
  account_id   = local.gcp_terraform_user
  display_name = local.gcp_terraform_user
  description  = format("Terraform user for %s", var.project_title)
  lifecycle {
    create_before_destroy = true
  }
}

// Generate access key for Terraform user
resource "google_service_account_key" "terraform" {
  for_each = toset(var.gcp_enabled ? ["main"] : [])

  service_account_id = google_service_account.terraform["main"].name
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Permissions
# ---------------------------------------------------------------------------------------------------------------------
// Terraform user can manage all resources within project
resource "google_project_iam_member" "terraform_owner" {
  for_each = toset(var.gcp_enabled ? ["main"] : [])

  project = google_project.gcp["main"].project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.terraform["main"].email}"
}

// Admin users can manage all resources within project
resource "google_project_iam_member" "admin_owners" {
  for_each = var.gcp_enabled ? var.gcp_admin_users : {}

  project = google_project.gcp["main"].project_id
  role    = "roles/owner"
  member  = each.value
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "gcp_project_id" {
  description = "GCP project ID."
  value       = var.gcp_enabled ? google_project.gcp["main"].project_id : null
}

output "gcp_terraform_user_id" {
  description = "GCP service account ID."
  value       = var.gcp_enabled ? google_service_account.terraform["main"].unique_id : null
}

output "gcp_terraform_user_email" {
  description = "GCP service account email."
  value       = var.gcp_enabled ? google_service_account.terraform["main"].email : null
}

output "gcp_terraform_user_secret_key" {
  description = "GCP service account key."
  value       = var.gcp_enabled ? google_service_account_key.terraform["main"].private_key : null
  sensitive   = true
}
