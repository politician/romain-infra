# ---------------------------------------------------------------------------------------------------------------------
# Digital Ocean
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {
  description = "Define which region to use. [More info](https://docs.digitalocean.com/products/platform/availability-matrix/#available-datacenters)"
  type        = string
  default     = "nyc1"
}

variable "do_project_id" {
  description = "Digital Ocean project ID."
  type        = string
  default     = null
}

variable "ssh_key" {
  description = "SSH key fingerprint to administrate the droplet."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# GitHub
# ---------------------------------------------------------------------------------------------------------------------
variable "runner_name" {
  description = "Name of the runner."
  type        = string
  default     = null
}

variable "runner_scope" {
  description = "Runner registration repo/org."
  type        = string
}

variable "runner_token" {
  description = <<-EOF
    Runner registration token. Get it with:
    ```
    gh api -p everest -X POST repos/{owner}/{repo}/actions/runners/registration-token | jq .token
    ```
    EOF
  type        = string
}
