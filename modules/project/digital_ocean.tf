# ---------------------------------------------------------------------------------------------------------------------
# Project
# ---------------------------------------------------------------------------------------------------------------------
// Create project
resource "digitalocean_project" "do" {
  for_each = toset(var.do_enabled ? ["main"] : [])

  name        = local.project_name
  description = local.project_description
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "do_project_id" {
  value       = var.do_enabled ? digitalocean_project.do["main"].id : null
  description = "DigitalOcean project ID."
}
 