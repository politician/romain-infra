# ---------------------------------------------------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------------------------------------------------
variable "project_title" {
  description = "Human friendly project title (eg. `My project`)."
  type        = string
  nullable    = false
}

variable "project_name" {
  description = "Computer friendly project name (eg. `my-project`). Leave blank to generate from project title."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# Google Cloud Platform
# ---------------------------------------------------------------------------------------------------------------------
variable "gcp_enabled" {
  description = "Create Google Cloud Platform project."
  type        = bool
  default     = false
}

variable "gcp_organization_id" {
  description = "If GCP is enabled, you must specify the organization id."
  type        = string
  default     = null
}

variable "gcp_enabled_apis" {
  description = "GCP APIs to enable for this project."
  type        = set(string)
  default     = []
}

variable "gcp_admin_users" {
  description = "Users to be added as admins of the project. Use the format `serviceAccount:<email>`, `user:<email>`, [etc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#member/members)."
  type        = map(string)
  default     = {}
}

variable "gcp_billing_account_id" {
  description = "Billing account id for this project."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# Amazon Web Services
# ---------------------------------------------------------------------------------------------------------------------
variable "aws_enabled" {
  description = "Create Amazon Web Services sub-account."
  type        = bool
  default     = false
}

variable "aws_account_email" {
  description = "If AWS is enabled, you must specify the sub-account email."
  type        = string
  default     = null
}

variable "aws_admin_users" {
  description = "Usernames to be added as admins of the newly created sub-account."
  type        = set(string)
  default     = []
}

# ---------------------------------------------------------------------------------------------------------------------
# Key Management System (Google)
# ---------------------------------------------------------------------------------------------------------------------
variable "kms_enabled" {
  description = "Create encryption/decryption key in Google KMS."
  type        = bool
  default     = false
}

variable "kms_keyring_id" {
  description = "Specify the KMS keyring id."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# Digital Ocean
# ---------------------------------------------------------------------------------------------------------------------
variable "do_enabled" {
  description = "Create Digital Ocean project."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes
# ---------------------------------------------------------------------------------------------------------------------
# variable "k8s_enabled" {
#   description = "Create Kubernetes namespace."
#   type = bool
#   default = false
# }

# ---------------------------------------------------------------------------------------------------------------------
# Terraform Cloud
# ---------------------------------------------------------------------------------------------------------------------
variable "tfe_enabled" {
  description = "Create Terraform Cloud workspace."
  type        = bool
  default     = false
}

variable "tfe_organization_name" {
  description = "If Terraform Cloud is enabled, you must specify the organization name."
  type        = string
  default     = null
}

variable "tfe_oauth_token_id" {
  description = "Terraform Cloud OAuth token id."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# GitHub
# ---------------------------------------------------------------------------------------------------------------------
variable "github_enabled" {
  description = "Create GitHub repo."
  type        = bool
  default     = false
}

variable "github_visibility" {
  description = "GitHub repo visibility."
  type        = string
  default     = "private"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals
# ---------------------------------------------------------------------------------------------------------------------
// Get normalized project_id
module "project_name" {
  source   = "Olivr/normalize/null"
  version  = "1.0.0"
  for_each = toset(var.project_name != null && var.project_name != "" ? [] : ["main"])
  string   = var.project_title
}

locals {
  project_name        = var.project_name != null && var.project_name != "" ? var.project_name : module.project_name["main"].lower
  project_description = var.github_enabled ? data.github_repository.github["main"].description : var.project_title
  tags = {
    automation = "true"
    terraform  = "true"
    project    = local.project_name
  }
}