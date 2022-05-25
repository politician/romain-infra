# ---------------------------------------------------------------------------------------------------------------------
# Terraform Cloud workspace
# ---------------------------------------------------------------------------------------------------------------------
resource "tfe_workspace" "tfe" {
  for_each = toset(var.tfe_enabled ? ["main"] : [])

  name         = local.project_name
  organization = var.tfe_organization_name
  auto_apply   = true
  description  = local.project_description

  dynamic "vcs_repo" {
    for_each = toset(var.github_enabled ? ["github"] : [])
    content {
      oauth_token_id = var.tfe_oauth_token_id
      identifier     = github_repository.github["main"].full_name
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Cloud credentials
# ---------------------------------------------------------------------------------------------------------------------
// Amazon Web Services
resource "tfe_variable" "aws_key_id" {
  for_each = toset(var.tfe_enabled && var.aws_enabled ? ["main"] : [])

  workspace_id = tfe_workspace.tfe["main"].id
  category     = "env"
  description  = aws_iam_user.terraform["main"].arn
  key          = "AWS_ACCESS_KEY_ID"
  value        = aws_iam_access_key.terraform["main"].id
}

resource "tfe_variable" "aws_key_secret" {
  for_each = toset(var.tfe_enabled && var.aws_enabled ? ["main"] : [])

  workspace_id = tfe_workspace.tfe["main"].id
  category     = "env"
  description  = aws_iam_user.terraform["main"].arn
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = aws_iam_access_key.terraform["main"].secret
  sensitive    = true
}

// Google Cloud Platform
resource "tfe_variable" "google_credentials" {
  for_each = toset(var.tfe_enabled && var.gcp_enabled ? ["main"] : [])

  workspace_id = tfe_workspace.tfe["main"].id
  category     = "env"
  description  = google_service_account.terraform["main"].email
  key          = "GOOGLE_CREDENTIALS"
  value        = replace(base64decode(google_service_account_key.terraform["main"].private_key), "\n", "")
  sensitive    = true
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "tfe_workspace_id" {
  value       = var.tfe_enabled ? tfe_workspace.tfe["main"].id : null
  description = "Terraform Cloud workspace ID."
}