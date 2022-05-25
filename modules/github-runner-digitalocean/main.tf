# Get the cheapest droplet
data "digitalocean_sizes" "main" {
  filter {
    key    = "available"
    values = [true]
  }
  filter {
    key    = "regions"
    values = [var.region]
  }
  sort {
    key       = "price_monthly"
    direction = "asc"
  }
}

# Get the latest Ubuntu
data "digitalocean_images" "ubuntu" {
  filter {
    key    = "distribution"
    values = ["Ubuntu"]
  }
  filter {
    key    = "regions"
    values = [var.region]
  }
  sort {
    key       = "created"
    direction = "desc"
  }

  # TODO: Route through floating IP https://docs.digitalocean.com/products/networking/floating-ips/how-to/outbound-traffic/
  # Auto-update the ubuntu image
  # filter {
  #   key      = "description"
  #   values   = ["^Ubuntu .* x64$"]
  #   match_by = "re"
  # }

  # But for now, don't auto-update the image because it will rotate the IP of the droplet
  # and this IP will need to be whitelisted again with the various domain providers
  filter {
    key    = "description"
    values = ["Ubuntu 22.04 x64"]
  }
}

locals {
  runner_name = var.runner_name != null ? var.runner_name : format("do-gh-runner-%s", replace(var.runner_scope, "/", "-"))
}

# Create a GitHub runner
resource "digitalocean_droplet" "github_runner" {
  image      = data.digitalocean_images.ubuntu.images[0].slug
  name       = local.runner_name
  region     = var.region
  size       = data.digitalocean_sizes.main.sizes[0].slug
  monitoring = true // Free
  ipv6       = true // Free
  ssh_keys   = [var.ssh_key]
  user_data  = <<-EOF
  #cloud-config
  users:
    - name: runner
      groups: sudo
      shell: /bin/bash
      sudo: ['ALL=(ALL) NOPASSWD:ALL']
  runcmd:
    - [su, runner, -c, "mkdir ~/actions-runner"]
    - [su, runner, -c, "curl -o ~/actions-runner/actions-runner-linux-x64-2.287.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.287.1/actions-runner-linux-x64-2.287.1.tar.gz"]
    - [su, runner, -c, "tar xzf ~/actions-runner/actions-runner-linux-x64-2.287.1.tar.gz -C ~/actions-runner"]
    - [su, runner, -c, "~/actions-runner/config.sh --unattended --url https://github.com/${var.runner_scope} --token ${var.runner_token}"]
    - cd /home/runner/actions-runner
    - ./svc.sh install
    - ./svc.sh start
  EOF
}

resource "digitalocean_project_resources" "project_resources" {
  for_each = toset(var.do_project_id != null ? [var.do_project_id] : [])

  project = var.do_project_id
  resources = [
    digitalocean_droplet.github_runner.urn
  ]
}

output "ips" {
  description = "Github runner IP addresses (ipv4 & ipv6)."
  value = {
    ipv4 = digitalocean_droplet.github_runner.ipv4_address
    ipv6 = digitalocean_droplet.github_runner.ipv6_address
  }
}
