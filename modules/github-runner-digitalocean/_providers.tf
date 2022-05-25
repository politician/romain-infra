terraform {
  required_version = ">= 1.2.1"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.19.0"
    }
  }
}
