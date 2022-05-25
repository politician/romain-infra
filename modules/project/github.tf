# ---------------------------------------------------------------------------------------------------------------------
# GitHub repository
# ---------------------------------------------------------------------------------------------------------------------
// Create repo
resource "github_repository" "github" {
  for_each = toset(var.github_enabled ? ["main"] : [])

  name                   = local.project_name
  description            = var.project_title
  visibility             = var.github_visibility
  auto_init              = true
  license_template       = var.github_visibility == "public" ? "apache-2.0" : null
  delete_branch_on_merge = true
  allow_auto_merge       = true
  allow_merge_commit     = false
  has_issues             = true
  has_projects           = false
  has_wiki               = false

  // Description is managed manually though the UI and fetched on each Terraform run
  lifecycle {
    ignore_changes = [description]
  }
}

// Add branch protection on main branch
resource "github_branch_protection" "github" {
  for_each = toset(var.github_enabled ? ["main"] : [])

  repository_id           = github_repository.github["main"].node_id
  pattern                 = "main"
  enforce_admins          = true
  require_signed_commits  = true
  required_linear_history = true
  allows_deletions        = true

  required_status_checks {
    strict = true
  }
}

// Get the repository directly from GitHub to always use a fresh description for other resources
data "github_repository" "github" {
  for_each = toset(var.github_enabled ? ["main"] : [])

  full_name = github_repository.github["main"].full_name
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "github_repository_name" {
  description = "GitHub repository name."
  value       = var.github_enabled ? github_repository.github["main"].full_name : null
}
