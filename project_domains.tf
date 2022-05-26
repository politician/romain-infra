# ---------------------------------------------------------------------------------------------------------------------
# Project
# ---------------------------------------------------------------------------------------------------------------------
module "domains" {
  source = "./modules/project"

  project_title = "Domain names manager"
  project_name  = "domains"

  # kms_enabled     = true
  # kms_keyring_id = google_kms_key_ring.romain.id

  github_enabled = true
  do_enabled     = true
}

# ---------------------------------------------------------------------------------------------------------------------
# Additional resources
# ---------------------------------------------------------------------------------------------------------------------
# Github runner for domains repo
module "gh_runner_domains" {
  source  = "politician/github-runner/digitalocean"
  version = "1.0.0"

  ssh_key        = "f8:6b:7b:4e:24:42:a9:9b:05:ec:94:53:b6:6c:27:f8"
  runner_scope   = "politician/domains"
  runner_token   = var.domains_runner_token
  add_to_project = true
  do_project_id  = module.domains.do_project_id

  # Make sure Ubuntu version is not auto-updated because it will rotate the IP of the droplet
  # If this is the case this IP will need to be whitelisted again with the various domain providers
  ubuntu_version = "^22\\.04 \\(LTS\\) x64$"
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "gh_runner_domains_ips" {
  value = module.gh_runner_domains.ips
}
