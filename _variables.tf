# ---------------------------------------------------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------------------------------------------------
variable "email_domain" {
  description = "Domain name used for my emails. I put it in a variable because this repo is public."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Google Cloud Platform
# ---------------------------------------------------------------------------------------------------------------------
variable "gcp_organization_id" {
  description = "GCP organization id."
  type        = string
}

variable "gcp_admin_email" {
  description = "My GCP admin email."
  type        = string
}

variable "gcp_billing_account_id" {
  description = "Billing account id for this project."
  type        = string
  default     = null
}

# variable "gcp_iam_project_id" {
#   description = "IAM account project ID."
#   type        = string
#   default     = null
# }

# ---------------------------------------------------------------------------------------------------------------------
# Terraform Cloud
# ---------------------------------------------------------------------------------------------------------------------
variable "tfe_organization_name" {
  description = "If Terraform Cloud is enabled, you must specify the organization name."
  type        = string
  default     = null
}

variable "tfe_oauth_token_id" {
  description = "Terraform Cloud OAuth token id."
  type        = string
}
